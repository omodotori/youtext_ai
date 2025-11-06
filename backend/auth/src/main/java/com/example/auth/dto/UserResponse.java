package com.example.auth.dto;

public class UserResponse {
    private Long id;
    private String nickname;

    public UserResponse(Long id, String nickname, String avatarId) {
        this.id = id;
        this.nickname = nickname;
    }

    public Long getId() { return id; }
    public String getNickname() { return nickname; }
}
