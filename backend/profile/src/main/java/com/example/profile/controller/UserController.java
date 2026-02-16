package com.example.profile.controller;
import com.example.profile.models.User;

import com.example.profile.dto.UserDto;
import com.example.profile.dto.UserUpdateDto;
import com.example.profile.services.UserService;

import java.util.List;

import java.util.stream.Collectors;

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
    )
    throws Exception {
        System.out.println("load user photo");
        return ResponseEntity.ok(new UserDto(service.updateAvatar(userId, file)));
    }

    @GetMapping("/{user_id}")
    public ResponseEntity<UserDto> getProfile(@PathVariable("user_id") Long userId) {
        UserDto dto = new UserDto(service.getUser(userId));
        System.out.println("DEBUG: user.isAdmin = " + dto.isAdmin());
        return ResponseEntity.ok(dto);
    }

    @GetMapping("/{user_id}/photo")
    public ResponseEntity<byte[]> getUserAvatar(@PathVariable("user_id") Long userId) throws Exception {
        System.out.println("get user photo");

        String avatarUrl = service.getUser(userId).getAvatarId();

        // Забираем файл из MinIO
        byte[] imageBytes = service.downloadAvatar(avatarUrl);
        String contentType = service.getAvatarContentType(avatarUrl);

        return ResponseEntity
                .ok()
                .header("Content-Type", contentType)
                .body(imageBytes);
    }

    @PutMapping("/update/{user_id}")
    public ResponseEntity<Void> updateProfile(@PathVariable("user_id") Long userId, @RequestBody UserUpdateDto userDto) {

        service.updateProfile(userId, userDto);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/all/users")
    public ResponseEntity<List<UserDto>> getAllUsers() {
        List<User> users = service.getAllUsers(); // берём всех из БД
        List<UserDto> dtoList = users.stream()
                .map(UserDto::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(dtoList);
    } 

}