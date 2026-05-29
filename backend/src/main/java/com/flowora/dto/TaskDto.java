package com.flowora.dto;

import com.flowora.entity.Task;
import lombok.Data;
import java.time.LocalDate;

@Data
public class TaskDto {
    private String id;
    private String title;
    private String description;
    private LocalDate dueDate;
    private Task.Priority priority;
    private Task.Category category;
    private boolean complete;
    private Task.RecurrenceType recurrence;
}
