package handlers

import (
	"encoding/json"
	"net/http"
	"owner/internal/domain/models"
	"owner/internal/lib/utils"
)

func (h *Handler) GetProfile(w http.ResponseWriter, r *http.Request) {
	if http.MethodGet != r.Method {
		http.Error(w, "POST method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	resp, err := h.service.GetProfileByID(int(id))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, resp)
}

func (h *Handler) UpdateAvatarID(w http.ResponseWriter, r *http.Request) {
	if http.MethodPut != r.Method {
		http.Error(w, "PUT method not allowed", http.StatusMethodNotAllowed)
	}

	id, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	resp, err := h.service.GetProfileByID(int(id))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, resp)
}

func (h *Handler) GetAvatar(w http.ResponseWriter, r *http.Request) {
	if http.MethodGet != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	resp, contentType, err := h.service.GetUserPhoto(int(id))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)
		return
	}

	w.Header().Set("Content-Type", contentType)
	w.WriteHeader(http.StatusOK)
	w.Write(resp)
}

func (h *Handler) UpdateUserData(w http.ResponseWriter, r *http.Request) {
	if http.MethodPost != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	body := models.User{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		h.logger.Error("error:", err)
		return
	}

	err = h.service.UpdateUserData(int(id), body)
	if err != nil {
		h.logger.Error("error:", err)

		utils.ErrResponseInJson(w, err)
		return
	}

	utils.ResponseInJson(w, 200, map[string]string{
		"message": "User updated",
	})
}
