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

    public List<ShoppingItem> getAllByUser(String userId) {
        return repo.findByUserIdOrderByCheckedAsc(userId);
    }

    public ShoppingItem create(String userId, ShoppingItemDto dto) {
        ShoppingItem item = ShoppingItem.builder()
                .userId(userId)
                .name(dto.getName())
                .quantity(dto.getQuantity())
                .unit(dto.getUnit())
                .source(dto.getSource() != null ? dto.getSource() : ShoppingItem.Source.MANUAL)
                .build();
        return repo.save(item);
    }

    public ShoppingItem toggleChecked(String userId, String itemId) {
        ShoppingItem item = getOwnedItem(userId, itemId);
        item.setChecked(!item.isChecked());
        return repo.save(item);
    }

    public void delete(String userId, String itemId) {
        ShoppingItem item = getOwnedItem(userId, itemId);
        repo.delete(item);
    }

    @Transactional
    public void clearChecked(String userId) {
        List<ShoppingItem> items = repo.findByUserIdOrderByCheckedAsc(userId);
        items.stream()
                .filter(ShoppingItem::isChecked)
                .forEach(repo::delete);
    }

    @Transactional
    public List<ShoppingItem> generateFromRecipes(String userId,
                                                   List<ShoppingItemDto> items) {
        // Remove old auto items
        repo.deleteByUserIdAndSource(userId, ShoppingItem.Source.AUTO);

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

    private ShoppingItem getOwnedItem(String userId, String itemId) {
        ShoppingItem item = repo.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item not found"));
        if (!item.getUserId().equals(userId)) throw new RuntimeException("Unauthorized");
        return item;
    }
}
