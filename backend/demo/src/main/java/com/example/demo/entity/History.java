package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonManagedReference;

@Entity
@Table(name = "history")
public class History {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Long id;

    @Column(name = "user_id")
    @JsonProperty("user_id")
    private Integer userId;

    @Column(columnDefinition = "TEXT")
    private String text;

    @Column(length = 255)
    private String link;

    @OneToMany(mappedBy = "history", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private List<Timecode> timecodes = new ArrayList<>();

    // --- Методы для связи ---
    public void addTimecode(Timecode timecode) {
        timecodes.add(timecode);
        timecode.setHistory(this);
    }

    public void removeTimecode(Timecode timecode) {
        timecodes.remove(timecode);
        timecode.setHistory(null);
    }

    // --- Getters / Setters ---
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    public List<Timecode> getTimecodes() {
        return timecodes;
    }

    public void setTimecodes(List<Timecode> timecodes) {
        this.timecodes = timecodes;
        if (timecodes != null) {
            for (Timecode t : timecodes) {
                t.setHistory(this);
            }
        }
    }
}
