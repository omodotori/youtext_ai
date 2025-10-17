package com.snapmath.youtext.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record CreateTranscriptionRequest(
        @NotBlank(message = "Video title is required") String videoTitle,
        @NotBlank(message = "Video URL is required") String videoUrl,
        @NotBlank(message = "Summary is required") String summary,
        @NotEmpty(message = "Highlights must not be empty") List<@NotBlank(message = "Highlight must not be blank") String> highlights,
        @NotBlank(message = "Transcript body is required") String transcript,
        @NotEmpty(message = "At least one line is required") List<TranscriptLineDto> lines
) {
}
