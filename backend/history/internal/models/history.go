package models

import "time"

type History struct {
	ID         int64       `json:"id"`
	UserID     int         `json:"user_id"`
	VideoTitle string      `json:"video_title"`
	Link       string      `json:"link"`
	CreatedAt  time.Time   `json:"created_at"`
	Summary    string      `json:"summary"`
	Transcript string      `json:"transcript"`
	Highlights []Highlight `json:"highlights"`
	Timecodes  []Timecode  `json:"timecodes"`
}

type Highlight struct {
	ID        int64  `json:"id"`
	Highlight string `json:"highlight"`
	HistoryID int64  `json:"history_id"`
}

type Timecode struct {
	ID           int64  `json:"id"`
	Timecode     string `json:"timecode"`
	Descriptions string `json:"descriptions"`
	HistoryID    int64  `json:"history_id"`
}

type User struct {
	ID       int64  `json:"id"`
	AvatarID string `json:"avatar_id"`
	Email    string `json:"email"`
}
