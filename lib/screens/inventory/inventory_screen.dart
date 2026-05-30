import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/models/inventory_item.dart';
import 'package:flowora/providers/inventory_provider.dart';
import 'package:flowora/widgets/empty_state.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inventoryProvider);

    final filtered = _filter == 'All'
        ? items
        : _filter == 'Low Stock'
            ? items.where((i) => i.isLowStock).toList()
            : _filter == 'Expiring'
                ? items.where((i) => i.isExpiringSoon || i.isExpired).toList()
                : items.where((i) => i.category == _filter).toList();

    final lowStockCount = items.where((i) => i.isLowStock).length;
    final expiringCount = items.where((i) => i.isExpiringSoon || i.isExpired).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory', style: AppTextStyles.heading2),
      ),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _StatChip(
                  label: 'Total',
                  value: '${items.length}',
                  color: AppColors.primary,
                  selected: _filter == 'All',
                  onTap: () => setState(() => _filter = 'All'),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Low Stock',
                  value: '$lowStockCount',
                  color: AppColors.warning,
                  selected: _filter == 'Low Stock',
                  onTap: () => setState(() => _filter = 'Low Stock'),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Expiring',
                  value: '$expiringCount',
                  color: AppColors.error,
                  selected: _filter == 'Expiring',
                  onTap: () => setState(() => _filter = 'Expiring'),
                ),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2,
                    title: _filter == 'All'
                        ? 'Inventory is empty'
                        : 'No items match filter',
                    subtitle: 'Track your fridge, pantry, and household items',
                    buttonText: _filter == 'All' ? 'Add Item' : null,
                    onButtonTap: _filter == 'All' ? () => _showAddItem() : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _InventoryTile(
                        item: item,
                        onToggleLowStock: () => ref
                            .read(inventoryProvider.notifier)
                            .toggleLowStock(item.id),
                        onDelete: () => ref
                            .read(inventoryProvider.notifier)
                            .deleteItem(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItem() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    String category = 'Fridge';
    DateTime? expiry;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Inventory Item', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Item name',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Qty'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(hintText: 'Unit (kg, L)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Fridge', 'Pantry', 'Freezer', 'Other'].map((c) {
                  final selected = category == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) => setSheetState(() => category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(expiry != null
                    ? 'Expires: ${DateFormat('MMM d, y').format(expiry!)}'
                    : 'Set expiry date (optional)'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) setSheetState(() => expiry = date);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Theme.of(ctx).inputDecorationTheme.fillColor,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    ref.read(inventoryProvider.notifier).addItem(
                          InventoryItem(
                            name: nameCtrl.text.trim(),
                            quantity: qtyCtrl.text.trim(),
                            unit: unitCtrl.text.trim(),
                            category: category,
                            expiryDate: expiry,
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.textGrey.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(value,
                  style: AppTextStyles.heading3.copyWith(color: color)),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onToggleLowStock;
  final VoidCallback onDelete;

  const _InventoryTile({
    required this.item,
    required this.onToggleLowStock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: item.isExpired
              ? Border.all(color: AppColors.error.withOpacity(0.5))
              : item.isExpiringSoon
                  ? Border.all(color: AppColors.warning.withOpacity(0.5))
                  : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon, color: _categoryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  Row(
                    children: [
                      if (item.quantity.isNotEmpty)
                        Text('${item.quantity} ${item.unit}',
                            style: AppTextStyles.bodySmall),
                      if (item.quantity.isNotEmpty && item.expiryDate != null)
                        const Text(' · ', style: TextStyle(color: AppColors.textGrey)),
                      if (item.expiryDate != null)
                        Text(
                          item.isExpired
                              ? 'Expired!'
                              : 'Exp: ${DateFormat('MMM d').format(item.expiryDate!)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: item.isExpired
                                ? AppColors.error
                                : item.isExpiringSoon
                                    ? AppColors.warning
                                    : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Low',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning)),
              ),
            IconButton(
              icon: Icon(
                item.isLowStock
                    ? Icons.warning_amber
                    : Icons.warning_amber_outlined,
                color: item.isLowStock ? AppColors.warning : AppColors.textGrey,
                size: 20,
              ),
              onPressed: onToggleLowStock,
            ),
          ],
        ),
      ),
    );
  }

  Color get _categoryColor {
    switch (item.category) {
      case 'Fridge':
        return AppColors.info;
      case 'Pantry':
        return AppColors.warning;
      case 'Freezer':
        return AppColors.primaryLight;
      default:
        return AppColors.textGrey;
    }
  }

  IconData get _categoryIcon {
    switch (item.category) {
      case 'Fridge':
        return Icons.kitchen;
      case 'Pantry':
        return Icons.shelves;
      case 'Freezer':
        return Icons.ac_unit;
      default:
        return Icons.inventory_2;
    }
  }
}
