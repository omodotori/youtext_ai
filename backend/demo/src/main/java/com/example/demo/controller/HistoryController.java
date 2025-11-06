package com.example.demo.controller;

import com.example.demo.entity.History;
import com.example.demo.repository.HistoryRepository;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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
    public List<History> getByUserId(@PathVariable("user_id") Integer userId) {
        return historyRepository.findByUserId(userId);
    }

    @DeleteMapping("/user/{user_id}")
    public void deleteAllByUserId(@PathVariable("user_id") Integer userId) {
        historyRepository.deleteByUserId(userId);
    }

    @GetMapping("/user/{user_id}/count")
    public Map<String, Long> getHistoryCount(@PathVariable("user_id") Integer userId) {
        long count = historyRepository.countByUserId(userId);
        return Map.of("count", count);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteByHistoryId(@PathVariable Long id) {
        if (!historyRepository.existsById(id)) {
            return ResponseEntity.status(404).body(Map.of("error", "Not found"));
        }
        historyRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Deleted"));
    }
}
