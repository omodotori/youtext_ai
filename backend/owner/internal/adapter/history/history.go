package history

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

type history struct {
	client http.Client
	mu     sync.Mutex
	logger *logger.Logger
}

var instance string = "history.service:"

func NewHistory(logger *logger.Logger) ports.HistoryClient {
	client := http.Client{Timeout: time.Minute}

	return &history{client: client, logger: logger}
}

func (h *history) AddHistory(data models.Summary) error {
	locInstance := "api/history"
	h.mu.Lock()
	defer h.mu.Unlock()

	body, err := json.Marshal(data)
	if err != nil {
		return fmt.Errorf("ошибка сериализации JSON: %w", err)
	}

	h.logger.Info("%s генерация запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodPost, "http://localhost:3001/api/history", bytes.NewBuffer(body))
	if err != nil {
		return fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	_, err = h.client.Do(req)
	if err != nil {
		return fmt.Errorf("ошибка запроса: %w", err)
	}

	return nil
}

func (h *history) GetHistoryByID(id string) (*[]models.Summary, error) {
	locInstance := "api/history/{user_id}"

	h.logger.Info("%s генерация запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodGet, "http://localhost:3001/api/history/"+id, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка генерации запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := h.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка запроса: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(body))
	}

	var result []models.Summary
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("ошибка декодирования JSON: %w", err)
	}

	return &result, nil
}
