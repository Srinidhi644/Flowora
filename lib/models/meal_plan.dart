import 'package:uuid/uuid.dart';

class MealPlan {
  final String id;
  final DateTime date;
  final String? breakfastRecipeId;
  final String? lunchRecipeId;
  final String? dinnerRecipeId;
  final String? snackRecipeId;

  MealPlan({
    String? id,
    required this.date,
    this.breakfastRecipeId,
    this.lunchRecipeId,
    this.dinnerRecipeId,
    this.snackRecipeId,
  }) : id = id ?? const Uuid().v4();

  bool get isEmpty =>
      breakfastRecipeId == null &&
      lunchRecipeId == null &&
      dinnerRecipeId == null &&
      snackRecipeId == null;

  int get mealsPlanned {
    int count = 0;
    if (breakfastRecipeId != null) count++;
    if (lunchRecipeId != null) count++;
    if (dinnerRecipeId != null) count++;
    if (snackRecipeId != null) count++;
    return count;
  }

  String? getRecipeIdForMeal(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return breakfastRecipeId;
      case 'Lunch':
        return lunchRecipeId;
      case 'Dinner':
        return dinnerRecipeId;
      case 'Snack':
        return snackRecipeId;
      default:
        return null;
    }
  }

  MealPlan copyWith({
    DateTime? date,
    String? breakfastRecipeId,
    String? lunchRecipeId,
    String? dinnerRecipeId,
    String? snackRecipeId,
  }) {
    return MealPlan(
      id: id,
      date: date ?? this.date,
      breakfastRecipeId: breakfastRecipeId ?? this.breakfastRecipeId,
      lunchRecipeId: lunchRecipeId ?? this.lunchRecipeId,
      dinnerRecipeId: dinnerRecipeId ?? this.dinnerRecipeId,
      snackRecipeId: snackRecipeId ?? this.snackRecipeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'breakfastRecipeId': breakfastRecipeId,
        'lunchRecipeId': lunchRecipeId,
        'dinnerRecipeId': dinnerRecipeId,
        'snackRecipeId': snackRecipeId,
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        id: json['id'],
        date: DateTime.parse(json['date']),
        breakfastRecipeId: json['breakfastRecipeId'],
        lunchRecipeId: json['lunchRecipeId'],
        dinnerRecipeId: json['dinnerRecipeId'],
        snackRecipeId: json['snackRecipeId'],
      );
}
