package com.example.auth.service;

import com.example.auth.dto.*;
import com.example.auth.model.*;
import com.example.auth.repository.*;
import com.example.auth.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.env.Environment;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class AuthServiceTest {

    private UserRepository userRepository = mock(UserRepository.class);
    private RefreshTokenRepository refreshTokenRepository = mock(RefreshTokenRepository.class);
    private PasswordResetTokenRepository tokenRepository = mock(PasswordResetTokenRepository.class);
    private PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
    private JavaMailSender mailSender = mock(JavaMailSender.class);
    private Environment env = mock(Environment.class);
    
    private JwtUtil jwtUtil = new JwtUtil("dummySecretKey12345678901234567890", 3600000L) {
        @Override
        public String generateAccessToken(Long userId) {
            return "fake-jwt-token";
        }
    };

    private AuthService authService;

    @BeforeEach
    void setUp() {
        lenient().when(env.getProperty("jwt.refresh-expiration-ms")).thenReturn("86400000");
        authService = new AuthService(userRepository, refreshTokenRepository, tokenRepository, passwordEncoder, jwtUtil, mailSender, env);
    }

    @Test
    void register_Success() {
        RegRequest req = new RegRequest();
        req.setEmail("test@mail.com"); req.setNickname("u"); req.setPassword("p");
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        when(userRepository.findByNickname(anyString())).thenReturn(Optional.empty());
        when(passwordEncoder.encode(anyString())).thenReturn("hash");
        authService.register(req);
        verify(userRepository).save(any(User.class));
    }

    @Test
    void register_EmailTaken() {
        RegRequest req = new RegRequest();
        req.setEmail("taken@mail.com");
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(new User()));
        assertThrows(RuntimeException.class, () -> authService.register(req));
    }

    @Test
    void register_NicknameTaken() {
        RegRequest req = new RegRequest();
        req.setNickname("taken");
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        when(userRepository.findByNickname(anyString())).thenReturn(Optional.of(new User()));
        assertThrows(RuntimeException.class, () -> authService.register(req));
    }

    @Test
    void login_Success() {
        AuthRequest req = new AuthRequest();
        req.setEmail("a@b.com"); req.setPassword("p");
        User user = new User(); user.setId(1L); user.setPassword("hash");
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        doReturn(true).when(passwordEncoder).matches(anyString(), anyString());
        AuthResponse res = authService.login(req);
        assertEquals("fake-jwt-token", res.getAccessToken());
        verify(refreshTokenRepository).save(any());
    }

    @Test
    void login_InvalidUser() {
        AuthRequest req = new AuthRequest();
        req.setEmail("none@b.com");
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        assertThrows(RuntimeException.class, () -> authService.login(req));
    }

    @Test
    void refresh_Success() {
        RefreshToken rt = new RefreshToken();
        rt.setUserId(1L); rt.setExpiresAt(Instant.now().plusSeconds(60));
        when(refreshTokenRepository.findByToken(anyString())).thenReturn(Optional.of(rt));
        AuthResponse res = authService.refresh("token");
        assertEquals("fake-jwt-token", res.getAccessToken());
    }

    @Test
    void refresh_Expired() {
        RefreshToken rt = new RefreshToken();
        rt.setExpiresAt(Instant.now().minusSeconds(60));
        when(refreshTokenRepository.findByToken(anyString())).thenReturn(Optional.of(rt));
        assertThrows(RuntimeException.class, () -> authService.refresh("t"));
    }

    @Test
    void logout_Success() {
        authService.logout(1L);
        verify(refreshTokenRepository).deleteByUserId(1L);
    }

    @Test
    void forgotPassword_Success() {
        User user = new User();
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(tokenRepository.findByUser(any())).thenReturn(Optional.empty());
        authService.forgotPassword("a@b.com");
        verify(mailSender).send(any(SimpleMailMessage.class));
    }

    @Test
    void resetPassword_Success() {
        User user = new User();
        PasswordResetToken token = new PasswordResetToken();
        token.setCode("1"); token.setExpiryDate(LocalDateTime.now().plusMinutes(5));
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(tokenRepository.findByUser(any())).thenReturn(Optional.of(token));
        when(passwordEncoder.encode(anyString())).thenReturn("new-hash");
        authService.resetPassword("a@b.com", "1", "pass");
        verify(userRepository).save(user);
    }
}