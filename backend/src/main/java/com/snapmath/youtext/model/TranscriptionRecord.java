package com.snapmath.youtext.model;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class TranscriptionRecord {
    private final String id;
    private final String userId;
    private final String videoTitle;
    private final String videoUrl;
    private final String summary;
    private final List<String> highlights;
    private final String transcript;
    private final List<TranscriptLine> lines;
    private final Instant createdAt;

    private TranscriptionRecord(Builder builder) {
        this.id = builder.id != null ? builder.id : UUID.randomUUID().toString();
        this.userId = builder.userId;
        this.videoTitle = builder.videoTitle;
        this.videoUrl = builder.videoUrl;
        this.summary = builder.summary;
        this.highlights = List.copyOf(builder.highlights);
        this.transcript = builder.transcript;
        this.lines = List.copyOf(builder.lines);
        this.createdAt = builder.createdAt != null ? builder.createdAt : Instant.now();
    }

    public String getId() {
        return id;
    }

    public String getUserId() {
        return userId;
    }

    public String getVideoTitle() {
        return videoTitle;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public String getSummary() {
        return summary;
    }

    public List<String> getHighlights() {
        return highlights;
    }

    public String getTranscript() {
        return transcript;
    }

    public List<TranscriptLine> getLines() {
        return lines;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Builder toBuilder() {
        return new Builder()
                .id(id)
                .userId(userId)
                .videoTitle(videoTitle)
                .videoUrl(videoUrl)
                .summary(summary)
                .highlights(highlights)
                .transcript(transcript)
                .lines(lines)
                .createdAt(createdAt);
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String id;
        private String userId;
        private String videoTitle;
        private String videoUrl;
        private String summary;
        private List<String> highlights = List.of();
        private String transcript;
        private List<TranscriptLine> lines = List.of();
        private Instant createdAt;

        public Builder id(String id) {
            this.id = id;
            return this;
        }

        public Builder userId(String userId) {
            this.userId = userId;
            return this;
        }

        public Builder videoTitle(String videoTitle) {
            this.videoTitle = videoTitle;
            return this;
        }

        public Builder videoUrl(String videoUrl) {
            this.videoUrl = videoUrl;
            return this;
        }

        public Builder summary(String summary) {
            this.summary = summary;
            return this;
        }

        public Builder highlights(List<String> highlights) {
            this.highlights = highlights != null ? List.copyOf(highlights) : List.of();
            return this;
        }

        public Builder transcript(String transcript) {
            this.transcript = transcript;
            return this;
        }

        public Builder lines(List<TranscriptLine> lines) {
            this.lines = lines != null ? List.copyOf(lines) : List.of();
            return this;
        }

        public Builder createdAt(Instant createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public TranscriptionRecord build() {
            return new TranscriptionRecord(this);
        }
    }
}
