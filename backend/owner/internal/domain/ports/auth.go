package ports

import "owner/internal/domain/models"

type AuthClient interface {
	Register(data models.User) (*models.RegisterResp, error)
	Login(data models.User) (*models.Tokens, error)
	NewAccessToken(refreshToken *models.Tokens) (*models.Tokens, error)
}
