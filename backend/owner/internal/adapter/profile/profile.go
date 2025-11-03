package profile

import (
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

type profileClient struct {
	client http.Client
	mu     sync.Mutex
	logger *logger.Logger
}

var instance string = "profile.service:"

func NewProfile(logger *logger.Logger) ports.ProfileClient {
	client := http.Client{Timeout: time.Minute}

	return &profileClient{client: client, logger: logger}
}

func (p *profileClient) GetByID(id string) (*models.User, error) {
	locInstance := "api/profile/{user_id}"

	p.logger.Info("%s генерация запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodGet, "http://localhost:3002/api/profile/"+id, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка генерации запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	p.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка запроса: %w", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(body))
	}

	var result models.User
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("ошибка декодирования JSON: %w", err)
	}

	return &result, nil
}

func (p *profileClient) UpdateAvatar(id string) (*models.User, error) {
	locInstance := "api/profile/{user_id}/photo"

	pathUrl := fmt.Sprintf("http://localhost:3002/api/profile/%s/photo", id)

	p.logger.Info("%s генерация запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodPut, pathUrl, nil)
	if err != nil {
		return nil, fmt.Errorf("ошибка генерации запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	p.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка запроса: %w", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(body))
	}

	var result models.User
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("ошибка декодирования JSON: %w", err)
	}

	return &result, nil
}

func (p *profileClient) GetUserPhoto(userID int) ([]byte, string, error) {
	locInstance := "api/profile/{id}/photo"
	url := fmt.Sprintf("http://localhost:3002/api/profile/%d/photo", userID)

	p.logger.Info("%s Генерация нового запроса: %s", instance, locInstance)

	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, "", fmt.Errorf("ошибка создания запроса: %w", err)
	}

	resp, err := p.client.Do(req)
	if err != nil {
		return nil, "", fmt.Errorf("ошибка выполнения запроса: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return nil, "", fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(b))
	}

	contentType := resp.Header.Get("Content-Type")

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, "", fmt.Errorf("ошибка чтения ответа: %w", err)
	}

	return data, contentType, nil
}
