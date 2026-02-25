package service

import (
	"context"
	"history/internal/models"
	"history/internal/repository"
)

type HistoryService interface {
	CreateHistory(ctx context.Context, h *models.History) error
	GetAllHistories(ctx context.Context) ([]models.History, error)
	GetHistoriesByUser(ctx context.Context, userID int) ([]models.History, error)
	DeleteUserHistories(ctx context.Context, userID int) error
	GetHistoryCount(ctx context.Context, userID int) (int64, error)
	DeleteHistoryByID(ctx context.Context, id int64) (bool, error)
}

type historyService struct {
	repo repository.HistoryRepository
}

func NewHistoryService(repo repository.HistoryRepository) HistoryService {
	return &historyService{repo: repo}
}

func (s *historyService) CreateHistory(ctx context.Context, h *models.History) error {
	return s.repo.Save(ctx, h)
}

func (s *historyService) GetAllHistories(ctx context.Context) ([]models.History, error) {
	return s.repo.FindAll(ctx)
}

func (s *historyService) GetHistoriesByUser(ctx context.Context, userID int) ([]models.History, error) {
	return s.repo.FindByUserID(ctx, userID)
}

func (s *historyService) DeleteUserHistories(ctx context.Context, userID int) error {
	return s.repo.DeleteByUserID(ctx, userID)
}

func (s *historyService) GetHistoryCount(ctx context.Context, userID int) (int64, error) {
	return s.repo.CountByUserID(ctx, userID)
}

func (s *historyService) DeleteHistoryByID(ctx context.Context, id int64) (bool, error) {
	return s.repo.DeleteByID(ctx, id)
}
