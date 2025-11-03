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

func (h *Handler) Router() *http.ServeMux {
	mux := http.NewServeMux()

	mux.Handle("/api/ai/video", AuthMiddleware(http.HandlerFunc(h.Generate))) // POST

	mux.Handle("/api/history/delete", AuthMiddleware(http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {}))) // DELETE
	mux.Handle("/api/history/get", AuthMiddleware(http.HandlerFunc(h.GetHistoryByID)))                                              // GET

	mux.Handle("/api/profile/get", AuthMiddleware(http.HandlerFunc(h.GetProfile)))               // GET
	mux.Handle("/api/profile/get/avatar", AuthMiddleware(http.HandlerFunc(h.GetProfile)))        // GET
	mux.Handle("/api/profile/update/avatar", AuthMiddleware(http.HandlerFunc(h.UpdateAvatarID))) // PUT
	mux.Handle("/api/profile/get/photo", AuthMiddleware(http.HandlerFunc(h.GetAvatar)))          // GET

	mux.Handle("/api/auth/register", http.HandlerFunc(h.Register))                                                               // POST
	mux.Handle("/api/auth/login", http.HandlerFunc(h.Login))                                                                     // POST
	mux.Handle("/api/auth/logout", AuthMiddleware(http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {}))) // POST
	mux.HandleFunc("/api/auth/refresh", h.NewAccessToken)

	return mux
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

	resp, err := h.service.Generate(body, int(userID))
	if err != nil {
		h.logger.Error("error:", err)
		utils.ErrResponseInJson(w, err)

		return
	}

	utils.ResponseInJson(w, 200, resp)
}
