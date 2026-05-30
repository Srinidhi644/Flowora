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

    // Shared: returns ALL shopping items
    @GetMapping
    public List<ShoppingItem> getAll() {
        return service.getAll();
    }

    @PostMapping
    public ShoppingItem create(Authentication auth, @RequestBody ShoppingItemDto dto) {
        return service.create(auth.getPrincipal().toString(), dto);
    }

    @PatchMapping("/{id}/toggle")
    public ShoppingItem toggle(@PathVariable String id) {
        return service.toggleChecked(id);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/clear-checked")
    public ResponseEntity<Void> clearChecked() {
        service.clearChecked();
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/generate")
    public List<ShoppingItem> generateFromRecipes(Authentication auth,
                                                    @RequestBody List<ShoppingItemDto> items) {
        return service.generateFromRecipes(auth.getPrincipal().toString(), items);
    }
}
