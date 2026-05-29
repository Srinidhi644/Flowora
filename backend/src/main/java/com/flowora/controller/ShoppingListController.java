package com.flowora.controller;

import com.flowora.dto.ShoppingItemDto;
import com.flowora.entity.ShoppingItem;
import com.flowora.service.ShoppingListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shopping-list")
@RequiredArgsConstructor
public class ShoppingListController {

    private final ShoppingListService service;

    @GetMapping
    public List<ShoppingItem> getAll(Authentication auth) {
        return service.getAllByUser(userId(auth));
    }

    @PostMapping
    public ShoppingItem create(Authentication auth, @RequestBody ShoppingItemDto dto) {
        return service.create(userId(auth), dto);
    }

    @PatchMapping("/{id}/toggle")
    public ShoppingItem toggle(Authentication auth, @PathVariable String id) {
        return service.toggleChecked(userId(auth), id);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(Authentication auth, @PathVariable String id) {
        service.delete(userId(auth), id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/clear-checked")
    public ResponseEntity<Void> clearChecked(Authentication auth) {
        service.clearChecked(userId(auth));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/generate")
    public List<ShoppingItem> generateFromRecipes(Authentication auth,
                                                    @RequestBody List<ShoppingItemDto> items) {
        return service.generateFromRecipes(userId(auth), items);
    }

    private String userId(Authentication auth) {
        return auth.getPrincipal().toString();
    }
}
