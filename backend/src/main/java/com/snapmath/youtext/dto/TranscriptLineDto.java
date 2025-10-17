package com.snapmath.youtext.dto;

import jakarta.validation.constraints.NotBlank;

public record TranscriptLineDto(
        @NotBlank(message = "Timestamp is required") String timestamp,
        @NotBlank(message = "Text must not be empty") String text
) {
}
