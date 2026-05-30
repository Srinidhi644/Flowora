import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/meal_plan.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/core/utils/date_utils.dart';
import 'package:flowora/services/api_client.dart';

class MealPlanNotifier extends StateNotifier<List<MealPlan>> {
  MealPlanNotifier() : super([]) {
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    await _loadFromHive();
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(AppConstants.mealPlanBox);
    final plans = box.values
        .map((e) => MealPlan.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = plans;
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox(AppConstants.mealPlanBox);
    await box.clear();
    for (final plan in state) {
      await box.put(plan.id, jsonEncode(plan.toJson()));
    }
  }

  Future<void> upsertPlan(MealPlan plan) async {
    final existingIndex = state.indexWhere(
      (p) => AppDateUtils.isSameDay(p.date, plan.date),
    );

    if (existingIndex >= 0) {
      state = [...state]..[existingIndex] = plan;
    } else {
      state = [...state, plan];
    }
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.upsertMealPlan(plan.toJson());
      } catch (_) {}
    }
  }

  Future<void> assignMeal(DateTime date, String mealType, String? recipeId) async {
    final existing = getPlanForDate(date);
    final plan = existing ?? MealPlan(date: AppDateUtils.startOfDay(date));

    MealPlan updated;
    switch (mealType) {
      case 'Breakfast':
        updated = plan.copyWith(breakfastRecipeId: recipeId);
        break;
      case 'Lunch':
        updated = plan.copyWith(lunchRecipeId: recipeId);
        break;
      case 'Dinner':
        updated = plan.copyWith(dinnerRecipeId: recipeId);
        break;
      case 'Snack':
        updated = plan.copyWith(snackRecipeId: recipeId);
        break;
      default:
        return;
    }
    upsertPlan(updated);

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.assignMeal({
          'date': date.toIso8601String().split('T')[0],
          'mealType': mealType.toLowerCase(),
          'recipeId': recipeId ?? '',
        });
      } catch (_) {}
    }
  }

  MealPlan? getPlanForDate(DateTime date) {
    try {
      return state.firstWhere(
        (p) => AppDateUtils.isSameDay(p.date, date),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deletePlan(String id) async {
    state = state.where((p) => p.id != id).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.deleteMealPlan(id);
      } catch (_) {}
    }
  }

  Future<void> refresh() async => _loadPlans();
}

final mealPlanProvider =
    StateNotifierProvider<MealPlanNotifier, List<MealPlan>>((ref) {
  return MealPlanNotifier();
});

final todayMealPlanProvider = Provider<MealPlan?>((ref) {
  final plans = ref.watch(mealPlanProvider);
  final today = DateTime.now();
  try {
    return plans.firstWhere(
      (p) => AppDateUtils.isSameDay(p.date, today),
    );
  } catch (_) {
    return null;
  }
});
