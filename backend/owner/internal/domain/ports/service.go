package ports

import "owner/internal/domain/models"

type Services interface {
	Generate(data models.GenerateReq, userID int) (*models.Summary, error)
	Login(data models.User) (*models.Tokens, error)
	Register(data models.User) (*models.RegisterResp, error)
	GetHistoryByID(id int) (*[]models.Summary, error)
	GetProfileByID(id int) (*models.User, error)
	UpdateAvatar(id int) (*models.User, error)
	NewAccessToken(data models.Tokens) (*models.Tokens, error)
	GetUserPhoto(userID int) ([]byte, string, error)
}
