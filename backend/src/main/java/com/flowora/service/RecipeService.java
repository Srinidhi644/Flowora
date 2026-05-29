package com.flowora.service;

import com.flowora.dto.RecipeDto;
import com.flowora.entity.Ingredient;
import com.flowora.entity.Recipe;
import com.flowora.repository.RecipeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecipeService {

    private final RecipeRepository repo;

    public List<Recipe> getAllByUser(String userId) {
        return repo.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public Recipe getById(String userId, String recipeId) {
        Recipe recipe = repo.findById(recipeId)
                .orElseThrow(() -> new RuntimeException("Recipe not found"));
        if (!recipe.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");
        return recipe;
    }

    @Transactional
    public Recipe create(String userId, RecipeDto dto) {
        Recipe recipe = Recipe.builder()
                .userId(userId)
                .name(dto.getName())
                .prepTimeMinutes(dto.getPrepTimeMinutes())
                .cookTimeMinutes(dto.getCookTimeMinutes())
                .servings(dto.getServings())
                .imagePath(dto.getImagePath())
                .dietaryType(dto.getDietaryType())
                .steps(dto.getSteps() != null ? dto.getSteps() : List.of())
                .tags(dto.getTags() != null ? dto.getTags() : List.of())
                .build();

        recipe = repo.save(recipe);

        if (dto.getIngredients() != null) {
            for (RecipeDto.IngredientDto ingDto : dto.getIngredients()) {
                Ingredient ingredient = Ingredient.builder()
                        .name(ingDto.getName())
                        .quantity(ingDto.getQuantity())
                        .unit(ingDto.getUnit())
                        .recipe(recipe)
                        .build();
                recipe.getIngredients().add(ingredient);
            }
            recipe = repo.save(recipe);
        }

        return recipe;
    }

    @Transactional
    public Recipe update(String userId, String recipeId, RecipeDto dto) {
        Recipe recipe = getById(userId, recipeId);

        if (dto.getName() != null) recipe.setName(dto.getName());
        recipe.setPrepTimeMinutes(dto.getPrepTimeMinutes());
        recipe.setCookTimeMinutes(dto.getCookTimeMinutes());
        recipe.setServings(dto.getServings());
        if (dto.getImagePath() != null) recipe.setImagePath(dto.getImagePath());
        if (dto.getDietaryType() != null) recipe.setDietaryType(dto.getDietaryType());
        if (dto.getSteps() != null) recipe.setSteps(dto.getSteps());
        if (dto.getTags() != null) recipe.setTags(dto.getTags());

        if (dto.getIngredients() != null) {
            recipe.getIngredients().clear();
            for (RecipeDto.IngredientDto ingDto : dto.getIngredients()) {
                Ingredient ingredient = Ingredient.builder()
                        .name(ingDto.getName())
                        .quantity(ingDto.getQuantity())
                        .unit(ingDto.getUnit())
                        .recipe(recipe)
                        .build();
                recipe.getIngredients().add(ingredient);
            }
        }

        return repo.save(recipe);
    }

    public List<Recipe> searchByIngredients(String userId, List<String> ingredients) {
        List<String> lower = ingredients.stream()
                .map(String::toLowerCase)
                .collect(Collectors.toList());
        return repo.findByIngredientsIn(userId, lower);
    }

    public void delete(String userId, String recipeId) {
        Recipe recipe = getById(userId, recipeId);
        repo.delete(recipe);
    }
}
