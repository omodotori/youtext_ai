package com.example.demo.repository;

import com.example.demo.entity.History;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

public interface HistoryRepository extends JpaRepository<History, Long> {
    List<History> findByUserId(Integer userId);

    @Transactional
    void deleteByUserId(Integer userId);

    long countByUserId(Integer userId);
}
