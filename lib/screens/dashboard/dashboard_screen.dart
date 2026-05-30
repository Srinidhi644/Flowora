import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/utils/date_utils.dart';
import 'package:flowora/providers/time_block_provider.dart';
import 'package:flowora/providers/meal_plan_provider.dart';
import 'package:flowora/providers/recipe_provider.dart';
import 'package:flowora/providers/expense_provider.dart';
import 'package:flowora/widgets/section_header.dart';
import 'package:flowora/widgets/time_block_card.dart';
import 'package:flowora/widgets/meal_slot_card.dart';
import 'package:flowora/core/constants/app_constants.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  void _refreshAll() {
    ref.invalidate(timeBlockProvider);
    ref.invalidate(mealPlanProvider);
    ref.invalidate(recipeProvider);
    ref.invalidate(expenseProvider);
  }

  @override
  Widget build(BuildContext context) {
    final todayBlocks = ref.watch(todayBlocksProvider);
    final todayMeal = ref.watch(todayMealPlanProvider);
    final recipes = ref.watch(recipeProvider);
    final todaySpent = ref.watch(todayExpensesProvider);
    final completedBlocks = todayBlocks.where((b) => b.isComplete).length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshAll();
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.getGreeting(),
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.formatFullDate(DateTime.now()),
                          style: AppTextStyles.heading3,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ),
            ),

            // Quick stats
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Schedule',
                      value: '$completedBlocks/${todayBlocks.length}',
                      icon: Icons.check_circle_outline,
                    ),
                    _StatItem(
                      label: 'Meals',
                      value: '${todayMeal?.mealsPlanned ?? 0}/4',
                      icon: Icons.restaurant,
                    ),
                    _StatItem(
                      label: 'Spent',
                      value: '₹${todaySpent.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet,
                    ),
                  ],
                ),
              ),
            ),

            // Schedule
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Schedule',
                actionText: 'See all',
                onAction: () => context.go('/time-blocks'),
              ),
            ),
            if (todayBlocks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.event_note,
                            color: AppColors.textGrey, size: 32),
                        const SizedBox(height: 8),
                        Text('No time blocks scheduled',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TimeBlockCard(
                    block: todayBlocks[index],
                    onToggleComplete: () => ref
                        .read(timeBlockProvider.notifier)
                        .toggleComplete(todayBlocks[index].id),
                  ),
                  childCount:
                      todayBlocks.length > 6 ? 6 : todayBlocks.length,
                ),
              ),

            // Meals
            SliverToBoxAdapter(
              child: SectionHeader(
                title: "Today's Meals",
                actionText: 'Plan',
                onAction: () => context.push('/meal-planner'),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final mealType = AppConstants.mealTypes[index];
                  final recipeId = todayMeal?.getRecipeIdForMeal(mealType);
                  final recipe = recipeId != null
                      ? ref.read(recipeProvider.notifier).getById(recipeId)
                      : null;
                  return MealSlotCard(
                    mealType: mealType,
                    recipe: recipe,
                    onTap: () => context.push('/meal-planner'),
                  );
                },
                childCount: AppConstants.mealTypes.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quick Add', style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickAddButton(
                  icon: Icons.calendar_view_day,
                  label: 'Schedule',
                  color: AppColors.work,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/time-blocks/add');
                  },
                ),
                _QuickAddButton(
                  icon: Icons.restaurant_menu,
                  label: 'Recipe',
                  color: AppColors.cooking,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/recipes/add');
                  },
                ),
                _QuickAddButton(
                  icon: Icons.account_balance_wallet,
                  label: 'Expense',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/expenses');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall
              .copyWith(color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
