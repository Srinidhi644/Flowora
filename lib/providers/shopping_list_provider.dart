import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/shopping_item.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/services/api_client.dart';

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingListNotifier() : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    await _loadFromHive();

    if (ApiClient.isLoggedIn) {
      try {
        final data = await ApiClient.getShoppingList();
        final items = data.map((e) => ShoppingItem.fromJson(Map<String, dynamic>.from(e))).toList();
        state = items;
        await _saveToHive();
      } catch (_) {}
    }
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(AppConstants.shoppingListBox);
    final items = box.values
        .map((e) => ShoppingItem.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = items;
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox(AppConstants.shoppingListBox);
    await box.clear();
    for (final item in state) {
      await box.put(item.id, jsonEncode(item.toJson()));
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    // Merge if same unchecked item exists
    final existingIdx = state.indexWhere((i) =>
        i.name.toLowerCase() == item.name.toLowerCase() && !i.isChecked);

    if (existingIdx >= 0) {
      final existing = state[existingIdx];
      final oldQty = double.tryParse(existing.quantity) ?? 0;
      final newQty = double.tryParse(item.quantity) ?? 0;
      final totalQty = oldQty + newQty;
      final merged = existing.copyWith(
        quantity: totalQty > 0
            ? (totalQty == totalQty.roundToDouble()
                ? totalQty.toInt().toString()
                : totalQty.toStringAsFixed(1))
            : existing.quantity,
      );
      state = [...state]..[existingIdx] = merged;
    } else {
      state = [...state, item];
    }
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        final res = await ApiClient.createShoppingItem(item.toJson());
        final serverItem = ShoppingItem.fromJson(Map<String, dynamic>.from(res));
        state = state.map((i) => i.id == item.id ? serverItem : i).toList();
        _saveToHive();
      } catch (_) {}
    }
  }

  /// Add multiple items at once, merging duplicates
  void addItems(List<ShoppingItem> items) {
    var updated = [...state];
    for (final item in items) {
      final existingIdx = updated.indexWhere((i) =>
          i.name.toLowerCase() == item.name.toLowerCase() && !i.isChecked);

      if (existingIdx >= 0) {
        final existing = updated[existingIdx];
        final oldQty = double.tryParse(existing.quantity) ?? 0;
        final newQty = double.tryParse(item.quantity) ?? 0;
        final totalQty = oldQty + newQty;
        updated[existingIdx] = existing.copyWith(
          quantity: totalQty > 0
              ? (totalQty == totalQty.roundToDouble()
                  ? totalQty.toInt().toString()
                  : totalQty.toStringAsFixed(1))
              : existing.quantity,
        );
      } else {
        updated.add(item);
      }
    }
    state = updated;
    _saveToHive();
  }

  Future<void> updateItem(ShoppingItem updated) async {
    state = state.map((i) => i.id == updated.id ? updated : i).toList();
    _saveToHive();
  }

  Future<void> deleteItem(String id) async {
    state = state.where((i) => i.id != id).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.deleteShoppingItem(id);
      } catch (_) {}
    }
  }

  Future<void> toggleChecked(String id) async {
    state = state.map((i) {
      if (i.id == id) return i.copyWith(isChecked: !i.isChecked);
      return i;
    }).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.toggleShoppingItem(id);
      } catch (_) {}
    }
  }

  Future<void> clearChecked() async {
    state = state.where((i) => !i.isChecked).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.clearCheckedItems();
      } catch (_) {}
    }
  }

  void generateFromMealPlan(List<Recipe> recipes, List<String?> recipeIds) {
    state = state.where((i) => i.source != ShoppingItemSource.auto).toList();

    final Map<String, ShoppingItem> ingredientMap = {};
    for (final recipeId in recipeIds) {
      if (recipeId == null) continue;
      final recipe = recipes.where((r) => r.id == recipeId).firstOrNull;
      if (recipe == null) continue;

      for (final ingredient in recipe.ingredients) {
        final key = ingredient.name.toLowerCase();
        if (!ingredientMap.containsKey(key)) {
          ingredientMap[key] = ShoppingItem(
            name: ingredient.name,
            quantity: ingredient.quantity,
            unit: ingredient.unit,
            source: ShoppingItemSource.auto,
          );
        }
      }
    }

    state = [...state, ...ingredientMap.values];
    _saveToHive();
  }

  Future<void> refresh() async => _loadItems();
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
  return ShoppingListNotifier();
});
