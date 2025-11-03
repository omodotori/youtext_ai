package com.example.demo.controller;

import com.example.demo.entity.History;
import com.example.demo.repository.HistoryRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/history")
public class HistoryController {

    private final HistoryRepository historyRepository;

    public HistoryController(HistoryRepository historyRepository) {
        this.historyRepository = historyRepository;
    }

    @PostMapping
    public History create(@RequestBody History history) {
        return historyRepository.save(history);
    }

    @GetMapping
    public List<History> getAll() {
        return historyRepository.findAll();
    }

    @GetMapping("/{user_id}")
    public List<History> getByUserId(@PathVariable("user_id") Long userId) {
        return historyRepository.findByUserId(userId);
    }
}