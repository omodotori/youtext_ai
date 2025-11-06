package com.example.auth.controller;

import com.example.auth.dto.UserResponse;
import com.example.auth.model.User;
import com.example.auth.repository.UserRepository;
import com.example.auth.security.JwtUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.PostConstruct;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    public UserController(UserRepository userRepository, JwtUtil jwtUtil, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
    }

    @PostConstruct
    public void initAdmin() {
        userRepository.findByEmail("admingoat@gmail.com").ifPresentOrElse(
                user -> {},
                () -> {
                    User admin = new User();
                    admin.setNickname("adminGoat");
                    admin.setEmail("admingoat@gmail.com");
                    admin.setPassword(passwordEncoder.encode("12345678"));
                    admin.setAdmin(true);
                    userRepository.save(admin);
                    System.out.println("✅ Админ создан: admingoat@gmail.com / 12345678");
                }
        );
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body("No token");
        }

        String token = authHeader.substring(7);
        if (!jwtUtil.validateToken(token)) return ResponseEntity.status(401).body("Invalid token");

        Long userId = jwtUtil.extractUserId(token);
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));

        user.setPassword(null);
        return ResponseEntity.ok(new UserResponse(user.getId(), user.getNickname(), user.getAvatarId()));
    }
}
