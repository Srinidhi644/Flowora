import 'package:uuid/uuid.dart';

enum ShoppingItemSource { auto, manual }

class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  final String unit;
  final bool isChecked;
  final double? price;
  final ShoppingItemSource source;

  ShoppingItem({
    String? id,
    required this.name,
    this.quantity = '',
    this.unit = '',
    this.isChecked = false,
    this.price,
    this.source = ShoppingItemSource.manual,
  }) : id = id ?? const Uuid().v4();

  ShoppingItem copyWith({
    String? name,
    String? quantity,
    String? unit,
    bool? isChecked,
    double? price,
    ShoppingItemSource? source,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      price: price ?? this.price,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'isChecked': isChecked,
        'price': price,
        'source': source.index,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'] ?? '',
        unit: json['unit'] ?? '',
        isChecked: json['isChecked'] ?? false,
        price: json['price']?.toDouble(),
        source: ShoppingItemSource.values[json['source'] ?? 1],
      );
}
