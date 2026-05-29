package com.flowora.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "habits")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Habit {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String name;

    @Builder.Default
    private String icon = "check_circle";

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private HabitType type = HabitType.BOOLEAN;

    private Double targetValue;

    private String unit;

    @OneToMany(mappedBy = "habit", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<HabitLog> logs = new ArrayList<>();

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum HabitType { BOOLEAN, QUANTITY }
}
