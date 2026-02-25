package handlers

import (
	"encoding/json"
	"net/http"
	"owner/internal/domain/models"
	"owner/internal/domain/ports"
	"owner/internal/lib/logger"
	"owner/internal/lib/utils"
)

type Handler struct {
	service ports.Services
	logger  *logger.Logger
}

func (h *Handler) Router() http.Handler {
	mux := http.NewServeMux()

	mux.Handle("/api/admin/users", AuthMiddleware(http.HandlerFunc(h.GetAllUsers))) // GET

	mux.Handle("/api/ai/video", AuthMiddleware(http.HandlerFunc(h.Generate))) // POST
	mux.Handle("/api/ai/video/anon", http.HandlerFunc(h.AnonGenerate))        // POST

	mux.Handle("/api/history/delete", AuthMiddleware(http.HandlerFunc(h.DeleteHistory)))                  // DELETE
	mux.Handle("/api/history/get/count", AuthMiddleware(http.HandlerFunc(h.GetHistoryCountByID)))         // GET
	mux.Handle("/api/history/get", AuthMiddleware(http.HandlerFunc(h.GetHistoryByID)))                    // GET
	mux.Handle("/api/history/delete/{history_id}", AuthMiddleware(http.HandlerFunc(h.DeleteHistoryByID))) // DELETE

	mux.Handle("/api/profile/get", AuthMiddleware(http.HandlerFunc(h.GetProfile))) // GET
	// mux.Handle("/api/profile/get/avatar", AuthMiddleware(http.HandlerFunc(h.GetProfile)))        // GET
	mux.Handle("/api/profile/update/avatar", AuthMiddleware(http.HandlerFunc(h.UpdateAvatarID))) // PUT
	mux.Handle("/api/profile/get/photo", AuthMiddleware(http.HandlerFunc(h.GetAvatar)))          // GET
	mux.Handle("/api/profile/update/user", AuthMiddleware(http.HandlerFunc(h.UpdateUserData)))   // PUT

	mux.Handle("/api/auth/register", http.HandlerFunc(h.Register))             // POST
	mux.Handle("/api/auth/login", http.HandlerFunc(h.Login))                   // POST
	mux.Handle("/api/auth/logout", AuthMiddleware(http.HandlerFunc(h.Logout))) // POST
	mux.HandleFunc("/api/auth/refresh", h.NewAccessToken)
	mux.HandleFunc("/api/auth/forgot-password", h.ForgotPassword) // POST (fotget password, enter email and return code)
	mux.HandleFunc("/api/auth/reset-password", h.ResetPassword)   // POST (enter code and set a new password)

	return CorsMiddleware(mux)
}

func NewHandler(s ports.Services, logger *logger.Logger) *Handler {
	return &Handler{service: s, logger: logger}
}

func (h *Handler) Generate(w http.ResponseWriter, r *http.Request) {
	if http.MethodPost != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID, ok := r.Context().Value(UserIDKey).(int64)
	if !ok {
		http.Error(w, "user id not found in context", http.StatusUnauthorized)
		return
	}

	body := models.GenerateReq{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		h.logger.Error("error:", err)
		return
	}

	history, err := h.service.Generate(body, int(userID))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	resp := models.HistoryResponse{
		ID:         history.ID,
		UserID:     history.UserID,
		VideoTitle: history.VideoTitle,
		Link:       history.Link,
		CreatedAt:  history.CreatedAt,
		Summary:    history.Summary,
		Transcript: history.Transcript,
		Timecodes:  history.Timecodes,
	}

	for _, r := range history.Highlights {
		resp.Highlights = append(resp.Highlights, r.Highlight)
	}

	utils.ResponseInJson(w, 200, resp)
}

func (h *Handler) AnonGenerate(w http.ResponseWriter, r *http.Request) {
	if http.MethodPost != r.Method {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	body := models.GenerateReq{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		h.logger.Error("error:", err)
		return
	}

	resp, err := h.service.AnonGenerate(body)
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, resp)
}
