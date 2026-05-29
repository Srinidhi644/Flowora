package com.flowora.service;

import com.flowora.dto.TaskDto;
import com.flowora.entity.Task;
import com.flowora.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository repo;

    public List<Task> getAllByUser(String userId) {
        return repo.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<Task> getByDate(String userId, LocalDate date) {
        return repo.findByUserIdAndDueDate(userId, date);
    }

    public List<Task> getOverdue(String userId) {
        return repo.findByUserIdAndCompleteFalseAndDueDateBefore(userId, LocalDate.now());
    }

    public Task create(String userId, TaskDto dto) {
        Task task = Task.builder()
                .userId(userId)
                .title(dto.getTitle())
                .description(dto.getDescription())
                .dueDate(dto.getDueDate())
                .priority(dto.getPriority() != null ? dto.getPriority() : Task.Priority.MEDIUM)
                .category(dto.getCategory() != null ? dto.getCategory() : Task.Category.PERSONAL)
                .recurrence(dto.getRecurrence() != null ? dto.getRecurrence() : Task.RecurrenceType.NONE)
                .build();
        return repo.save(task);
    }

    public Task update(String userId, String taskId, TaskDto dto) {
        Task task = repo.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));
        if (!task.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");

        if (dto.getTitle() != null) task.setTitle(dto.getTitle());
        if (dto.getDescription() != null) task.setDescription(dto.getDescription());
        if (dto.getDueDate() != null) task.setDueDate(dto.getDueDate());
        if (dto.getPriority() != null) task.setPriority(dto.getPriority());
        if (dto.getCategory() != null) task.setCategory(dto.getCategory());
        if (dto.getRecurrence() != null) task.setRecurrence(dto.getRecurrence());
        task.setComplete(dto.isComplete());

        return repo.save(task);
    }

    public Task toggleComplete(String userId, String taskId) {
        Task task = repo.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));
        if (!task.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");
        task.setComplete(!task.isComplete());
        return repo.save(task);
    }

    public void delete(String userId, String taskId) {
        Task task = repo.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));
        if (!task.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");
        repo.delete(task);
    }
}
