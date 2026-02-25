package ports

import "owner/internal/domain/models"

type AIClient interface {
	Generate(data models.GenerateReq) (models.History, error)
}
