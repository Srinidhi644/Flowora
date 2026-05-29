package com.flowora.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "meal_plans")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MealPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private LocalDate date;

    private String breakfastRecipeId;
    private String lunchRecipeId;
    private String dinnerRecipeId;
    private String snackRecipeId;
}
