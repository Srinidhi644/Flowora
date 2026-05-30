import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/services/seed_data.dart';

class SeedDataLoader {
  static const _seedLoadedKey = 'seedDataLoaded_v2';

  static Future<void> loadIfFirstRun() async {
    final settingsBox = await Hive.openBox(AppConstants.settingsBox);
    final alreadyLoaded = settingsBox.get(_seedLoadedKey, defaultValue: false);

    if (alreadyLoaded == true) return;

    await _loadRecipes();
    await _loadTimeBlocks();
    await _loadMealPlans();
    await _loadShoppingList();
    await _loadInventory();
    await _loadExpenses();

    await settingsBox.put(_seedLoadedKey, true);
  }

  static Future<void> _loadRecipes() async {
    final box = await Hive.openBox(AppConstants.recipesBox);
    for (final recipe in SeedData.recipes) {
      await box.put(recipe.id, jsonEncode(recipe.toJson()));
    }
  }

  static Future<void> _loadTimeBlocks() async {
    final box = await Hive.openBox(AppConstants.timeBlocksBox);
    for (final block in SeedData.timeBlocks) {
      await box.put(block.id, jsonEncode(block.toJson()));
    }
  }

  static Future<void> _loadMealPlans() async {
    final box = await Hive.openBox(AppConstants.mealPlanBox);
    final plans = SeedData.mealPlans(SeedData.recipes);
    for (final plan in plans) {
      await box.put(plan.id, jsonEncode(plan.toJson()));
    }
  }

  static Future<void> _loadShoppingList() async {
    final box = await Hive.openBox(AppConstants.shoppingListBox);
    for (final item in SeedData.shoppingItems) {
      await box.put(item.id, jsonEncode(item.toJson()));
    }
  }

  static Future<void> _loadInventory() async {
    final box = await Hive.openBox(AppConstants.inventoryBox);
    for (final item in SeedData.inventoryItems) {
      await box.put(item.id, jsonEncode(item.toJson()));
    }
  }

  static Future<void> _loadExpenses() async {
    final box = await Hive.openBox(AppConstants.expensesBox);
    for (final expense in SeedData.expenses) {
      await box.put(expense.id, jsonEncode(expense.toJson()));
    }
  }
}
