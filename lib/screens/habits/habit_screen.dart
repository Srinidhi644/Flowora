import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/models/habit.dart';
import 'package:flowora/providers/habit_provider.dart';
import 'package:flowora/widgets/habit_tile.dart';
import 'package:flowora/widgets/empty_state.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits', style: AppTextStyles.heading2),
      ),
      body: habits.isEmpty
          ? EmptyState(
              icon: Icons.trending_up,
              title: 'Start tracking habits',
              subtitle: 'Build consistency with daily habit tracking',
              buttonText: 'Add Habit',
              onButtonTap: () => _showAddHabit(context, ref),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF16A34A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Active',
                        value: '${habits.length}',
                      ),
                      _StatItem(
                        label: 'Best Streak',
                        value:
                            '${habits.fold<int>(0, (max, h) => h.bestStreak > max ? h.bestStreak : max)}',
                      ),
                      _StatItem(
                        label: 'Today',
                        value:
                            '${habits.where((h) => h.logs.any((l) => l.completed && _isToday(l.date))).length}/${habits.length}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text('Daily Habits', style: AppTextStyles.heading3),
                const SizedBox(height: 12),

                ...habits.map((habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key(habit.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => ref
                            .read(habitProvider.notifier)
                            .deleteHabit(habit.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        child: HabitTile(
                          habit: habit,
                          onToggle: () => ref
                              .read(habitProvider.notifier)
                              .toggleTodayLog(habit.id),
                        ),
                      ),
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showAddHabit(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Habit'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Drink 8 glasses of water',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(habitProvider.notifier).addHabit(
                      Habit(name: controller.text.trim()),
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white.withOpacity(0.8))),
      ],
    );
  }
}
