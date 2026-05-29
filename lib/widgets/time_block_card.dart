import 'package:flutter/material.dart';
import 'package:flowora/models/time_block.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/utils/date_utils.dart';

class TimeBlockCard extends StatelessWidget {
  final TimeBlock block;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TimeBlockCard({
    super.key,
    required this.block,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: block.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: block.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: block.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.label.isNotEmpty ? block.label : block.type,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: block.color,
                    ),
                  ),
                  Text(
                    '${AppDateUtils.formatTimeOfDay(block.startHour, block.startMinute)} - ${AppDateUtils.formatTimeOfDay(block.endHour, block.endMinute)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: block.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                block.type,
                style: AppTextStyles.label.copyWith(color: block.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
