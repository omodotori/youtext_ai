package com.example.demo.entity;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "history")
public class History {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @JsonProperty("id")
    private Long id;

    @Column(name = "user_id", nullable = false)
    @JsonProperty("user_id")
    private Integer userId;

    @Column(name = "video_title", length = 255, nullable = false)
    @JsonProperty("video_title")
    private String videoTitle;

    // 🔹 ИСПРАВЛЕНО: Go ждет поле "video_url", поэтому отдаем его именно так
    @Column(columnDefinition = "TEXT")
    @JsonProperty("video_url")
    private String link;

    // 🔹 ИСПРАВЛЕНО: База данных (PostgreSQL) сама проставит время. 
    // Java будет только отдавать его для Go под ключом "created_at" и игнорировать при сохранении.
    @Column(name = "created_at", insertable = false, updatable = false)
    @JsonProperty(value = "created_at", access = JsonProperty.Access.READ_ONLY)
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX")
    private OffsetDateTime createdAt;

    @Column(columnDefinition = "TEXT")
    @JsonProperty("summary")
    private String summary;

    @Column(columnDefinition = "TEXT")
    @JsonProperty("transcript")
    private String transcript;

    @OneToMany(mappedBy = "history", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    @JsonProperty("highlights")
    private List<Highlight> highlights = new ArrayList<>();

    @OneToMany(mappedBy = "history", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    @JsonProperty("timecodes")
    private List<Timecode> timecodes = new ArrayList<>();

    // --- Методы связи ---
    public void addHighlight(Highlight highlight) {
        highlights.add(highlight);
        highlight.setHistory(this);
    }

    public void addTimecode(Timecode timecode) {
        timecodes.add(timecode);
        timecode.setHistory(this);
    }

    // --- Getters / Setters ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getVideoTitle() { return videoTitle; }
    public void setVideoTitle(String videoTitle) { this.videoTitle = videoTitle; }

    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

    // 🔹 ИСПРАВЛЕНО: Геттеры и сеттеры теперь называются getSummary / setSummary
    // Это нужно, чтобы Jackson правильно связал их с полем @JsonProperty("summary")
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }

    public String getTranscript() { return transcript; }
    public void setTranscript(String transcript) { this.transcript = transcript; }

    public List<Highlight> getHighlights() { return highlights; }
    public void setHighlights(List<Highlight> highlights) {
        this.highlights = highlights;
        if (highlights != null)
            highlights.forEach(h -> h.setHistory(this));
    }

    public List<Timecode> getTimecodes() { return timecodes; }
    public void setTimecodes(List<Timecode> timecodes) {
        this.timecodes = timecodes;
        if (timecodes != null)
            timecodes.forEach(t -> t.setHistory(this));
    }
}