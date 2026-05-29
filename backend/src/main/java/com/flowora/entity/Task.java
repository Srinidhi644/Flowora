package com.flowora.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "tasks")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    private LocalDate dueDate;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Priority priority = Priority.MEDIUM;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Category category = Category.PERSONAL;

    @Builder.Default
    private boolean complete = false;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RecurrenceType recurrence = RecurrenceType.NONE;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum Priority { HIGH, MEDIUM, LOW }
    public enum Category { WORK, PERSONAL }
    public enum RecurrenceType { NONE, DAILY, WEEKLY, MONTHLY }
}
