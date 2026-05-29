import 'package:uuid/uuid.dart';

enum TaskPriority { high, medium, low }
enum TaskCategory { work, personal }
enum RecurrenceType { none, daily, weekly, monthly }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskCategory category;
  final bool isComplete;
  final RecurrenceType recurrence;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    this.isComplete = false,
    this.recurrence = RecurrenceType.none,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskCategory? category,
    bool? isComplete,
    RecurrenceType? recurrence,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isComplete: isComplete ?? this.isComplete,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority.index,
        'category': category.index,
        'isComplete': isComplete,
        'recurrence': recurrence.index,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        priority: TaskPriority.values[json['priority'] ?? 1],
        category: TaskCategory.values[json['category'] ?? 1],
        isComplete: json['isComplete'] ?? false,
        recurrence: RecurrenceType.values[json['recurrence'] ?? 0],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
