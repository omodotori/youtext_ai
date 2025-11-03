package com.example.profile.dto;

import com.example.profile.models.User;

public class UserDto {
    private Long id;
    private String avatarId;
    private String nickname;

    public UserDto(User user) {
        this.id = user.getId();
        this.avatarId = user.getAvatarId();
        this.nickname = user.getNickname();
    }

    public Long getId() { return id; }
    public String getAvatarId() { return avatarId; }
    public String getNickname() { return nickname; }
}
