package usecase

import (
	"log/slog"
	"owner/internal/domain/models"
	"time"
)

func (s *Service) Generate(data models.GenerateReq, userID int) (*models.History, error) {
	resp, err := s.AIClient.Generate(data)
	if err != nil {
		return nil, err
	}
	slog.Info("text has been generated")

	resp.UserID = userID
	resp.Link = data.URL
	resp.CreatedAt = time.Now()

	if err := s.HistoryClient.AddHistory(resp); err != nil {
		return nil, err
	}
	slog.Info("text has been added to history")

	return &resp, nil
}

func (s *Service) AnonGenerate(data models.GenerateReq) (*models.History, error) {
	resp, err := s.AIClient.Generate(data)
	if err != nil {
		return nil, err
	}

	resp.Link = data.URL
	resp.CreatedAt = time.Now()
	// resp.VideoTitle = "Title"
	slog.Info("text has been generated")

	return &resp, nil
}

// Added log
