package usecase

import (
	"owner/internal/domain/models"
	"owner/internal/lib/utils"
	"strconv"
)

func (s *Service) Login(data models.User) (*models.Tokens, error) {

	return s.AuthClient.Login(data)
}

func (s *Service) Register(data models.User) (*models.RegisterResp, error) {
	if err := utils.ValidateReg(data); err != nil {
		return nil, err
	}

	return s.AuthClient.Register(data)
}

func (s *Service) NewAccessToken(data models.Tokens) (*models.Tokens, error) {
	return s.AuthClient.NewAccessToken(&data)
}

func (s *Service) Logout(id int) error {
	newID := strconv.Itoa(id)

	return s.AuthClient.Logout(newID)
}

// deda
