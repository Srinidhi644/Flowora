import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/task.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/core/utils/date_utils.dart';
import 'package:flowora/services/api_client.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    // Load from local first (instant)
    await _loadFromHive();

    // Then sync from API
    if (ApiClient.isLoggedIn) {
      try {
        final data = await ApiClient.getTasks();
        final tasks = data.map((e) => Task.fromJson(Map<String, dynamic>.from(e))).toList();
        state = tasks;
        await _saveToHive();
      } catch (_) {
        // Offline — use local data
      }
    }
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(AppConstants.tasksBox);
    final tasks = box.values
        .map((e) => Task.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = tasks;
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox(AppConstants.tasksBox);
    await box.clear();
    for (final task in state) {
      await box.put(task.id, jsonEncode(task.toJson()));
    }
  }

  Future<void> addTask(Task task) async {
    state = [...state, task];
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        final res = await ApiClient.createTask(task.toJson());
        final serverTask = Task.fromJson(Map<String, dynamic>.from(res));
        state = state.map((t) => t.id == task.id ? serverTask : t).toList();
        _saveToHive();
      } catch (_) {}
    }
  }

  Future<void> updateTask(Task updated) async {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.updateTask(updated.id, updated.toJson());
      } catch (_) {}
    }
  }

  Future<void> deleteTask(String id) async {
    state = state.where((t) => t.id != id).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.deleteTask(id);
      } catch (_) {}
    }
  }

  Future<void> toggleComplete(String id) async {
    state = state.map((t) {
      if (t.id == id) return t.copyWith(isComplete: !t.isComplete);
      return t;
    }).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.toggleTask(id);
      } catch (_) {}
    }
  }

  Future<void> refresh() async => _loadTasks();
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final today = DateTime.now();
  return tasks.where((t) {
    if (t.dueDate == null) return false;
    return AppDateUtils.isSameDay(t.dueDate!, today);
  }).toList();
});

final overdueTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final today = AppDateUtils.startOfDay(DateTime.now());
  return tasks.where((t) {
    if (t.dueDate == null || t.isComplete) return false;
    return t.dueDate!.isBefore(today);
  }).toList();
});
