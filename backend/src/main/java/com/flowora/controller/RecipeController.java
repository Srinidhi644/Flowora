package com.flowora.controller;

import com.flowora.dto.RecipeDto;
import com.flowora.entity.Recipe;
import com.flowora.service.RecipeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recipes")
@RequiredArgsConstructor
public class RecipeController {

    private final RecipeService service;

    // Shared: returns ALL recipes from all users
    @GetMapping
    public List<Recipe> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public Recipe getById(@PathVariable String id) {
        return service.getById(id);
    }

    @PostMapping
    public Recipe create(Authentication auth, @RequestBody RecipeDto dto) {
        return service.create(auth.getPrincipal().toString(), dto);
    }

    // Any user can update any recipe (shared)
    @PutMapping("/{id}")
    public Recipe update(@PathVariable String id, @RequestBody RecipeDto dto) {
        return service.update(id, dto);
    }

    @GetMapping("/search")
    public List<Recipe> searchByIngredients(@RequestParam List<String> ingredients) {
        return service.searchByIngredients(ingredients);
    }

    // Any user can delete any recipe (shared)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
