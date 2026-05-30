import 'package:flutter/material.dart';
import 'package:flowora/models/time_block.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/utils/date_utils.dart';

class TimeBlockCard extends StatelessWidget {
  final TimeBlock block;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const TimeBlockCard({
    super.key,
    required this.block,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusClr = block.statusColor;
    final typeClr = block.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: typeClr.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusClr.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            // Status indicator bar
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: statusClr,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Completion checkbox for all blocks
            if (onToggleComplete != null) ...[
              GestureDetector(
                onTap: onToggleComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: block.isComplete ? AppColors.success : Colors.transparent,
                    border: Border.all(
                      color: block.isComplete ? AppColors.success : AppColors.textGrey,
                      width: 2,
                    ),
                  ),
                  child: block.isComplete
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.label.isNotEmpty ? block.label : block.type,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: block.isComplete ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${AppDateUtils.formatTimeOfDay(block.startHour, block.startMinute)} - ${AppDateUtils.formatTimeOfDay(block.endHour, block.endMinute)}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: block.status),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: typeClr.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                block.isTask ? 'Task' : block.type,
                style: AppTextStyles.label.copyWith(color: typeClr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BlockStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status) {
      case BlockStatus.completed:
        label = 'Done';
        color = AppColors.success;
        break;
      case BlockStatus.upcoming:
        label = 'Upcoming';
        color = AppColors.textGrey;
        break;
      case BlockStatus.inProgress:
        label = 'Now';
        color = AppColors.primary;
        break;
      case BlockStatus.missed:
        label = 'Missed';
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
