package main

import (
	"context"
	"database/sql"
	"history/internal/config"
	"history/internal/handlers"
	"history/internal/repository"
	"history/internal/service"
	"log/slog"
	"net/http"
	"time"
)

func main() {
	cfg := config.LoadConfig()

	db, err := config.ConnDb(&cfg)
	if err != nil {
		panic(err)
	}

	repo := repository.NewHistoryRepository(db)
	service := service.NewHistoryService(repo)
	handler := handlers.NewHistoryHandler(service)

	svc := handler.Router()

	go clearTokens(db)

	slog.Info("Server launched!")

	if err := http.ListenAndServe(":"+cfg.Port, svc); err != nil {
		panic(err)
	}
}

func clearTokens(db *sql.DB) {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()
	query := `DELETE FROM refresh_token WHERE expires_at <= NOW();`

	for {
		select {
		case <-ticker.C:
			ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)

			_, err := db.ExecContext(ctx, query)
			cancel()

			if err != nil {
				slog.Error(err.Error())
				continue
			} else {
				slog.Info("Tokens cleared")
			}
		}
	}
}
