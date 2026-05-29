package com.flowora.repository;

import com.flowora.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface TaskRepository extends JpaRepository<Task, String> {
    List<Task> findByUserIdOrderByCreatedAtDesc(String userId);
    List<Task> findByUserIdAndDueDate(String userId, LocalDate dueDate);
    List<Task> findByUserIdAndCompleteFalseAndDueDateBefore(String userId, LocalDate date);
}
