package com.flowora.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "time_blocks")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TimeBlock {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private LocalDate date;

    private int startHour;
    private int startMinute;
    private int endHour;
    private int endMinute;

    @Column(nullable = false)
    private String type;

    private String label;
}
