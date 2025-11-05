package com.example.profile.dto;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

public class UserUpdateDto {
    private String email;
    private String nickname;

    public UserUpdateDto() {} // обязательно

    @JsonCreator
    public UserUpdateDto(
        @JsonProperty("email") String email,
        @JsonProperty("nickname") String nickname
    ) {
        this.email = email;
        this.nickname = nickname;
    }

    // геттеры и сеттеры
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
}
