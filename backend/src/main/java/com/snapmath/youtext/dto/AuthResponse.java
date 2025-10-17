package com.snapmath.youtext.dto;

public record AuthResponse(
        String userId,
        String displayName,
        String email,
        String accessToken,
        long expiresInSeconds
) {
}
