import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/models/time_block.dart';
import 'package:flowora/providers/time_block_provider.dart';

class AddTimeBlockScreen extends ConsumerStatefulWidget {
  const AddTimeBlockScreen({super.key});

  @override
  ConsumerState<AddTimeBlockScreen> createState() =>
      _AddTimeBlockScreenState();
}

class _AddTimeBlockScreenState extends ConsumerState<AddTimeBlockScreen> {
  final _labelController = TextEditingController();
  String _type = 'Work';
  bool _isTask = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(timeBlockProvider.notifier).addBlock(
          TimeBlock(
            date: _date,
            startHour: _startTime.hour,
            startMinute: _startTime.minute,
            endHour: _endTime.hour,
            endMinute: _endTime.minute,
            type: _isTask ? 'Task' : _type,
            label: _labelController.text.trim(),
            isTask: _isTask,
          ),
        );
    context.pop();
  }

  Future<void> _pickTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Time Block', style: AppTextStyles.heading3),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save',
                style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: 'Label (optional)',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 24),

            // Task toggle
            SwitchListTile(
              title: const Text('This is a task'),
              subtitle: const Text('Tasks show completion status'),
              value: _isTask,
              onChanged: (v) => setState(() => _isTask = v),
              secondary: Icon(
                _isTask ? Icons.check_circle : Icons.schedule,
                color: _isTask ? AppColors.success : AppColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            const SizedBox(height: 24),

            if (!_isTask) ...[
            Text('Type', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.blockTypes.map((type) {
                final selected = _type == type;
                final block = TimeBlock(
                  date: DateTime.now(),
                  startHour: 0,
                  startMinute: 0,
                  endHour: 1,
                  endMinute: 0,
                  type: type,
                );
                return GestureDetector(
                  onTap: () => setState(() => _type = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? block.color.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? block.color
                            : AppColors.textGrey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      type,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: selected ? block.color : AppColors.textGrey,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ],

            Text('Time', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () => _pickTime(true),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor:
                        Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListTile(
                    title: const Text('End'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () => _pickTime(false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor:
                        Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
