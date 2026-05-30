import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/utils/date_utils.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/providers/meal_plan_provider.dart';
import 'package:flowora/providers/recipe_provider.dart';
import 'package:flowora/providers/shopping_list_provider.dart';
import 'package:flowora/providers/inventory_provider.dart';
import 'package:flowora/services/cooking_service.dart';
import 'package:flowora/widgets/meal_slot_card.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = AppDateUtils.getWeekDays(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final mealPlans = ref.watch(mealPlanProvider);
    final recipes = ref.watch(recipeProvider);
    final plan = ref.read(mealPlanProvider.notifier).getPlanForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner', style: AppTextStyles.heading2),
        actions: [
          TextButton.icon(
            onPressed: () => _generateShoppingList(),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Shopping List'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Week selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _weekDays.map((day) {
                final isSelected = AppDateUtils.isSameDay(day, _selectedDate);
                final dayPlan =
                    ref.read(mealPlanProvider.notifier).getPlanForDate(day);
                final hasMeals = dayPlan != null && !dayPlan.isEmpty;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: Container(
                    width: 44,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.cooking
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][
                              day.weekday - 1],
                          style: AppTextStyles.label.copyWith(
                            color:
                                isSelected ? Colors.white : AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasMeals)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.cooking,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppDateUtils.relativeDay(_selectedDate),
                style: AppTextStyles.heading3,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Meal slots
          Expanded(
            child: ListView(
              children: AppConstants.mealTypes.map((mealType) {
                final recipeId = plan?.getRecipeIdForMeal(mealType);
                final recipe = recipeId != null
                    ? ref.read(recipeProvider.notifier).getById(recipeId)
                    : null;

                return MealSlotCard(
                  mealType: mealType,
                  recipe: recipe,
                  onTap: () => _selectRecipe(mealType),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _selectRecipe(String mealType) {
    final recipes = ref.read(recipeProvider);
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add some recipes first!'),
          action: SnackBarAction(
            label: 'Add',
            onPressed: () => context.push('/recipes/add'),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select for $mealType', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            // Remove option
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.error),
              title: const Text('Remove meal'),
              onTap: () {
                ref
                    .read(mealPlanProvider.notifier)
                    .assignMeal(_selectedDate, mealType, null);
                Navigator.pop(ctx);
              },
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: recipes.length,
                itemBuilder: (_, i) {
                  final recipe = recipes[i];
                  return ListTile(
                    leading: const Icon(Icons.restaurant,
                        color: AppColors.cooking),
                    title: Text(recipe.name),
                    subtitle: Text('${recipe.totalTimeMinutes} min'),
                    onTap: () {
                      ref
                          .read(mealPlanProvider.notifier)
                          .assignMeal(_selectedDate, mealType, recipe.id);

                      // Check inventory and add missing to shopping list
                      final cookingService = CookingService(ref);
                      cookingService.onMealAssigned(recipe.id);

                      final stock = cookingService.checkStock(recipe.id);
                      Navigator.pop(ctx);

                      if (stock.missing > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${stock.missing} missing ingredient(s) added to shopping list: ${stock.missingNames.join(", ")}',
                            ),
                            action: SnackBarAction(
                              label: 'View',
                              onPressed: () => context.push('/shopping-list'),
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateShoppingList() {
    final plans = ref.read(mealPlanProvider);
    final recipes = ref.read(recipeProvider);

    final allRecipeIds = <String?>[];
    for (final plan in plans) {
      allRecipeIds.addAll([
        plan.breakfastRecipeId,
        plan.lunchRecipeId,
        plan.dinnerRecipeId,
        plan.snackRecipeId,
      ]);
    }

    ref
        .read(shoppingListProvider.notifier)
        .generateFromMealPlan(recipes, allRecipeIds);

    context.push('/shopping-list');
  }
}
