package handlers

import (
	"net/http"
	"owner/internal/lib/utils"
)

func (h *Handler) GetHistoryByID(w http.ResponseWriter, r *http.Request) {
	if http.MethodGet != r.Method {
		http.Error(w, "POST method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	resp, err := h.service.GetHistoryByID(int(id))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, resp)
}

func (h *Handler) GetHistoryCountByID(w http.ResponseWriter, r *http.Request) {
	if http.MethodGet != r.Method {
		http.Error(w, "POST method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	resp, err := h.service.GetHistoryCountByID(int(id))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, map[string]int{
		"count": resp,
	})
}

func (h *Handler) DeleteHistory(w http.ResponseWriter, r *http.Request) {
	if http.MethodDelete != r.Method {
		http.Error(w, "POST method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	err := h.service.DeleteHistory(int(id))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, map[string]string{
		"message": "History has been deleted",
	})
}

func (h *Handler) DeleteHistoryByID(w http.ResponseWriter, r *http.Request) {
	if http.MethodDelete != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	_, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	historyID := r.PathValue("history_id")

	if historyID == "" {
		h.logger.Error("error: history id is null")
		http.Error(w, "ID is null", http.StatusBadRequest)
		return
	}

	err := h.service.DeleteHistoryByID(historyID)
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, map[string]string{
		"message": "History has been deleted",
	})
}
