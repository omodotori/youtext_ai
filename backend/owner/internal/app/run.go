package app

import (
	"log/slog"
	"net/http"
	"owner/internal/adapter/ai"
	"owner/internal/adapter/auth"
	"owner/internal/adapter/handlers"
	"owner/internal/adapter/history"
	"owner/internal/adapter/profile"
	"owner/internal/app/usecase"
	"owner/internal/config"
	"owner/internal/lib/logger"
)

func Run() {
	config.MustLoad()

	logg := logger.New("owner")

	aiClient := ai.NewAIClient(logg)
	historyClient := history.NewHistory(logg)
	authClient := auth.NewAuth(logg)
	profileClient := profile.NewProfile(logg)

	services := usecase.NewService(aiClient, historyClient, authClient, profileClient, logg)

	handl := handlers.NewHandler(services, logg)

	mux := handl.Router()

	slog.Info("Server launched!")

	if err := http.ListenAndServe("0.0.0.0:8000", mux); err != nil {
		panic(err)
	}
}
