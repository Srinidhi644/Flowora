import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/inventory_item.dart';
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
    state = [...state, item];
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
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) {
  return InventoryNotifier();
});
