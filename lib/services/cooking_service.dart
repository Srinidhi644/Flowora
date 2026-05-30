import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/models/shopping_item.dart';
import 'package:flowora/models/inventory_item.dart';
import 'package:flowora/models/expense.dart';
import 'package:flowora/providers/inventory_provider.dart';
import 'package:flowora/providers/recipe_provider.dart';
import 'package:flowora/providers/shopping_list_provider.dart';
import 'package:flowora/providers/expense_provider.dart';

/// Orchestrates the flow between recipes, inventory, shopping list, and expenses.
///
/// Assign meal → check inventory → missing → shopping list
/// Remove meal → restore inventory + remove from shopping list + remove expense
/// Cook meal (mark done) → deduct from inventory
class CookingService {
  final WidgetRef ref;

  CookingService(this.ref);

  /// Called when a meal is assigned to a slot.
  /// Checks inventory and adds missing ingredients to shopping list.
  void onMealAssigned(String? recipeId) {
    if (recipeId == null) return;

    final recipe = ref.read(recipeProvider.notifier).getById(recipeId);
    if (recipe == null) return;

    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    final currentShoppingList = ref.read(shoppingListProvider);

    final missing = inventoryNotifier.getMissingIngredients(recipe);

    // For missing items: add new or increase quantity of existing
    final shoppingNotifier = ref.read(shoppingListProvider.notifier);
    final itemsToAdd = <ShoppingItem>[];

    for (final ingredient in missing) {
      final existingIdx = currentShoppingList.indexWhere((item) =>
          item.name.toLowerCase() == ingredient.name.toLowerCase() &&
          !item.isChecked);

      if (existingIdx >= 0) {
        // Already in list — increase quantity
        final existing = currentShoppingList[existingIdx];
        final oldQty = double.tryParse(existing.quantity) ?? 0;
        final addQty = double.tryParse(ingredient.quantity) ?? 0;
        final newQty = oldQty + addQty;
        shoppingNotifier.updateItem(existing.copyWith(
          quantity: newQty > 0
              ? (newQty == newQty.roundToDouble()
                  ? newQty.toInt().toString()
                  : newQty.toStringAsFixed(1))
              : existing.quantity,
        ));
      } else {
        itemsToAdd.add(ShoppingItem(
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          source: ShoppingItemSource.auto,
        ));
      }
    }

    if (itemsToAdd.isNotEmpty) {
      shoppingNotifier.addItems(itemsToAdd);
    }
  }

  /// Called when a meal is removed from a slot.
  /// Reverses: removes auto-added shopping items, restores inventory,
  /// removes auto-created expenses for this recipe's ingredients.
  void onMealRemoved(String? recipeId) {
    if (recipeId == null) return;

    final recipe = ref.read(recipeProvider.notifier).getById(recipeId);
    if (recipe == null) return;

    // Collect all IDs to delete first, then delete
    final shoppingList = List.of(ref.read(shoppingListProvider));
    final expenses = List.of(ref.read(expenseProvider));
    final today = DateTime.now();

    final shoppingIdsToDelete = <String>[];
    final expenseIdsToDelete = <String>[];

    for (final ingredient in recipe.ingredients) {
      final ingName = ingredient.name.toLowerCase();

      // Find auto-added shopping items to remove
      for (final item in shoppingList) {
        if (item.name.toLowerCase() == ingName &&
            item.source == ShoppingItemSource.auto &&
            !item.isChecked) {
          shoppingIdsToDelete.add(item.id);
        }
      }

      // Find auto-created expenses to remove
      for (final e in expenses) {
        if (e.title.toLowerCase() == ingName &&
            e.category == 'Groceries' &&
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day) {
          expenseIdsToDelete.add(e.id);
        }
      }
    }

    // Now delete
    for (final id in shoppingIdsToDelete) {
      ref.read(shoppingListProvider.notifier).deleteItem(id);
    }
    for (final id in expenseIdsToDelete) {
      ref.read(expenseProvider.notifier).deleteExpense(id);
    }
  }

  /// Called when a cooking schedule block is marked complete.
  /// Deducts recipe ingredients from inventory.
  void onMealCooked(String? recipeId) {
    if (recipeId == null) return;

    final recipe = ref.read(recipeProvider.notifier).getById(recipeId);
    if (recipe == null) return;

    ref.read(inventoryProvider.notifier).deductRecipeIngredients(recipe);
  }

  /// Called when a cooking schedule block is unchecked (undo cook).
  /// Restores recipe ingredients to inventory.
  void onMealUncooked(String? recipeId) {
    if (recipeId == null) return;

    final recipe = ref.read(recipeProvider.notifier).getById(recipeId);
    if (recipe == null) return;

    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    for (final ingredient in recipe.ingredients) {
      final existing = inventoryNotifier.findByName(ingredient.name);
      if (existing != null) {
        // Add back quantity
        final currentQty = double.tryParse(existing.quantity) ?? 0;
        final addQty = double.tryParse(ingredient.quantity) ?? 0;
        final newQty = currentQty + addQty;
        inventoryNotifier.updateItem(existing.copyWith(
          quantity: newQty == newQty.roundToDouble()
              ? newQty.toInt().toString()
              : newQty.toStringAsFixed(1),
          isLowStock: false,
        ));
      } else {
        // Re-add to inventory
        inventoryNotifier.addItem(InventoryItem(
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          category: 'Pantry',
        ));
      }
    }
  }

  /// Check inventory for a recipe and return a summary.
  ({int available, int missing, List<String> missingNames}) checkStock(
      String recipeId) {
    final recipe = ref.read(recipeProvider.notifier).getById(recipeId);
    if (recipe == null) {
      return (available: 0, missing: 0, missingNames: []);
    }

    final missingIngredients =
        ref.read(inventoryProvider.notifier).getMissingIngredients(recipe);
    final total = recipe.ingredients.length;

    return (
      available: total - missingIngredients.length,
      missing: missingIngredients.length,
      missingNames: missingIngredients.map((i) => i.name).toList(),
    );
  }
}
