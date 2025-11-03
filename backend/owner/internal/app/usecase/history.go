package usecase

import (
	"owner/internal/domain/models"
	"strconv"
)

func (s *Service) GetHistoryByID(id int) (*[]models.Summary, error) {
	newID := strconv.Itoa(id)

	return s.HistoryClient.GetHistoryByID(newID)
}
