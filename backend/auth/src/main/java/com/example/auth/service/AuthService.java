package com.example.auth.service;

import com.example.auth.dto.AuthRequest;
import com.example.auth.dto.RegRequest;

import com.example.auth.dto.AuthResponse;
import com.example.auth.model.RefreshToken;
import com.example.auth.model.User;
import com.example.auth.repository.RefreshTokenRepository;
import com.example.auth.repository.UserRepository;
import com.example.auth.security.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final long refreshExpirationMs;

    public AuthService(UserRepository userRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil,
                       org.springframework.core.env.Environment env) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.refreshExpirationMs = Long.parseLong(env.getProperty("jwt.refresh-expiration-ms"));
    }

    public void register(RegRequest req) {
        if (userRepository.findByEmail(req.getEmail()).isPresent()) {
            throw new RuntimeException("Email already taken");
        }
        if (userRepository.findByNickname(req.getNickname()).isPresent()) {
            throw new RuntimeException("Name already taken");
        }

        User user = new User();
        user.setEmail(req.getEmail());
        user.setNickname(req.getNickname());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        userRepository.save(user);
    }

    public AuthResponse login(AuthRequest req) {
        User user = userRepository.findByEmail(req.getEmail()).orElseThrow(() -> new RuntimeException("Invalid credentials"));
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        String accessToken = jwtUtil.generateAccessToken(user.getId());
        RefreshToken refreshToken = createRefreshToken(user.getId());

        return new AuthResponse(accessToken, refreshToken.getToken());
    }

    private RefreshToken createRefreshToken(Long userId) {
        RefreshToken rt = new RefreshToken();
        rt.setUserId(userId);
        rt.setToken(UUID.randomUUID().toString());
        rt.setExpiresAt(Instant.now().plusMillis(refreshExpirationMs));
        refreshTokenRepository.save(rt);
        return rt;
    }

    public AuthResponse refresh(String refreshTokenStr) {
        RefreshToken rt = refreshTokenRepository.findByToken(refreshTokenStr).orElseThrow(() -> new RuntimeException("Invalid refresh token"));
        if (rt.getExpiresAt().isBefore(Instant.now())) {
            refreshTokenRepository.delete(rt);
            throw new RuntimeException("Refresh token expired");
        }
        Long userId = rt.getUserId();
        refreshTokenRepository.delete(rt);
        RefreshToken newRt = createRefreshToken(userId);
        String accessToken = jwtUtil.generateAccessToken(userId);
        return new AuthResponse(accessToken, newRt.getToken());
    }

    @Transactional
    public void logout(Long userId) {
        refreshTokenRepository.deleteByUserId(userId);
    }
}
