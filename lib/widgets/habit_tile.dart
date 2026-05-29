import 'package:flutter/material.dart';
import 'package:flowora/models/habit.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/utils/date_utils.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  bool get _isCompletedToday {
    final today = DateTime.now();
    return habit.logs.any(
      (l) => AppDateUtils.isSameDay(l.date, today) && l.completed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _isCompletedToday;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: completed
              ? AppColors.success.withOpacity(0.1)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: completed
              ? Border.all(color: AppColors.success.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: completed ? AppColors.success : AppColors.textGrey,
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                habit.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: completed ? AppColors.success : null,
                  fontWeight: completed ? FontWeight.w600 : null,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: habit.currentStreak > 0
                          ? AppColors.warning
                          : AppColors.textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: habit.currentStreak > 0
                            ? AppColors.warning
                            : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
