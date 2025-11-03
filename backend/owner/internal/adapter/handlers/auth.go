package handlers

import (
	"encoding/json"
	"net/http"
	"owner/internal/domain/models"
	"owner/internal/lib/utils"
)

func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	if http.MethodPost != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	body := models.User{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		h.logger.Error("error:", err)
		return
	}

	result, err := h.service.Login(body)
	if err != nil {
		h.logger.Error("error:", err)

		utils.ErrResponseInJson(w, err)
	}

	utils.ResponseInJson(w, 200, result)
}

func (h *Handler) Register(w http.ResponseWriter, r *http.Request) {
	if http.MethodPost != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	body := models.User{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		h.logger.Error("error:", err)
		return
	}

	result, err := h.service.Register(body)
	if err != nil {
		h.logger.Error("error:", err)

		utils.ErrResponseInJson(w, err)
	}

	utils.ResponseInJson(w, 200, result)
}

func (h *Handler) NewAccessToken(w http.ResponseWriter, r *http.Request) {
	if http.MethodPost != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	body := models.Tokens{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		h.logger.Error("error:", err)
		return
	}

	if body.RefreshToken == "" {
		http.Error(w, "refresh token is null", http.StatusBadRequest)
		return
	}

	result, err := h.service.NewAccessToken(body)
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)
		return
	}

	utils.ResponseInJson(w, 200, result)
}
