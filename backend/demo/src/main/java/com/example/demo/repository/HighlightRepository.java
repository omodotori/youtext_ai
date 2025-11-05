package com.example.demo.repository;

import com.example.demo.entity.Highlight;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HighlightRepository extends JpaRepository<Highlight, Long> {}
