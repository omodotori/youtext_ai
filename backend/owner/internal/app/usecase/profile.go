package usecase

import (
	"mime/multipart"
	"owner/internal/domain/models"
	"strconv"
)

func (s *Service) GetProfileByID(id int) (*models.User, error) {
	newID := strconv.Itoa(id)

	return s.ProfileClient.GetByID(newID)
}

func (s *Service) UpdateAvatar(id int, file multipart.File, ct string) error {
	newID := strconv.Itoa(id)

	return s.ProfileClient.UpdateAvatar(newID, file, ct)
}

func (s *Service) GetUserPhoto(userID int) ([]byte, string, error) {
	return s.ProfileClient.GetUserPhoto(userID)
}

func (s *Service) UpdateUserData(id int, data models.User) error {
	newID := strconv.Itoa(id)

	return s.ProfileClient.UpdateDataUser(newID, data)
}

func (s *Service) GetAllUsers() (*[]models.User, error) {
	return s.ProfileClient.GetAllUsers()
}
