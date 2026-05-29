import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/models/shopping_item.dart';
import 'package:flowora/providers/shopping_list_provider.dart';
import 'package:flowora/widgets/empty_state.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingListProvider);
    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List', style: AppTextStyles.heading2),
        actions: [
          if (checked.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(shoppingListProvider.notifier).clearChecked(),
              child: Text('Clear done',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Add item input
          Padding(
            padding: const EdgeInsets.all(20),
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

          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.shopping_cart,
                    title: 'Shopping list is empty',
                    subtitle:
                        'Add items manually or generate from your meal plan',
                  )
                : ListView(
                    children: [
                      // Unchecked items
                      if (unchecked.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          child: Text(
                            'To buy (${unchecked.length})',
                            style: AppTextStyles.label,
                          ),
                        ),
                        ...unchecked.map((item) => _ShoppingItemTile(
                              item: item,
                              onToggle: () => ref
                                  .read(shoppingListProvider.notifier)
                                  .toggleChecked(item.id),
                              onDelete: () => ref
                                  .read(shoppingListProvider.notifier)
                                  .deleteItem(item.id),
                            )),
                      ],
                      // Checked items
                      if (checked.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          child: Text(
                            'Done (${checked.length})',
                            style: AppTextStyles.label,
                          ),
                        ),
                        ...checked.map((item) => _ShoppingItemTile(
                              item: item,
                              onToggle: () => ref
                                  .read(shoppingListProvider.notifier)
                                  .toggleChecked(item.id),
                              onDelete: () => ref
                                  .read(shoppingListProvider.notifier)
                                  .deleteItem(item.id),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
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
            decoration:
                item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? AppColors.textGrey : null,
          ),
        ),
        subtitle: item.quantity.isNotEmpty
            ? Text('${item.quantity} ${item.unit}',
                style: AppTextStyles.bodySmall)
            : null,
        trailing: item.source == ShoppingItemSource.auto
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('auto',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.info, fontSize: 10)),
              )
            : null,
      ),
    );
  }
}
