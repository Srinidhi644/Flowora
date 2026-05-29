package com.flowora.repository;

import com.flowora.entity.MealPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface MealPlanRepository extends JpaRepository<MealPlan, String> {
    List<MealPlan> findByUserIdOrderByDateAsc(String userId);
    Optional<MealPlan> findByUserIdAndDate(String userId, LocalDate date);
    List<MealPlan> findByUserIdAndDateBetween(String userId, LocalDate start, LocalDate end);
}
