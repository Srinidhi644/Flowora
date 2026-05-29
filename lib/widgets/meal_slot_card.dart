import 'package:flutter/material.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';

class MealSlotCard extends StatelessWidget {
  final String mealType;
  final Recipe? recipe;
  final VoidCallback onTap;

  const MealSlotCard({
    super.key,
    required this.mealType,
    this.recipe,
    required this.onTap,
  });

  IconData get _mealIcon {
    switch (mealType) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: recipe == null
              ? Border.all(
                  color: AppColors.textGrey.withOpacity(0.3),
                  style: BorderStyle.solid,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cooking.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_mealIcon, color: AppColors.cooking),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mealType, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(
                    recipe?.name ?? 'Tap to add meal',
                    style: recipe != null
                        ? AppTextStyles.bodyLarge
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textGrey,
                          ),
                  ),
                ],
              ),
            ),
            if (recipe != null)
              Text(
                '${recipe!.totalTimeMinutes} min',
                style: AppTextStyles.bodySmall,
              )
            else
              const Icon(Icons.add, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
