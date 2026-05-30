import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/inventory_item.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/core/constants/app_constants.dart';

class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  InventoryNotifier() : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final box = await Hive.openBox(AppConstants.inventoryBox);
    final items = box.values
        .map((e) =>
            InventoryItem.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = items;
  }

  Future<void> _saveItems() async {
    final box = await Hive.openBox(AppConstants.inventoryBox);
    await box.clear();
    for (final item in state) {
      await box.put(item.id, jsonEncode(item.toJson()));
    }
  }

  void addItem(InventoryItem item) {
    // Check if item with same name already exists — merge quantities
    final existingIdx = state.indexWhere(
        (i) => i.name.toLowerCase() == item.name.toLowerCase());

    if (existingIdx >= 0) {
      final existing = state[existingIdx];
      final oldQty = double.tryParse(existing.quantity) ?? 0;
      final newQty = double.tryParse(item.quantity) ?? 0;
      final totalQty = oldQty + newQty;

      final merged = existing.copyWith(
        quantity: totalQty == totalQty.roundToDouble()
            ? totalQty.toInt().toString()
            : totalQty.toStringAsFixed(1),
        unit: item.unit.isNotEmpty ? item.unit : existing.unit,
        isLowStock: false,
      );
      state = [...state]..[existingIdx] = merged;
    } else {
      state = [...state, item];
    }
    _saveItems();
  }

  void updateItem(InventoryItem updated) {
    state = state.map((i) => i.id == updated.id ? updated : i).toList();
    _saveItems();
  }

  void deleteItem(String id) {
    state = state.where((i) => i.id != id).toList();
    _saveItems();
  }

  void toggleLowStock(String id) {
    state = state.map((i) {
      if (i.id == id) return i.copyWith(isLowStock: !i.isLowStock);
      return i;
    }).toList();
    _saveItems();
  }

  /// Find an inventory item by ingredient name (case-insensitive partial match)
  InventoryItem? findByName(String name) {
    final lower = name.toLowerCase();
    try {
      return state.firstWhere(
        (i) => i.name.toLowerCase() == lower ||
            i.name.toLowerCase().contains(lower) ||
            lower.contains(i.name.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  /// Check which ingredients from a recipe are missing from inventory.
  /// Returns list of missing ingredient names.
  List<Ingredient> getMissingIngredients(Recipe recipe) {
    return recipe.ingredients.where((ing) {
      final found = findByName(ing.name);
      return found == null;
    }).toList();
  }

  /// Deduct recipe ingredients from inventory after cooking.
  /// Tries to parse quantities and subtract. If quantity reaches 0 or below,
  /// marks as low stock. If item not found, skips it.
  void deductRecipeIngredients(Recipe recipe) {
    final updated = [...state];

    for (final ing in recipe.ingredients) {
      final idx = updated.indexWhere((item) {
        final itemName = item.name.toLowerCase();
        final ingName = ing.name.toLowerCase();
        return itemName == ingName ||
            itemName.contains(ingName) ||
            ingName.contains(itemName);
      });

      if (idx < 0) continue;

      final item = updated[idx];
      final currentQty = double.tryParse(item.quantity) ?? 0;
      final usedQty = double.tryParse(ing.quantity) ?? 0;

      if (currentQty > 0 && usedQty > 0) {
        final newQty = currentQty - usedQty;
        if (newQty <= 0) {
          // Remove item, it's used up
          updated.removeAt(idx);
        } else {
          updated[idx] = item.copyWith(
            quantity: newQty == newQty.roundToDouble()
                ? newQty.toInt().toString()
                : newQty.toStringAsFixed(1),
            isLowStock: newQty <= (currentQty * 0.25),
          );
        }
      } else {
        // Can't parse quantities, just mark as low stock
        updated[idx] = item.copyWith(isLowStock: true);
      }
    }

    state = updated;
    _saveItems();
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) {
  return InventoryNotifier();
});
