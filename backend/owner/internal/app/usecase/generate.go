package usecase

import (
	"fmt"
	"log/slog"
	"owner/internal/domain/models"
)

func (s *Service) Generate(data models.GenerateReq, userID int) (*models.Summary, error) {
	resp, err := s.AIClient.Generate(data)
	if err != nil {
		return nil, err
	}
	slog.Info("text has been generated")

	fmt.Println(userID)
	resp.UserID = userID
	fmt.Println(resp)

	if err := s.HistoryClient.AddHistory(resp); err != nil {
		return nil, err
	}
	slog.Info("text has been added to history")

	return &resp, nil
}
