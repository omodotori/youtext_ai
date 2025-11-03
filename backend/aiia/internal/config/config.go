package config

import (
	"fmt"
	"log/slog"
	"os"
)

type Config struct {
	ServerPort string
	APIKey     string
	YtdlpPath  string
}

func MustLoad() *Config {
	cfg := Config{}

	cfg.ServerPort = os.Getenv("AIIA_PORT")
	cfg.APIKey = os.Getenv("OPENAI_API_KEY")
	cfg.YtdlpPath = os.Getenv("YTDLP_PATH")

	if cfg.YtdlpPath == "" || cfg.APIKey == "" || cfg.ServerPort == "" {
		slog.Info("You need to set AIIA_PORT and OPENAI_API_KEY")
		panic("You need to set values")
	}

	fmt.Println(cfg)

	return &cfg
}
