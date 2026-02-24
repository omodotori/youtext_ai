package services

import (
	"aiia/internal/lib"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	openai "github.com/sashabaranov/go-openai"
	"github.com/sirupsen/logrus"
)

type Service struct {
	log      *logrus.Logger
	openai   *openai.Client
	ytdlpCmd string
}

func NewService(log *logrus.Logger, openaiKey, ytdlpCmd string) *Service {
	var client *openai.Client
	if openaiKey != "" {
		client = openai.NewClient(openaiKey)
	}
	return &Service{log: log, openai: client, ytdlpCmd: ytdlpCmd}
}

func (s *Service) Process(videoURL, typ string) (*lib.Summary, error) {
	tmpDir := os.TempDir()
	outFile := filepath.Join(tmpDir, fmt.Sprintf("audio-%d.mp3", time.Now().UnixNano()))

	s.log.Infof("Downloading audio to %s", outFile)
	if err := s.downloadAudio(videoURL, outFile); err != nil {
		return nil, fmt.Errorf("download failed: %w", err)
	}
	defer func() { _ = os.Remove(outFile) }()

	s.log.Infof("Transcribing audio with Whisper")
	transcript, err := s.transcribe(outFile)
	if err != nil {
		return nil, fmt.Errorf("transcription failed: %w", err)
	}

	s.log.Infof("Generating summary (type=%s)", typ)
	summary, err := s.generateSummary(transcript, typ)
	if err != nil {
		return nil, fmt.Errorf("generate summary failed: %w", err)
	}

	return lib.ParseJSON(summary)
}

func (s *Service) downloadAudio(url, outPath string) error {
	if err := os.MkdirAll(filepath.Dir(outPath), 0o755); err != nil {
		return err
	}
	cmd := exec.Command(s.ytdlpCmd, "-x", "--audio-format", "mp3", "-o", outPath, url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func (s *Service) transcribe(path string) (string, error) {
	if s.openai == nil {
		return "", fmt.Errorf("openai client not configured (set OPENAI_API_KEY)")
	}
	f, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer f.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	req := openai.AudioRequest{
		Model:    openai.Whisper1,
		FilePath: path,
	}
	resp, err := s.openai.CreateTranscription(ctx, req)
	if err != nil {
		return "", err
	}
	return resp.Text, nil
}

func (s *Service) generateSummary(transcript, typ string) (string, error) {
	if s.openai == nil {
		return "", fmt.Errorf("openai client not configured (set OPENAI_API_KEY)")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()

	prompt := fmt.Sprintf(`
Ты — ассистент, который делает структурированный JSON с таймкодами из расшифровки видео.

⚠️ Правила:
- Верни строго корректный JSON.
- В video_title должна быть основная тема видео. Если из текста её нельзя извлечь — придумай реалистичное короткое название.
- Не добавляй никакого текста, комментариев или пояснений вне JSON.
- Все поля должны быть заполнены: ничего не должно быть null или пустым ("").
- Если чего-то нет в расшифровке — придумай реалистичное значение.
- Даты формируй в формате ISO8601, например "2025-11-05T00:00:00Z".
- Поле "timecodes" должно содержать не менее 3 элементов.

Формат:
{
  "video_title": "тай",
  "link": "string",
  "text": "string (summary)",
  "transcript": "string (full text or short version)",
  "highlights": ["string", "string"],
  "timecodes": [
    {"timecode": "00:00", "descriptions": "string"},
    {"timecode": "02:00", "descriptions": "string"}
  ]
}

Тип анализа: %s
Текст расшифровки:
%s
`, typ, transcript)

	req := openai.ChatCompletionRequest{
		Model: openai.GPT4oMini,
		Messages: []openai.ChatCompletionMessage{
			{
				Role: openai.ChatMessageRoleSystem,
				Content: `
Ты — точный JSON-генератор. 
Возвращай только валидный JSON без пустых или null полей. 
Если данных нет — выдумай логичные значения.`,
			},
			{
				Role:    openai.ChatMessageRoleUser,
				Content: prompt,
			},
		},
		MaxTokens:   2000,
		Temperature: 0.4,
	}

	resp, err := s.openai.CreateChatCompletion(ctx, req)
	if err != nil {
		return "", err
	}

	if len(resp.Choices) == 0 {
		return "", fmt.Errorf("empty response from model")
	}

	fmt.Println(resp.Choices[0].Message.Content)

	return resp.Choices[0].Message.Content, nil
}
