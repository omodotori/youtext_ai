package ports

import "owner/internal/domain/models"

type ProfileClient interface {
	GetByID(id string) (*models.User, error)
	UpdateAvatar(id string) (*models.User, error)
	GetUserPhoto(userID int) ([]byte, string, error)
}
