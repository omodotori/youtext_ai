package handlers

import "net/http"

func (h *HistoryHandler) Router() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("POST /api/history", h.Create)
	mux.HandleFunc("GET /api/history", h.GetAll)
	mux.HandleFunc("GET /api/history/{user_id}", h.GetByUserID)
	mux.HandleFunc("DELETE /api/history/user/{user_id}", h.DeleteAllByUserID)
	mux.HandleFunc("GET /api/history/user/{user_id}/count", h.GetHistoryCount)
	mux.HandleFunc("DELETE /api/history/{id}", h.DeleteByID)

	return CorsMiddleware(mux)
}
