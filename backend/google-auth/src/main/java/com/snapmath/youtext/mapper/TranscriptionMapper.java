package com.snapmath.youtext.mapper;

import com.snapmath.youtext.dto.CreateTranscriptionRequest;
import com.snapmath.youtext.dto.TranscriptLineDto;
import com.snapmath.youtext.dto.TranscriptionRecordDto;
import com.snapmath.youtext.model.TranscriptionRecord;
import com.snapmath.youtext.model.TranscriptLine;

import java.util.List;

public final class TranscriptionMapper {
    private TranscriptionMapper() {
    }

    public static TranscriptionRecord toModel(CreateTranscriptionRequest request, String userId) {
        List<TranscriptLine> lines = request.lines().stream()
                .map(line -> new TranscriptLine(line.timestamp(), line.text()))
                .toList();
        List<String> highlights = request.highlights().stream().map(String::trim).toList();

        return TranscriptionRecord.builder()
                .userId(userId)
                .videoTitle(request.videoTitle())
                .videoUrl(request.videoUrl())
                .summary(request.summary())
                .highlights(highlights)
                .transcript(request.transcript())
                .lines(lines)
                .build();
    }

    public static TranscriptionRecordDto toDto(TranscriptionRecord record) {
        List<TranscriptLineDto> lines = record.getLines().stream()
                .map(line -> new TranscriptLineDto(line.timestamp(), line.text()))
                .toList();

        return new TranscriptionRecordDto(
                record.getId(),
                record.getVideoTitle(),
                record.getVideoUrl(),
                record.getSummary(),
                record.getHighlights(),
                record.getTranscript(),
                lines,
                record.getCreatedAt()
        );
    }
}
