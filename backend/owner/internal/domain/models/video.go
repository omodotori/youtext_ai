package models

import "time"

type Summary struct {
	ID         int       `json:"id,omitempty"`
	UserID     int       `json:"user_id"`
	VideoTitle string    `json:"video_title"`
	Link       string    `json:"link"`
	CreatedAt  time.Time `json:"created_at"`
	Text       string    `json:"text"`
	Transcript string    `json:"transcript"`
	Highlights []string  `json:"highlights"`
	Timecodes  []struct {
		Timecode     string `json:"timecode"`
		Descriptions string `json:"descriptions"`
	} `json:"timecodes"`
}
