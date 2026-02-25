package handlers

import (
	"encoding/json"
	"fmt"
	"history/internal/models"
	"history/internal/service"
	"net/http"
	"strconv"
)

type HistoryHandler struct {
	service service.HistoryService
}

func NewHistoryHandler(service service.HistoryService) *HistoryHandler {
	return &HistoryHandler{service: service}
}

func (h *HistoryHandler) Create(w http.ResponseWriter, r *http.Request) {
	var hist models.History
	if err := json.NewDecoder(r.Body).Decode(&hist); err != nil {
		writeJSONError(w, http.StatusBadRequest, "Invalid input")
		return
	}

	fmt.Println(hist)

	if err := h.service.CreateHistory(r.Context(), &hist); err != nil {
		writeJSONError(w, http.StatusInternalServerError, "Failed to save history")
		return
	}
	writeJSON(w, http.StatusCreated, hist)
}

func (h *HistoryHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	histories, err := h.service.GetAllHistories(r.Context())
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, "Database error")
		return
	}
	writeJSON(w, http.StatusOK, histories)
}

func (h *HistoryHandler) GetByUserID(w http.ResponseWriter, r *http.Request) {
	userID, err := strconv.Atoi(r.PathValue("user_id"))
	if err != nil {
		writeJSONError(w, http.StatusBadRequest, "Invalid user_id")
		return
	}

	histories, err := h.service.GetHistoriesByUser(r.Context(), userID)
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, "Database error")
		return
	}
	writeJSON(w, http.StatusOK, histories)
}

func (h *HistoryHandler) DeleteAllByUserID(w http.ResponseWriter, r *http.Request) {
	userID, err := strconv.Atoi(r.PathValue("user_id"))
	if err != nil {
		writeJSONError(w, http.StatusBadRequest, "Invalid user_id")
		return
	}

	if err := h.service.DeleteUserHistories(r.Context(), userID); err != nil {
		writeJSONError(w, http.StatusInternalServerError, "Database error")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *HistoryHandler) GetHistoryCount(w http.ResponseWriter, r *http.Request) {
	userID, err := strconv.Atoi(r.PathValue("user_id"))
	if err != nil {
		writeJSONError(w, http.StatusBadRequest, "Invalid user_id")
		return
	}

	count, err := h.service.GetHistoryCount(r.Context(), userID)
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, "Database error")
		return
	}
	writeJSON(w, http.StatusOK, map[string]int64{"count": count})
}

func (h *HistoryHandler) DeleteByID(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		writeJSONError(w, http.StatusBadRequest, "Invalid id")
		return
	}

	deleted, err := h.service.DeleteHistoryByID(r.Context(), id)
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, "Database error")
		return
	}
	if !deleted {
		writeJSONError(w, http.StatusNotFound, "Not found")
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "Deleted"})
}

// Утилиты для JSON
func writeJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

func writeJSONError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}
