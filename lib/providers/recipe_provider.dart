import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/services/api_client.dart';

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  RecipeNotifier() : super([]) {
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    await _loadFromHive();
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(AppConstants.recipesBox);
    final recipes = box.values
        .map((e) => Recipe.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = recipes;
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox(AppConstants.recipesBox);
    await box.clear();
    for (final recipe in state) {
      await box.put(recipe.id, jsonEncode(recipe.toJson()));
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    state = [...state, recipe];
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        final res = await ApiClient.createRecipe(recipe.toJson());
        final serverRecipe = Recipe.fromJson(Map<String, dynamic>.from(res));
        state = state.map((r) => r.id == recipe.id ? serverRecipe : r).toList();
        _saveToHive();
      } catch (_) {}
    }
  }

  Future<void> updateRecipe(Recipe updated) async {
    state = state.map((r) => r.id == updated.id ? updated : r).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.updateRecipe(updated.id, updated.toJson());
      } catch (_) {}
    }
  }

  Future<void> deleteRecipe(String id) async {
    state = state.where((r) => r.id != id).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.deleteRecipe(id);
      } catch (_) {}
    }
  }

  Recipe? getById(String id) {
    try {
      return state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Recipe> searchByIngredients(List<String> ingredients) {
    if (ingredients.isEmpty) return state;
    return state.where((recipe) {
      final recipeIngredients =
          recipe.ingredients.map((i) => i.name.toLowerCase()).toList();
      return ingredients.any(
        (input) => recipeIngredients.any(
          (ri) => ri.contains(input.toLowerCase()),
        ),
      );
    }).toList();
  }

  Future<void> refresh() async => _loadRecipes();
}

final recipeProvider =
    StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  return RecipeNotifier();
});
