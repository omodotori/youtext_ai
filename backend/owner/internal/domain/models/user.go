package models

type User struct {
	ID       int    `json:"user_id,omitempty"`
	Email    string `json:"email,omitempty"`
	Nickname string `json:"nickname,omitempty"`
	Password string `json:"password,omitempty"`
	AvatarID string `json:"avatar_id,omitempty"`
}

type RegisterResp struct {
	Status string `json:"status"`
}
