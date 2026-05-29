package com.flowora.dto;

import com.flowora.entity.ShoppingItem;
import lombok.Data;

@Data
public class ShoppingItemDto {
    private String id;
    private String name;
    private String quantity;
    private String unit;
    private boolean checked;
    private ShoppingItem.Source source;
}
