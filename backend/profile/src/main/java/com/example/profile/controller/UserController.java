package com.example.profile.controller;

import com.example.profile.dto.UserDto;
import com.example.profile.services.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/profile")
public class UserController {

    private final UserService service;

    public UserController(UserService service) {
        this.service = service;
    }

    @PutMapping("/{user_id}/photo")
    public ResponseEntity<UserDto> uploadAvatar(
            @PathVariable("user_id") Long userId,
            @RequestParam("file") MultipartFile file
    ) throws Exception {
        return ResponseEntity.ok(new UserDto(service.updateAvatar(userId, file)));
    }

    @GetMapping("/{user_id}")
    public ResponseEntity<UserDto> getProfile(@PathVariable("user_id") Long userId) {
        return ResponseEntity.ok(new UserDto(service.getUser(userId)));
    }

    @GetMapping("/{user_id}/photo")
    public ResponseEntity<byte[]> getUserAvatar(@PathVariable("user_id") Long userId) throws Exception {
        String avatarUrl = service.getAvatarUrl(userId);

        // Забираем файл из MinIO
        byte[] imageBytes = service.downloadAvatar(avatarUrl);
        String contentType = service.getAvatarContentType(avatarUrl);

        return ResponseEntity
                .ok()
                .header("Content-Type", contentType)
                .body(imageBytes);
    }

}