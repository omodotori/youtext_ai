package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "highlights")
public class Highlight {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String highlight;

    @ManyToOne
    @JoinColumn(name = "history_id", nullable = false)
    @JsonBackReference
    private History history;

    // --- Getters / Setters ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getHighlight() { return highlight; }
    public void setHighlight(String highlight) { this.highlight = highlight; }

    public History getHistory() { return history; }
    public void setHistory(History history) { this.history = history; }
}
