import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/time_block.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/core/utils/date_utils.dart';
import 'package:flowora/services/api_client.dart';

class TimeBlockNotifier extends StateNotifier<List<TimeBlock>> {
  TimeBlockNotifier() : super([]) {
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    await _loadFromHive();

    if (ApiClient.isLoggedIn) {
      try {
        final data = await ApiClient.getTimeBlocks();
        final blocks = data.map((e) => TimeBlock.fromJson(Map<String, dynamic>.from(e))).toList();
        if (blocks.isNotEmpty) {
          state = blocks;
          await _saveToHive();
        }
      } catch (_) {}
    }
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(AppConstants.timeBlocksBox);
    final blocks = box.values
        .map((e) => TimeBlock.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = blocks;
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox(AppConstants.timeBlocksBox);
    await box.clear();
    for (final block in state) {
      await box.put(block.id, jsonEncode(block.toJson()));
    }
  }

  Future<void> addBlock(TimeBlock block) async {
    state = [...state, block];
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        final res = await ApiClient.createTimeBlock(block.toJson());
        final serverBlock = TimeBlock.fromJson(Map<String, dynamic>.from(res));
        state = state.map((b) => b.id == block.id ? serverBlock : b).toList();
        _saveToHive();
      } catch (_) {}
    }
  }

  Future<void> updateBlock(TimeBlock updated) async {
    state = state.map((b) => b.id == updated.id ? updated : b).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.updateTimeBlock(updated.id, updated.toJson());
      } catch (_) {}
    }
  }

  Future<void> deleteBlock(String id) async {
    state = state.where((b) => b.id != id).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      try {
        await ApiClient.deleteTimeBlock(id);
      } catch (_) {}
    }
  }

  Future<void> toggleComplete(String id) async {
    state = state.map((b) {
      if (b.id == id) return b.copyWith(isComplete: !b.isComplete);
      return b;
    }).toList();
    _saveToHive();

    if (ApiClient.isLoggedIn) {
      final block = state.firstWhere((b) => b.id == id);
      try {
        await ApiClient.updateTimeBlock(id, block.toJson());
      } catch (_) {}
    }
  }

  List<TimeBlock> blocksForDate(DateTime date) {
    return state
        .where((b) => AppDateUtils.isSameDay(b.date, date))
        .toList()
      ..sort((a, b) {
        final aStart = a.startHour * 60 + a.startMinute;
        final bStart = b.startHour * 60 + b.startMinute;
        return aStart.compareTo(bStart);
      });
  }

  Future<void> refresh() async => _loadBlocks();
}

final timeBlockProvider =
    StateNotifierProvider<TimeBlockNotifier, List<TimeBlock>>((ref) {
  return TimeBlockNotifier();
});

final todayBlocksProvider = Provider<List<TimeBlock>>((ref) {
  final blocks = ref.watch(timeBlockProvider);
  final today = DateTime.now();
  return blocks
      .where((b) => AppDateUtils.isSameDay(b.date, today))
      .toList()
    ..sort((a, b) {
      final aStart = a.startHour * 60 + a.startMinute;
      final bStart = b.startHour * 60 + b.startMinute;
      return aStart.compareTo(bStart);
    });
});
