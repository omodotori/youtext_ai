package main

import (
	"aiia/internal/config"
	"net/http"
	"time"

	"aiia/internal/handlers"
	"aiia/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

func main() {
	log := logrus.New()
	log.SetFormatter(&logrus.TextFormatter{FullTimestamp: true})

	cfg := config.MustLoad()

	svc := services.NewService(log, cfg.APIKey, cfg.YtdlpPath)

	r := gin.Default()
	r.POST("/api/generate", handlers.MakeGenerateHandler(svc, log))

	srv := &http.Server{
		Addr:         ":"+cfg.ServerPort,
		Handler:      r,
		ReadTimeout:  120 * time.Second,
		WriteTimeout: 600 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Infof("Starting server on %s", srv.Addr)
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("server error: %v", err)
	}
}
