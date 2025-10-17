package com.snapmath.youtext.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record GoogleAuthRequest(
        @NotBlank(message = "Client token is required") String credential,
        @Email(message = "Invalid email") @NotBlank(message = "Email is required") String email,
        @NotBlank(message = "Display name is required") String displayName
) {
}
