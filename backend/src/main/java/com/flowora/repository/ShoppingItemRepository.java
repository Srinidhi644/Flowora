package com.flowora.repository;

import com.flowora.entity.ShoppingItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ShoppingItemRepository extends JpaRepository<ShoppingItem, String> {
    List<ShoppingItem> findByUserIdOrderByCheckedAsc(String userId);
    List<ShoppingItem> findAllByOrderByCheckedAsc();
    void deleteByUserIdAndSource(String userId, ShoppingItem.Source source);
    void deleteBySource(ShoppingItem.Source source);
}
