package com.flowora.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class MealPlanDto {
    private String id;
    private LocalDate date;
    private String breakfastRecipeId;
    private String lunchRecipeId;
    private String dinnerRecipeId;
    private String snackRecipeId;
}
