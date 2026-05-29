import 'package:uuid/uuid.dart';

class Ingredient {
  final String name;
  final String quantity;
  final String unit;

  const Ingredient({
    required this.name,
    required this.quantity,
    this.unit = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'],
        quantity: json['quantity'],
        unit: json['unit'] ?? '',
      );
}

class Recipe {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String? imagePath;
  final List<String> tags;
  final String dietaryType;
  final DateTime createdAt;

  Recipe({
    String? id,
    required this.name,
    required this.ingredients,
    required this.steps,
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 2,
    this.imagePath,
    this.tags = const [],
    this.dietaryType = 'No Preference',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  Recipe copyWith({
    String? name,
    List<Ingredient>? ingredients,
    List<String>? steps,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? imagePath,
    List<String>? tags,
    String? dietaryType,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      dietaryType: dietaryType ?? this.dietaryType,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'steps': steps,
        'prepTimeMinutes': prepTimeMinutes,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        'imagePath': imagePath,
        'tags': tags,
        'dietaryType': dietaryType,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        name: json['name'],
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i))
            .toList(),
        steps: List<String>.from(json['steps']),
        prepTimeMinutes: json['prepTimeMinutes'] ?? 0,
        cookTimeMinutes: json['cookTimeMinutes'] ?? 0,
        servings: json['servings'] ?? 2,
        imagePath: json['imagePath'],
        tags: List<String>.from(json['tags'] ?? []),
        dietaryType: json['dietaryType'] ?? 'No Preference',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
