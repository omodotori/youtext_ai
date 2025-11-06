package com.snapmath.youtext.controller;

import com.snapmath.youtext.dto.CreateTranscriptionRequest;
import com.snapmath.youtext.dto.TranscriptionRecordDto;
import com.snapmath.youtext.mapper.TranscriptionMapper;
import com.snapmath.youtext.model.TranscriptionRecord;
import com.snapmath.youtext.service.AuthService;
import com.snapmath.youtext.service.TranscriptionService;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/transcriptions")
public class TranscriptionController {

    public static final String USER_HEADER = "X-User-Id";

    private final TranscriptionService transcriptionService;
    private final AuthService authService;

    public TranscriptionController(TranscriptionService transcriptionService, AuthService authService) {
        this.transcriptionService = transcriptionService;
        this.authService = authService;
    }

    @GetMapping
    public ResponseEntity<List<TranscriptionRecordDto>> findAll(
            @RequestHeader(USER_HEADER) String userId
    ) {
        Optional<String> resolved = resolveUser(userId);
        if (resolved.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        List<TranscriptionRecordDto> records = transcriptionService.findAll(resolved.get()).stream()
                .map(TranscriptionMapper::toDto)
                .toList();
        return ResponseEntity.ok(records);
    }

    @PostMapping
    public ResponseEntity<TranscriptionRecordDto> create(
            @RequestHeader(USER_HEADER) String userId,
            @Valid @RequestBody CreateTranscriptionRequest request
    ) {
        Optional<String> resolved = resolveUser(userId);
        if (resolved.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String id = resolved.get();
        TranscriptionRecord toSave = TranscriptionMapper.toModel(request, id);
        TranscriptionRecord saved = transcriptionService.save(id, toSave);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .header(HttpHeaders.LOCATION, "/api/transcriptions/" + saved.getId())
                .body(TranscriptionMapper.toDto(saved));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TranscriptionRecordDto> findOne(
            @RequestHeader(USER_HEADER) String userId,
            @PathVariable String id
    ) {
        Optional<String> resolved = resolveUser(userId);
        if (resolved.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        return transcriptionService.findOne(resolved.get(), id)
                .map(TranscriptionMapper::toDto)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @RequestHeader(USER_HEADER) String userId,
            @PathVariable String id
    ) {
        Optional<String> resolved = resolveUser(userId);
        if (resolved.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        transcriptionService.delete(resolved.get(), id);
        return ResponseEntity.noContent().build();
    }

    private Optional<String> resolveUser(String userId) {
        if (!StringUtils.hasText(userId)) {
            return Optional.empty();
        }
        return authService.findById(userId).map(profile -> userId);
    }

}
