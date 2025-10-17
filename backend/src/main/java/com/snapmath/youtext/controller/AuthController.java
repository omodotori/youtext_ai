package com.snapmath.youtext.controller;

import com.snapmath.youtext.dto.AuthResponse;
import com.snapmath.youtext.dto.GoogleAuthRequest;
import com.snapmath.youtext.model.UserProfile;
import com.snapmath.youtext.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private static final Duration TOKEN_TTL = Duration.ofHours(12);

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> signInWithGoogle(
            @Valid @RequestBody GoogleAuthRequest request
    ) {
        UserProfile profile = authService.signInWithGoogle(
                request.credential(),
                request.email(),
                request.displayName()
        );

        String token = authService.getActiveToken(profile.getId())
                .orElseThrow(() -> new IllegalStateException("Token creation failed"));

        return ResponseEntity.ok(
                new AuthResponse(
                        profile.getId(),
                        profile.getDisplayName(),
                        profile.getEmail(),
                        token,
                        TOKEN_TTL.toSeconds()
                )
        );
    }

    @PostMapping("/sign-out")
    public ResponseEntity<Void> signOut(@RequestParam("userId") String userId) {
        authService.signOut(userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public ResponseEntity<AuthResponse> currentUser(@RequestParam("userId") String userId) {
        Optional<UserProfile> profileOpt = authService.findById(userId);
        return profileOpt
                .flatMap(profile -> authService.getActiveToken(userId)
                        .map(token -> new AuthResponse(
                                profile.getId(),
                                profile.getDisplayName(),
                                profile.getEmail(),
                                token,
                                TOKEN_TTL.toSeconds())))
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
