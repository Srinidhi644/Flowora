package com.flowora.repository;

import com.flowora.entity.Habit;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface HabitRepository extends JpaRepository<Habit, String> {
    List<Habit> findByUserIdOrderByCreatedAtDesc(String userId);
}
