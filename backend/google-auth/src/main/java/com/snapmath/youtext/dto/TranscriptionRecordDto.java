package com.snapmath.youtext.dto;

import java.time.Instant;
import java.util.List;

public record TranscriptionRecordDto(
        String id,
        String videoTitle,
        String videoUrl,
        String summary,
        List<String> highlights,
        String transcript,
        List<TranscriptLineDto> lines,
        Instant createdAt
) {
}
