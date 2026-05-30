import 'package:uuid/uuid.dart';

class InventoryItem {
  final String id;
  final String name;
  final String quantity;
  final String unit;
  final String category;
  final DateTime? expiryDate;
  final bool isLowStock;
  final DateTime createdAt;

  InventoryItem({
    String? id,
    required this.name,
    this.quantity = '',
    this.unit = '',
    this.category = 'Other',
    this.expiryDate,
    this.isLowStock = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool get isExpiringSoon =>
      expiryDate != null &&
      !isExpired &&
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 3)));

  InventoryItem copyWith({
    String? name,
    String? quantity,
    String? unit,
    String? category,
    DateTime? expiryDate,
    bool? isLowStock,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      isLowStock: isLowStock ?? this.isLowStock,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
        'expiryDate': expiryDate?.toIso8601String(),
        'isLowStock': isLowStock,
        'createdAt': createdAt.toIso8601String(),
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'] ?? '',
        unit: json['unit'] ?? '',
        category: json['category'] ?? 'Other',
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        isLowStock: json['isLowStock'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );
}
