package usecase

import (
	"owner/internal/domain/ports"
	"owner/internal/lib/logger"
)

type Service struct {
	ports.AIClient
	ports.HistoryClient
	ports.AuthClient
	ports.ProfileClient
	*logger.Logger
}

func NewService(
	aiClient ports.AIClient,
	historyClient ports.HistoryClient,
	authClient ports.AuthClient,
	profileClient ports.ProfileClient,
	logger *logger.Logger) ports.Services {
	return &Service{aiClient, historyClient, authClient, profileClient, logger}
}
