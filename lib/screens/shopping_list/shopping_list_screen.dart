import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/models/shopping_item.dart';
import 'package:flowora/models/expense.dart';
import 'package:flowora/providers/shopping_list_provider.dart';
import 'package:flowora/providers/expense_provider.dart';
import 'package:flowora/widgets/empty_state.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const ShoppingListScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ShoppingListScreen> createState() =>
      _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemController.text.trim().isEmpty) return;
    ref.read(shoppingListProvider.notifier).addItem(
          ShoppingItem(name: _itemController.text.trim()),
        );
    _itemController.clear();
  }

  void _onToggleItem(ShoppingItem item) {
    if (item.isChecked) {
      // Unchecking — just toggle
      ref.read(shoppingListProvider.notifier).toggleChecked(item.id);
      return;
    }

    // Checking off — ask for price to auto-add expense
    _showPriceDialog(item);
  }

  void _showPriceDialog(ShoppingItem item) {
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bought ${item.name}?'),
        content: TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Price (₹) — skip if free',
            prefixIcon: Icon(Icons.currency_rupee),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Skip price, just mark as checked
              ref.read(shoppingListProvider.notifier).toggleChecked(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () {
              final price = double.tryParse(priceCtrl.text.trim());

              // Update shopping item with price and check it
              ref.read(shoppingListProvider.notifier).updateItem(
                    item.copyWith(isChecked: true, price: price),
                  );

              // Auto-add to expenses if price entered
              if (price != null && price > 0) {
                ref.read(expenseProvider.notifier).addExpense(
                      Expense(
                        title: item.name,
                        amount: price,
                        category: 'Groceries',
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('₹${price.toStringAsFixed(0)} added to expenses'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

              Navigator.pop(ctx);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingListProvider);
    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();
    final totalSpent = checked
        .where((i) => i.price != null)
        .fold(0.0, (sum, i) => sum + i.price!);

    final body = Column(
      children: [
        // Add item input
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    hintText: 'Add item...',
                    prefixIcon: Icon(Icons.add),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addItem,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),

        // Spent summary
        if (totalSpent > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Total spent: ₹${totalSpent.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        Expanded(
          child: items.isEmpty
              ? const EmptyState(
                  icon: Icons.shopping_cart,
                  title: 'Shopping list is empty',
                  subtitle: 'Add items manually or generate from your meal plan',
                )
              : ListView(
                  children: [
                    if (unchecked.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        child: Text('To buy (${unchecked.length})',
                            style: AppTextStyles.label),
                      ),
                      ...unchecked.map((item) => _ShoppingItemTile(
                            item: item,
                            onToggle: () => _onToggleItem(item),
                            onDelete: () => ref
                                .read(shoppingListProvider.notifier)
                                .deleteItem(item.id),
                          )),
                    ],
                    if (checked.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Done (${checked.length})',
                                style: AppTextStyles.label),
                            GestureDetector(
                              onTap: () => ref
                                  .read(shoppingListProvider.notifier)
                                  .clearChecked(),
                              child: Text('Clear',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ),
                      ...checked.map((item) => _ShoppingItemTile(
                            item: item,
                            onToggle: () => _onToggleItem(item),
                            onDelete: () => ref
                                .read(shoppingListProvider.notifier)
                                .deleteItem(item.id),
                          )),
                    ],
                  ],
                ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List', style: AppTextStyles.heading2),
      ),
      body: body,
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ShoppingItemTile({
    required this.item,
    required this.onToggle,
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: onToggle,
          child: Icon(
            item.isChecked
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: item.isChecked ? AppColors.success : AppColors.textGrey,
          ),
        ),
        title: Text(
          item.name,
          style: AppTextStyles.bodyMedium.copyWith(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? AppColors.textGrey : null,
          ),
        ),
        subtitle: item.quantity.isNotEmpty
            ? Text('${item.quantity} ${item.unit}',
                style: AppTextStyles.bodySmall)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.price != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('₹${item.price!.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success)),
              ),
            if (item.source == ShoppingItemSource.auto && item.price == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('auto',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info)),
              ),
          ],
        ),
      ),
    );
  }
}
