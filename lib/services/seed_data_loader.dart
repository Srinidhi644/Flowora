import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/services/seed_data.dart';

class SeedDataLoader {
  static const _seedLoadedKey = 'seedDataLoaded';

  static Future<void> loadIfFirstRun() async {
    final settingsBox = await Hive.openBox(AppConstants.settingsBox);
    final alreadyLoaded = settingsBox.get(_seedLoadedKey, defaultValue: false);

    if (alreadyLoaded == true) return;

    // Load all seed data into Hive boxes
    await _loadTasks();
    await _loadRecipes();
    await _loadTimeBlocks();
    await _loadHabits();
    await _loadMealPlans();
    await _loadShoppingList();

    await settingsBox.put(_seedLoadedKey, true);
  }

  static Future<void> _loadTasks() async {
    final box = await Hive.openBox(AppConstants.tasksBox);
    for (final task in SeedData.tasks) {
      await box.put(task.id, jsonEncode(task.toJson()));
    }
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

  static Future<void> _loadHabits() async {
    final box = await Hive.openBox(AppConstants.habitsBox);
    for (final habit in SeedData.habits) {
      await box.put(habit.id, jsonEncode(habit.toJson()));
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
}
