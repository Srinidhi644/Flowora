import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flowora/core/theme/app_colors.dart';

enum BlockStatus { upcoming, inProgress, completed, missed }

class TimeBlock {
  final String id;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String type;
  final String label;
  final bool isTask;
  final bool isComplete;

  TimeBlock({
    String? id,
    required this.date,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.type,
    this.label = '',
    this.isTask = false,
    this.isComplete = false,
  }) : id = id ?? const Uuid().v4();

  double get durationHours {
    final start = startHour + startMinute / 60.0;
    final end = endHour + endMinute / 60.0;
    return end - start;
  }

  BlockStatus get status {
    final now = DateTime.now();
    final blockDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (isComplete) return BlockStatus.completed;

    final blockStart = DateTime(date.year, date.month, date.day, startHour, startMinute);
    final blockEnd = DateTime(date.year, date.month, date.day, endHour, endMinute);

    if (now.isBefore(blockStart)) return BlockStatus.upcoming;
    if (now.isAfter(blockEnd)) return BlockStatus.missed;
    return BlockStatus.inProgress;
  }

  Color get statusColor {
    switch (status) {
      case BlockStatus.completed:
        return AppColors.success;
      case BlockStatus.upcoming:
        return AppColors.textGrey;
      case BlockStatus.inProgress:
        return AppColors.primary;
      case BlockStatus.missed:
        return AppColors.error;
    }
  }

  Color get color {
    switch (type) {
      case 'Work':
        return AppColors.work;
      case 'Deep Work':
        return AppColors.deepWork;
      case 'Cooking':
        return AppColors.cooking;
      case 'Exercise':
        return AppColors.exercise;
      case 'Rest':
        return AppColors.rest;
      case 'Personal':
        return AppColors.personal;
      case 'Task':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  TimeBlock copyWith({
    DateTime? date,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? type,
    String? label,
    bool? isTask,
    bool? isComplete,
  }) {
    return TimeBlock(
      id: id,
      date: date ?? this.date,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      type: type ?? this.type,
      label: label ?? this.label,
      isTask: isTask ?? this.isTask,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'type': type,
        'label': label,
        'isTask': isTask,
        'isComplete': isComplete,
      };

  factory TimeBlock.fromJson(Map<String, dynamic> json) => TimeBlock(
        id: json['id'],
        date: DateTime.parse(json['date']),
        startHour: json['startHour'],
        startMinute: json['startMinute'],
        endHour: json['endHour'],
        endMinute: json['endMinute'],
        type: json['type'],
        label: json['label'] ?? '',
        isTask: json['isTask'] ?? false,
        isComplete: json['isComplete'] ?? false,
      );
}
