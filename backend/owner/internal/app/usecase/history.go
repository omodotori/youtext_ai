package usecase

import (
	"owner/internal/domain/models"
	"strconv"
)

func (s *Service) GetHistoryByID(id int) (*[]models.HistoryResponse, error) {
	newID := strconv.Itoa(id)

	return s.HistoryClient.GetHistoryByID(newID)
}

func (s *Service) GetHistoryCountByID(id int) (int, error) {
	newID := strconv.Itoa(id)

	return s.HistoryClient.GetHistoryCountByID(newID)
}

func (s *Service) DeleteHistory(id int) error {
	newID := strconv.Itoa(id)

	return s.HistoryClient.DeleteHistory(newID)
}

func (s *Service) DeleteHistoryByID(historyID string) error {
	return s.HistoryClient.DeleteHistoryByID(historyID)
}
