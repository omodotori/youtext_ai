package models

type Summary struct {
	UserID    int    `json:"user_id"`
	Text      string `json:"text"`
	Link      string `json:"link"`
	Timecodes []struct {
		Timecode     string `json:"timecode"`
		Descriptions string `json:"descriptions"`
	} `json:"timecodes"`
}
