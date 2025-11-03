package com.snapmath.youtext.service;

import com.snapmath.youtext.model.TranscriptionRecord;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class InMemoryTranscriptionService implements TranscriptionService {

    private final Map<String, List<TranscriptionRecord>> storage = new ConcurrentHashMap<>();

    @Override
    public TranscriptionRecord save(String userId, TranscriptionRecord record) {
        storage.computeIfAbsent(userId, key -> Collections.synchronizedList(new ArrayList<>()));

        List<TranscriptionRecord> userRecords = storage.get(userId);
        userRecords.removeIf(existing -> existing.getId().equals(record.getId()));

        TranscriptionRecord toPersist = record.toBuilder().userId(userId).build();
        userRecords.add(0, toPersist);
        return toPersist;
    }

    @Override
    public List<TranscriptionRecord> findAll(String userId) {
        return storage.getOrDefault(userId, List.of());
    }

    @Override
    public Optional<TranscriptionRecord> findOne(String userId, String id) {
        return storage.getOrDefault(userId, List.of())
                .stream()
                .filter(record -> record.getId().equals(id))
                .findFirst();
    }

    @Override
    public void delete(String userId, String id) {
        storage.computeIfPresent(userId, (key, records) -> {
            records.removeIf(record -> record.getId().equals(id));
            return records.isEmpty() ? null : records;
        });
    }
}
