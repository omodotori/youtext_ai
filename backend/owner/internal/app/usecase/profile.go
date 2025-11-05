package usecase

import (
	"owner/internal/domain/models"
	"strconv"
)

func (s *Service) GetProfileByID(id int) (*models.User, error) {
	newID := strconv.Itoa(id)

	return s.ProfileClient.GetByID(newID)
}

func (s *Service) UpdateAvatar(id int) (*models.User, error) {
	newID := strconv.Itoa(id)

	return s.ProfileClient.UpdateAvatar(newID)
}

func (s *Service) GetUserPhoto(userID int) ([]byte, string, error) {
	return s.ProfileClient.GetUserPhoto(userID)
}

func (s *Service) UpdateUserData(id int, data models.User) error {
	newID := strconv.Itoa(id)

	return s.ProfileClient.UpdateDataUser(newID, data)
}
