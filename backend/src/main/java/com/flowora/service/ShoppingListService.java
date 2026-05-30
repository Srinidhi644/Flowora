package com.flowora.service;

import com.flowora.dto.ShoppingItemDto;
import com.flowora.entity.ShoppingItem;
import com.flowora.repository.ShoppingItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ShoppingListService {

    private final ShoppingItemRepository repo;

    // Shared: returns ALL shopping items
    public List<ShoppingItem> getAll() {
        return repo.findAllByOrderByCheckedAsc();
    }

    public ShoppingItem create(String userId, ShoppingItemDto dto) {
        ShoppingItem item = ShoppingItem.builder()
                .userId(userId)
                .name(dto.getName())
                .quantity(dto.getQuantity())
                .unit(dto.getUnit())
                .price(dto.getPrice())
                .source(dto.getSource() != null ? dto.getSource() : ShoppingItem.Source.MANUAL)
                .build();
        return repo.save(item);
    }

    public ShoppingItem toggleChecked(String itemId) {
        ShoppingItem item = repo.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item not found"));
        item.setChecked(!item.isChecked());
        return repo.save(item);
    }

    public void delete(String itemId) {
        repo.deleteById(itemId);
    }

    @Transactional
    public void clearChecked() {
        List<ShoppingItem> items = repo.findAllByOrderByCheckedAsc();
        items.stream()
                .filter(ShoppingItem::isChecked)
                .forEach(repo::delete);
    }

    @Transactional
    public List<ShoppingItem> generateFromRecipes(String userId,
                                                   List<ShoppingItemDto> items) {
        repo.deleteBySource(ShoppingItem.Source.AUTO);

        List<ShoppingItem> newItems = items.stream()
                .map(dto -> ShoppingItem.builder()
                        .userId(userId)
                        .name(dto.getName())
                        .quantity(dto.getQuantity())
                        .unit(dto.getUnit())
                        .source(ShoppingItem.Source.AUTO)
                        .build())
                .toList();

        return repo.saveAll(newItems);
    }
}
