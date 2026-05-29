package com.flowora.controller;

import com.flowora.dto.MealPlanDto;
import com.flowora.entity.MealPlan;
import com.flowora.service.MealPlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/meal-plans")
@RequiredArgsConstructor
public class MealPlanController {

    private final MealPlanService service;

    @GetMapping
    public List<MealPlan> getAll(Authentication auth) {
        return service.getAllByUser(userId(auth));
    }

    @GetMapping("/date/{date}")
    public MealPlan getByDate(Authentication auth,
                               @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return service.getByDate(userId(auth), date);
    }

    @GetMapping("/week/{weekStart}")
    public List<MealPlan> getWeek(Authentication auth,
                                   @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate weekStart) {
        return service.getWeek(userId(auth), weekStart);
    }

    @PostMapping
    public MealPlan upsert(Authentication auth, @RequestBody MealPlanDto dto) {
        return service.upsert(userId(auth), dto);
    }

    @PatchMapping("/assign")
    public MealPlan assignMeal(Authentication auth, @RequestBody Map<String, String> body) {
        LocalDate date = LocalDate.parse(body.get("date"));
        return service.assignMeal(userId(auth), date, body.get("mealType"), body.get("recipeId"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(Authentication auth, @PathVariable String id) {
        service.delete(userId(auth), id);
        return ResponseEntity.noContent().build();
    }

    private String userId(Authentication auth) {
        return auth.getPrincipal().toString();
    }
}
