package ai

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"owner/internal/domain/models"
	"owner/internal/domain/ports"
	"owner/internal/lib/logger"
	"sync"
	"time"
)

type aiClient struct {
	client http.Client
	mu     sync.Mutex
	logger *logger.Logger
}

const url = "http://localhost:3004/"

func NewAIClient(logger *logger.Logger) ports.AIClient {
	client := http.Client{Timeout: time.Minute * 5}

	return &aiClient{client: client, logger: logger}
}

func (a *aiClient) Generate(data models.GenerateReq) (models.History, error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	body, err := json.Marshal(data)
	if err != nil {
		return models.History{}, fmt.Errorf("ошибка сериализации JSON: %w", err)
	}

	req, err := http.NewRequest(http.MethodPost, url+"api/generate", bytes.NewBuffer(body))
	if err != nil {
		return models.History{}, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := a.client.Do(req)
	if err != nil {
		return models.History{}, fmt.Errorf("ошибка запроса: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		return models.History{}, fmt.Errorf("сервер вернул %d: %s", resp.StatusCode, string(respBody))
	}

	response, err := io.ReadAll(resp.Body)
	if err != nil {
		return models.History{}, fmt.Errorf("ошибка чтения тела ответа: %w", err)
	}

	var videoTras models.History
	if err := json.Unmarshal(response, &videoTras); err != nil {
		return models.History{}, fmt.Errorf("ошибка парсинга ответа: %w", err)
	}

	if len(videoTras.Timecodes) > 0 {
		videoTras.VideoTitle = videoTras.Timecodes[0].Descriptions
	} else {
		videoTras.VideoTitle = "Untitled"
	}

	for _, r := range videoTras.Highlights {
		r.HistoryID = videoTras.ID
	}

	return videoTras, nil

}

func parseOpenAISummary(response []byte) (models.History, error) {
	var summary models.History

	if err := json.Unmarshal(response, &summary); err == nil {
		if summary.VideoTitle != "" {
			return summary, nil
		}
	}

	var raw string
	if err := json.Unmarshal(response, &raw); err != nil {
		return models.History{}, fmt.Errorf("не удалось распарсить ответ как JSON или string: %w", err)
	}

	if err := json.Unmarshal([]byte(raw), &summary); err != nil {
		return models.History{}, fmt.Errorf("не удалось распарсить вложенный JSON: %w", err)
	}

	if summary.VideoTitle == "" {
		summary.VideoTitle = "Без названия видео"
	}

	for _, r := range summary.Highlights {
		r.HistoryID = summary.ID
	}

	return summary, nil
}
