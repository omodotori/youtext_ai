package ports

import "owner/internal/domain/models"

type HistoryClient interface {
	AddHistory(data models.History) error
	GetHistoryByID(id string) (*[]models.HistoryResponse, error)
	GetHistoryCountByID(id string) (int, error)
	DeleteHistory(id string) error
	DeleteHistoryByID(id string) error
}
