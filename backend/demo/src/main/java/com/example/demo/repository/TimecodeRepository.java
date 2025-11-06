package com.example.demo.repository;

import com.example.demo.entity.Timecode;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TimecodeRepository extends JpaRepository<Timecode, Long> {}
