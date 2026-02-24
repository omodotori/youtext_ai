package auth

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"owner/internal/domain/models"
	"owner/internal/domain/ports"
	"owner/internal/lib/apperrors"
	"owner/internal/lib/logger"
	"sync"
	"time"
)

var instance string = "auth.service:"

type authClient struct {
	client http.Client
	mu     sync.Mutex
	logger *logger.Logger
}

const url = "http://localhost:3003/"

func NewAuth(logger *logger.Logger) ports.AuthClient {
	client := http.Client{Timeout: time.Minute}

	return &authClient{client: client, logger: logger}
}

func (h *authClient) Register(data models.User) (*models.RegisterResp, error) {
	locInstance := "api/auth/register"

	h.mu.Lock()
	defer h.mu.Unlock()

	body, err := json.Marshal(data)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации JSON: %w", err)
	}

	h.logger.Info("%s Генерация нового запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodPost, url+locInstance, bytes.NewBuffer(body))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := h.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка запроса: %w", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(b))
	}

	var result models.RegisterResp
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("ошибка декодирования JSON: %w", err)
	}

	return &result, nil
}

func (h *authClient) Login(data models.User) (*models.Tokens, error) {
	locInstance := "api/auth/login"

	h.mu.Lock()
	defer h.mu.Unlock()

	body, err := json.Marshal(data)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации JSON: %w", err)
	}

	h.logger.Info("%s Генерация нового запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodPost, url+locInstance, bytes.NewBuffer(body))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := h.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка запроса: %w", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(b))
	}

	response, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("ошибка чтения тела ответа: %w", err)
	}

	var result models.Tokens
	if err := json.Unmarshal(response, &result); err != nil {
		return nil, fmt.Errorf("ошибка декодирования JSON: %w", err)
	}

	return &result, nil
}

func (h *authClient) Logout(id string) error {
	locInstance := "api/auth/logout/"

	h.mu.Lock()
	defer h.mu.Unlock()

	h.logger.Info("%s Генерация нового запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodPost, url+locInstance+id, nil)
	if err != nil {
		return fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := h.client.Do(req)
	if err != nil {
		return fmt.Errorf("ошибка запроса: %w", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(b))
	}

	return nil
}

func (h *authClient) NewAccessToken(refreshToken *models.Tokens) (*models.Tokens, error) {
	locInstance := "api/auth/refresh"

	body, err := json.Marshal(refreshToken)
	if err != nil {
		return nil, fmt.Errorf("ошибка сериализации JSON", err)
	}

	h.logger.Info("%s генерация запроса: %s", instance, locInstance)
	req, err := http.NewRequest(http.MethodPost, url+locInstance, bytes.NewBuffer(body))
	if err != nil {
		return nil, fmt.Errorf("ошибка создания запроса: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := h.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ошибка зарпоса: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("сервер вернул статус %d: %s", resp.StatusCode, string(b))
	}

	response, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("ошибка чтения тела ответа: %w", err)
	}

	var result models.Tokens
	if err := json.Unmarshal(response, &result); err != nil {
		return nil, fmt.Errorf("ошибка декодирования JSON: %w", err)
	}

	return &result, nil
}

func (h *authClient) ForgotPassword(email string) error {
	locInstance := "api/auth/forgot-password"

	type locStruct struct {
		Email string `json:"email,omitempty"`
	}

	bodySend := locStruct{Email: email}

	body, err := json.Marshal(&bodySend)
	if err != nil {
		return apperrors.NewInternal(err)
	}

	h.logger.Info("%s генерация запроса: %s", instance, locInstance)

	req, err := http.NewRequest(http.MethodPost, url+locInstance, bytes.NewBuffer(body))
	if err != nil {
		return apperrors.NewInternal(err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := h.client.Do(req)
	if err != nil {
		return apperrors.NewInternal(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		err := errors.New("Something went wrong")

		return apperrors.NewInternal(err)
	}

	return nil
}

func (h *authClient) ResetPassword(data *models.ResetPasswordRequest) error {
	locInstance := "api/auth/reset-password"

	body, err := json.Marshal(data)
	if err != nil {
		return apperrors.NewInternal(err)
	}

	h.logger.Info("%s генерация запроса: %s", instance, locInstance)

	req, err := http.NewRequest(http.MethodPost, url+locInstance, bytes.NewBuffer(body))
	if err != nil {
		return apperrors.NewInternal(err)
	}

	req.Header.Set("Content-Type", "application/json")

	h.logger.Info("%s отправка запроса: %s", instance, locInstance)
	resp, err := h.client.Do(req)
	if err != nil {
		return apperrors.NewInternal(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		buff, _ := io.ReadAll(resp.Body)

		return apperrors.NewBadRequest(string(buff))
	}

	return nil
}
