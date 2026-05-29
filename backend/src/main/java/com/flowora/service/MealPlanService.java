package com.flowora.service;

import com.flowora.dto.MealPlanDto;
import com.flowora.entity.MealPlan;
import com.flowora.repository.MealPlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MealPlanService {

    private final MealPlanRepository repo;

    public List<MealPlan> getAllByUser(String userId) {
        return repo.findByUserIdOrderByDateAsc(userId);
    }

    public MealPlan getByDate(String userId, LocalDate date) {
        return repo.findByUserIdAndDate(userId, date).orElse(null);
    }

    public List<MealPlan> getWeek(String userId, LocalDate weekStart) {
        return repo.findByUserIdAndDateBetween(userId, weekStart, weekStart.plusDays(6));
    }

    public MealPlan upsert(String userId, MealPlanDto dto) {
        MealPlan plan = repo.findByUserIdAndDate(userId, dto.getDate())
                .orElse(MealPlan.builder()
                        .userId(userId)
                        .date(dto.getDate())
                        .build());

        if (dto.getBreakfastRecipeId() != null) plan.setBreakfastRecipeId(dto.getBreakfastRecipeId());
        if (dto.getLunchRecipeId() != null) plan.setLunchRecipeId(dto.getLunchRecipeId());
        if (dto.getDinnerRecipeId() != null) plan.setDinnerRecipeId(dto.getDinnerRecipeId());
        if (dto.getSnackRecipeId() != null) plan.setSnackRecipeId(dto.getSnackRecipeId());

        return repo.save(plan);
    }

    public MealPlan assignMeal(String userId, LocalDate date, String mealType, String recipeId) {
        MealPlan plan = repo.findByUserIdAndDate(userId, date)
                .orElse(MealPlan.builder().userId(userId).date(date).build());

        switch (mealType.toLowerCase()) {
            case "breakfast" -> plan.setBreakfastRecipeId(recipeId);
            case "lunch" -> plan.setLunchRecipeId(recipeId);
            case "dinner" -> plan.setDinnerRecipeId(recipeId);
            case "snack" -> plan.setSnackRecipeId(recipeId);
            default -> throw new RuntimeException("Invalid meal type: " + mealType);
        }

        return repo.save(plan);
    }

    public void delete(String userId, String planId) {
        MealPlan plan = repo.findById(planId)
                .orElseThrow(() -> new RuntimeException("MealPlan not found"));
        if (!plan.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");
        repo.delete(plan);
    }
}
