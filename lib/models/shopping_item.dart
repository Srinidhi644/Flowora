import 'package:uuid/uuid.dart';

enum ShoppingItemSource { auto, manual }

class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  final String unit;
  final bool isChecked;
  final ShoppingItemSource source;

  ShoppingItem({
    String? id,
    required this.name,
    this.quantity = '',
    this.unit = '',
    this.isChecked = false,
    this.source = ShoppingItemSource.manual,
  }) : id = id ?? const Uuid().v4();

  ShoppingItem copyWith({
    String? name,
    String? quantity,
    String? unit,
    bool? isChecked,
    ShoppingItemSource? source,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'isChecked': isChecked,
        'source': source.index,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'] ?? '',
        unit: json['unit'] ?? '',
        isChecked: json['isChecked'] ?? false,
        source: ShoppingItemSource.values[json['source'] ?? 1],
      );
}
