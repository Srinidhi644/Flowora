package com.flowora.dto;

import com.flowora.entity.Habit;
import lombok.Data;
import java.time.LocalDate;

@Data
public class HabitDto {
    private String id;
    private String name;
    private String icon;
    private Habit.HabitType type;
    private Double targetValue;
    private String unit;

    @Data
    public static class LogDto {
        private LocalDate date;
        private boolean completed;
        private Double value;
    }
}
