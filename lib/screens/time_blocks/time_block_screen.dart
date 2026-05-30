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

  bool get _isPastDate {
    final today = DateTime.now();
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final todayStart = DateTime(today.year, today.month, today.day);
    return selected.isBefore(todayStart);
  }

  void _onToggleComplete(block) {
    if (_isPastDate) return; // Can't modify past

    final wasComplete = block.isComplete;
    ref.read(timeBlockProvider.notifier).toggleComplete(block.id);

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
              cookingService.onMealCooked(recipeId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Inventory deducted for ${recipe.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
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

  /// Generate 14 days: today's week start through +1 week
  List<DateTime> _getTwoWeeks() {
    final today = DateTime.now();
    final weekStart = AppDateUtils.startOfWeek(today);
    return List.generate(14, (i) => weekStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final allBlocks = ref.watch(timeBlockProvider);
    final dayBlocks =
        ref.read(timeBlockProvider.notifier).blocksForDate(_selectedDate);

    final days = _getTwoWeeks();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: AppTextStyles.heading2),
      ),
      body: Column(
        children: [
          // 2-week day selector (scrollable)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = AppDateUtils.isSameDay(day, _selectedDate);
                final isToday = AppDateUtils.isSameDay(day, today);
                final dayStart = DateTime(day.year, day.month, day.day);
                final isPast = dayStart.isBefore(todayStart);

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: Container(
                    width: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1],
                          style: AppTextStyles.label.copyWith(
                            color: isSelected
                                ? Colors.white
                                : isPast
                                    ? AppColors.textGrey.withOpacity(0.4)
                                    : AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isSelected
                                ? Colors.white
                                : isPast
                                    ? AppColors.textGrey.withOpacity(0.4)
                                    : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppDateUtils.relativeDay(_selectedDate),
                    style: AppTextStyles.heading3,
                  ),
                ),
                if (_isPastDate)
                  Text('Read only', style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: dayBlocks.isEmpty
                ? EmptyState(
                    icon: Icons.calendar_view_day,
                    title: 'No time blocks',
                    subtitle: _isPastDate
                        ? 'Nothing was scheduled for this day'
                        : 'Plan your day with time blocks',
                    buttonText: _isPastDate ? null : 'Add Block',
                    onButtonTap: _isPastDate
                        ? null
                        : () => context.push('/time-blocks/add', extra: _selectedDate),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: dayBlocks.length,
                    itemBuilder: (context, index) {
                      final block = dayBlocks[index];
                      return Dismissible(
                        key: Key(block.id),
                        direction: _isPastDate
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
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
                          onTap: _isPastDate
                              ? null
                              : () => context.push('/time-blocks/edit',
                                  extra: block.id),
                          onToggleComplete: _isPastDate
                              ? null
                              : () => _onToggleComplete(block),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _isPastDate
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/time-blocks/add', extra: _selectedDate),
              child: const Icon(Icons.add),
            ),
    );
  }
}
