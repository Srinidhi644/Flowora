package com.flowora.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class TimeBlockDto {
    private String id;
    private LocalDate date;
    private int startHour;
    private int startMinute;
    private int endHour;
    private int endMinute;
    private String type;
    private String label;
}
