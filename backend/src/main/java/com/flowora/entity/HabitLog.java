package com.flowora.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "habit_logs")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class HabitLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private LocalDate date;

    @Builder.Default
    private boolean completed = false;

    @Column(name = "log_value")
    private Double value;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "habit_id")
    @JsonIgnore
    private Habit habit;
}
