package ports

import (
	"mime/multipart"
	"owner/internal/domain/models"
)

type ProfileClient interface {
	GetByID(id string) (*models.User, error)
	UpdateAvatar(id string, file multipart.File, ct string) error
	GetUserPhoto(userID int) ([]byte, string, error)
	UpdateDataUser(id string, data models.User) error
}
