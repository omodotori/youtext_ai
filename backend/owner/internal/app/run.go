package app

import (
	"context"
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
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

func Run() {
	config.MustLoad()

	//db := database.ConnectToDB(cfg)

	logg := logger.New("owner")

	//go clearTokens(db, logg)

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

func clearTokens(db *pgxpool.Pool, logger *logger.Logger) {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()
	query := `DELETE FROM refresh_token WHERE expires_at <= NOW();`

	for {
		select {
		case <-ticker.C:
			ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)

			_, err := db.Exec(ctx, query)
			cancel()

			if err != nil {
				logger.Error(err.Error())
				continue
			} else {
				logger.Info("Tokens cleared")
			}
		}
	}
}
