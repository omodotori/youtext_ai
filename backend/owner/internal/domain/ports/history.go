package ports

import "owner/internal/domain/models"

type HistoryClient interface {
	AddHistory(data models.Summary) error
	GetHistoryByID(id string) (*[]models.Summary, error)
}
