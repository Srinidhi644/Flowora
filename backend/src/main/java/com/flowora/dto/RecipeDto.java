package com.flowora.dto;

import lombok.Data;
import java.util.List;

@Data
public class RecipeDto {
    private String id;
    private String name;
    private int prepTimeMinutes;
    private int cookTimeMinutes;
    private int servings;
    private String imagePath;
    private String dietaryType;
    private List<IngredientDto> ingredients;
    private List<String> steps;
    private List<String> tags;

    @Data
    public static class IngredientDto {
        private String name;
        private String quantity;
        private String unit;
    }
}
