package com.flowora.repository;

import com.flowora.entity.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface RecipeRepository extends JpaRepository<Recipe, String> {
    List<Recipe> findByUserIdOrderByCreatedAtDesc(String userId);

    List<Recipe> findAllByOrderByCreatedAtDesc();

    @Query("SELECT DISTINCT r FROM Recipe r JOIN r.ingredients i " +
           "WHERE LOWER(i.name) IN :ingredients")
    List<Recipe> findByIngredientsIn(@Param("ingredients") List<String> ingredients);
}
