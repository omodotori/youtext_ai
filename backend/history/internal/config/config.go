package config

import (
	"fmt"
	"history/internal/models"
	"os"
)

func LoadConfig() models.Config {
	cfg := models.Config{}

	cfg.DBName = os.Getenv("DB_NAME")
	cfg.DBUser = os.Getenv("DB_USER")
	cfg.DBPassword = os.Getenv("DB_PASS")
	cfg.DBHost = os.Getenv("DB_HOST")
	cfg.DBPort = os.Getenv("DB_PORT")
	cfg.Port = os.Getenv("HISTORY_PORT")

	if cfg.DBPort == "" || cfg.DBName == "" || cfg.DBUser == "" || cfg.DBHost == "" || cfg.DBPassword == "" || cfg.Port == "" {
		panic("env is empty")
	}

	fmt.Println(cfg)

	return cfg
}
