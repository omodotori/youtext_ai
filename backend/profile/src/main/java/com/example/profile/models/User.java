package com.example.profile.models;

import jakarta.persistence.*;

@Entity
@Table(name = "\"user\"")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "avatar_id", unique = true)
    private String avatarId;

    @Column(unique = true)
    private String nickname;

    private String password;

    @Column(unique = true)
    private String email;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getAvatarId() { return avatarId; }
    public void setAvatarId(String avatarId) { this.avatarId = avatarId; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}