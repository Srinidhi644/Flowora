package com.flowora.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "shopping_items")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ShoppingItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String name;

    private String quantity;

    private String unit;

    @Builder.Default
    private boolean checked = false;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Source source = Source.MANUAL;

    public enum Source { AUTO, MANUAL }
}
