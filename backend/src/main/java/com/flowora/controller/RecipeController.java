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

    @GetMapping
    public List<Recipe> getAll(Authentication auth) {
        return service.getAllByUser(userId(auth));
    }

    @GetMapping("/{id}")
    public Recipe getById(Authentication auth, @PathVariable String id) {
        return service.getById(userId(auth), id);
    }

    @PostMapping
    public Recipe create(Authentication auth, @RequestBody RecipeDto dto) {
        return service.create(userId(auth), dto);
    }

    @PutMapping("/{id}")
    public Recipe update(Authentication auth, @PathVariable String id, @RequestBody RecipeDto dto) {
        return service.update(userId(auth), id, dto);
    }

    @GetMapping("/search")
    public List<Recipe> searchByIngredients(Authentication auth,
                                             @RequestParam List<String> ingredients) {
        return service.searchByIngredients(userId(auth), ingredients);
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
