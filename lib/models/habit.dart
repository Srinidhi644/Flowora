import 'package:uuid/uuid.dart';

enum HabitType { boolean, quantity }

class HabitLog {
  final DateTime date;
  final bool completed;
  final double? value;

  const HabitLog({
    required this.date,
    this.completed = false,
    this.value,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'completed': completed,
        'value': value,
      };

  factory HabitLog.fromJson(Map<String, dynamic> json) => HabitLog(
        date: DateTime.parse(json['date']),
        completed: json['completed'] ?? false,
        value: json['value']?.toDouble(),
      );
}

class Habit {
  final String id;
  final String name;
  final String icon;
  final HabitType type;
  final double? targetValue;
  final String? unit;
  final List<HabitLog> logs;
  final DateTime createdAt;

  Habit({
    String? id,
    required this.name,
    this.icon = 'check_circle',
    this.type = HabitType.boolean,
    this.targetValue,
    this.unit,
    this.logs = const [],
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get currentStreak {
    if (logs.isEmpty) return 0;
    final sorted = [...logs]..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    var checkDate = DateTime.now();

    for (final log in sorted) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      final expected =
          DateTime(checkDate.year, checkDate.month, checkDate.day);

      if (logDate == expected && log.completed) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (logDate.isBefore(expected)) {
        break;
      }
    }
    return streak;
  }

  int get bestStreak {
    if (logs.isEmpty) return 0;
    final sorted = [...logs]..sort((a, b) => a.date.compareTo(b.date));
    int best = 0;
    int current = 0;
    DateTime? lastDate;

    for (final log in sorted) {
      if (!log.completed) {
        current = 0;
        lastDate = null;
        continue;
      }

      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (lastDate != null) {
        final diff = logDate.difference(lastDate!).inDays;
        if (diff == 1) {
          current++;
        } else {
          current = 1;
        }
      } else {
        current = 1;
      }
      lastDate = logDate;
      if (current > best) best = current;
    }
    return best;
  }

  Habit copyWith({
    String? name,
    String? icon,
    HabitType? type,
    double? targetValue,
    String? unit,
    List<HabitLog>? logs,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      logs: logs ?? this.logs,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'type': type.index,
        'targetValue': targetValue,
        'unit': unit,
        'logs': logs.map((l) => l.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        icon: json['icon'] ?? 'check_circle',
        type: HabitType.values[json['type'] ?? 0],
        targetValue: json['targetValue']?.toDouble(),
        unit: json['unit'],
        logs: (json['logs'] as List?)
                ?.map((l) => HabitLog.fromJson(l))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
