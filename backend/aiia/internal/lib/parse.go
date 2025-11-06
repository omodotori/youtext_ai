package lib

import "encoding/json"

type Summary struct {
	Text      string `json:"text"`
	Link      string `json:"link"`
	Timecodes []struct {
		Timecode     string `json:"timecode"`
		Descriptions string `json:"descriptions"`
	} `json:"timecodes"`
}

func ParseJSON(jsonStr string) (*Summary, error) {
	var summary Summary
	if err := json.Unmarshal([]byte(jsonStr), &summary); err != nil {
		return nil, err
	}
	return &summary, nil
}
