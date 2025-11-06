package usecase

import (
	"owner/internal/domain/models"
	"strconv"
)

func (s *Service) GetHistoryByID(id int) (*[]models.Summary, error) {
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
