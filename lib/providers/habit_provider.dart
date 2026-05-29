import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/habit.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/core/utils/date_utils.dart';
import 'package:flowora/services/api_client.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    await _loadFromHive();

    if (ApiClient.isLoggedIn) {
      try {
        final data = await ApiClient.getHabits();
        final habits = data.map((e) => Habit.fromJson(Map<String, dynamic>.from(e))).toList();
        state = habits;
        await _saveToHive();
      } catch (_) {}
    }
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(AppConstants.habitsBox);
    final habits = box.values
        .map((e) => Habit.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = habits;
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox(AppConstants.habitsBox);
    await box.clear();
    for (final habit in state) {
      await box.put(habit.id, jsonEncode(habit.toJson()));
    }
  }

  Future<void> addHabit(Habit habit) async {
    state = [...state, habit];
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        final res = await ApiClient.createHabit(habit.toJson());
        final serverHabit = Habit.fromJson(Map<String, dynamic>.from(res));
        state = state.map((h) => h.id == habit.id ? serverHabit : h).toList();
        _saveToHive();
      } catch (_) {}
    }
  }

  Future<void> updateHabit(Habit updated) async {
    state = state.map((h) => h.id == updated.id ? updated : h).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.updateHabit(updated.id, updated.toJson());
      } catch (_) {}
    }
  }

  Future<void> deleteHabit(String id) async {
    state = state.where((h) => h.id != id).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.deleteHabit(id);
      } catch (_) {}
    }
  }

  Future<void> toggleTodayLog(String habitId) async {
    final today = DateTime.now();
    state = state.map((h) {
      if (h.id != habitId) return h;

      final existingIndex = h.logs.indexWhere(
        (l) => AppDateUtils.isSameDay(l.date, today),
      );

      List<HabitLog> newLogs;
      if (existingIndex >= 0) {
        newLogs = [...h.logs];
        newLogs[existingIndex] = HabitLog(
          date: today,
          completed: !h.logs[existingIndex].completed,
        );
      } else {
        newLogs = [...h.logs, HabitLog(date: today, completed: true)];
      }

      return h.copyWith(logs: newLogs);
    }).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.toggleHabit(habitId);
      } catch (_) {}
    }
  }

  Future<void> logQuantity(String habitId, double value) async {
    final today = DateTime.now();
    state = state.map((h) {
      if (h.id != habitId) return h;

      final existingIndex = h.logs.indexWhere(
        (l) => AppDateUtils.isSameDay(l.date, today),
      );

      List<HabitLog> newLogs;
      if (existingIndex >= 0) {
        newLogs = [...h.logs];
        newLogs[existingIndex] = HabitLog(
          date: today,
          completed: true,
          value: value,
        );
      } else {
        newLogs = [
          ...h.logs,
          HabitLog(date: today, completed: true, value: value),
        ];
      }

      return h.copyWith(logs: newLogs);
    }).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.logHabit(habitId, {
          'date': today.toIso8601String().split('T')[0],
          'completed': true,
          'value': value,
        });
      } catch (_) {}
    }
  }

  Future<void> refresh() async => _loadHabits();
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});
