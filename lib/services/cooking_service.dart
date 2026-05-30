import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/models/shopping_item.dart';
import 'package:flowora/providers/inventory_provider.dart';
import 'package:flowora/providers/recipe_provider.dart';
import 'package:flowora/providers/shopping_list_provider.dart';

/// Orchestrates the flow between recipes, inventory, and shopping list.
///
/// When a meal is assigned:
///   - Check recipe ingredients against inventory
///   - Missing ingredients → auto-add to shopping list
///
/// When a meal is marked done (cooked):
///   - Deduct recipe ingredients from inventory
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
    final shoppingNotifier = ref.read(shoppingListProvider.notifier);
    final currentShoppingList = ref.read(shoppingListProvider);

    final missing = inventoryNotifier.getMissingIngredients(recipe);

    for (final ingredient in missing) {
      // Check if already in shopping list
      final alreadyInList = currentShoppingList.any((item) =>
          item.name.toLowerCase() == ingredient.name.toLowerCase() &&
          !item.isChecked);

      if (!alreadyInList) {
        shoppingNotifier.addItem(ShoppingItem(
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          source: ShoppingItemSource.auto,
        ));
      }
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

  /// Convenience: check inventory for a recipe and return a summary.
  /// Returns (available count, missing count, missing names).
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
