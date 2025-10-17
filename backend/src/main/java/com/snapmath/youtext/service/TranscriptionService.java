package com.snapmath.youtext.service;

import com.snapmath.youtext.model.TranscriptionRecord;

import java.util.List;
import java.util.Optional;

public interface TranscriptionService {

    TranscriptionRecord save(String userId, TranscriptionRecord record);

    List<TranscriptionRecord> findAll(String userId);

    Optional<TranscriptionRecord> findOne(String userId, String id);

    void delete(String userId, String id);
}
