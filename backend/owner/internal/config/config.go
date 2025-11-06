package config

import (
	"github.com/joho/godotenv"
	"log/slog"
	"os"
	"owner/internal/domain/models"
)

var JWTKey []byte

func MustLoad() *models.DBConfig {
	cfg := &models.DBConfig{}

	wd, _ := os.Getwd()
	slog.Info("Working dir", slog.String("path", wd))

	if err := godotenv.Load("../.env"); err != nil {
		slog.Warn(".env not found, using system env")
		panic(".env not found, using system env")
	}

	secret := getEnv("JWTKey")

	cfg.Database = getEnv("DB_NAME")
	cfg.User = getEnv("DB_USER")
	cfg.Password = getEnv("DB_PASS")
	cfg.Host = getEnv("DB_HOST")
	cfg.Port = getEnv("DB_PORT")

	JWTKey = []byte(secret)

	return cfg
}

func getEnv(key string) string {
	val := os.Getenv(key)
	if val == "" {
		panic("Environment variable " + key + " not set")
	}
	return val
}
