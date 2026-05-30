import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/utils/date_utils.dart';
import 'package:flowora/providers/time_block_provider.dart';
import 'package:flowora/providers/meal_plan_provider.dart';
import 'package:flowora/providers/recipe_provider.dart';
import 'package:flowora/services/cooking_service.dart';
import 'package:flowora/widgets/time_block_card.dart';
import 'package:flowora/widgets/empty_state.dart';

class TimeBlockScreen extends ConsumerStatefulWidget {
  const TimeBlockScreen({super.key});

  @override
  ConsumerState<TimeBlockScreen> createState() => _TimeBlockScreenState();
}

class _TimeBlockScreenState extends ConsumerState<TimeBlockScreen> {
  DateTime _selectedDate = DateTime.now();

  void _onToggleComplete(block) {
    final wasComplete = block.isComplete;
    ref.read(timeBlockProvider.notifier).toggleComplete(block.id);

    // Cooking block: manage inventory
    if (block.type == 'Cooking') {
      final mealPlan = ref.read(mealPlanProvider.notifier).getPlanForDate(block.date);
      if (mealPlan != null) {
        final cookingService = CookingService(ref);
        final recipeIds = [
          mealPlan.breakfastRecipeId,
          mealPlan.lunchRecipeId,
          mealPlan.dinnerRecipeId,
          mealPlan.snackRecipeId,
        ].where((id) => id != null);

        for (final recipeId in recipeIds) {
          final recipe = ref.read(recipeProvider.notifier).getById(recipeId!);
          if (recipe != null &&
              block.label.toLowerCase().contains(recipe.name.toLowerCase())) {
            if (!wasComplete) {
              // Marking done → deduct inventory
              cookingService.onMealCooked(recipeId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Inventory deducted for ${recipe.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              // Unchecking → restore inventory
              cookingService.onMealUncooked(recipeId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Inventory restored for ${recipe.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allBlocks = ref.watch(timeBlockProvider);
    final dayBlocks =
        ref.read(timeBlockProvider.notifier).blocksForDate(_selectedDate);

    final weekDays = AppDateUtils.getWeekDays(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: AppTextStyles.heading2),
      ),
      body: Column(
        children: [
          // Week day selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDays.map((day) {
                final isSelected =
                    AppDateUtils.isSameDay(day, _selectedDate);
                final isToday =
                    AppDateUtils.isSameDay(day, DateTime.now());
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: Container(
                    width: 44,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][
                              day.weekday - 1],
                          style: AppTextStyles.label.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isSelected
                                ? Colors.white
                                : null,
                            fontWeight: FontWeight.w600,
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
          Expanded(
            child: dayBlocks.isEmpty
                ? EmptyState(
                    icon: Icons.calendar_view_day,
                    title: 'No time blocks',
                    subtitle: 'Plan your day with time blocks',
                    buttonText: 'Add Block',
                    onButtonTap: () => context.push('/time-blocks/add'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: dayBlocks.length,
                    itemBuilder: (context, index) {
                      final block = dayBlocks[index];
                      return Dismissible(
                        key: Key(block.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => ref
                            .read(timeBlockProvider.notifier)
                            .deleteBlock(block.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        child: TimeBlockCard(
                          block: block,
                          onToggleComplete: () =>
                              _onToggleComplete(block),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/time-blocks/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
