# youtube-ai-service (Go REST)

Simple REST API in Go that:
- downloads audio from YouTube via `yt-dlp`
- transcribes audio using OpenAI Whisper
- generates summaries/conспекты/пересказы with timecodes using OpenAI GPT

## Requirements
- Go 1.23
- yt-dlp in PATH
- ffmpeg in PATH (yt-dlp uses it for audio extraction)
- OpenAI API key in environment variable `OPENAI_API_KEY`

## Quickstart (Windows)
1. Unzip the project and open terminal in project root.
2. Install dependencies and tidy:

```bash
cd youtube-ai-go
go mod tidy
```

3. Set OpenAI key (PowerShell):
```powershell
setx OPENAI_API_KEY "sk-..."
```
Restart your terminal after setx.

4. Run server:
```bash
go run ./cmd/server
```

5. Test endpoint:
```bash
curl -X POST http://localhost:8080/api/generate -H "Content-Type: application/json" -d '{"url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ","type":"конспект"}'
```

## Notes
- This project expects `yt-dlp` and `ffmpeg` available in PATH.
- Be careful with OpenAI costs; Whisper and GPT calls are paid.
- The summarization prompt asks the model to create timecodes; depending on the transcript quality, results will vary.
