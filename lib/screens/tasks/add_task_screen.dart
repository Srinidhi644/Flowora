import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/models/task.dart';
import 'package:flowora/providers/task_provider.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const AddTaskScreen({super.key, this.taskId});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.personal;
  RecurrenceType _recurrence = RecurrenceType.none;

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final task =
          ref.read(taskProvider).firstWhere((t) => t.id == widget.taskId);
      _titleController.text = task.title;
      _descController.text = task.description;
      _dueDate = task.dueDate;
      _priority = task.priority;
      _category = task.category;
      _recurrence = task.recurrence;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    if (_isEditing) {
      final existing =
          ref.read(taskProvider).firstWhere((t) => t.id == widget.taskId);
      ref.read(taskProvider.notifier).updateTask(
            existing.copyWith(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              dueDate: _dueDate,
              priority: _priority,
              category: _category,
              recurrence: _recurrence,
            ),
          );
    } else {
      ref.read(taskProvider.notifier).addTask(
            Task(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              dueDate: _dueDate,
              priority: _priority,
              category: _category,
              recurrence: _recurrence,
            ),
          );
    }
    context.pop();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: AppTextStyles.heading3,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              style: AppTextStyles.heading3,
              decoration: const InputDecoration(
                hintText: 'Task title',
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
            ),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 24),

            // Due date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_dueDate != null
                  ? DateFormat('EEE, MMM d, y').format(_dueDate!)
                  : 'Set due date'),
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _dueDate = null),
                    )
                  : null,
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            const SizedBox(height: 12),

            // Priority
            Text('Priority', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((p) {
                final selected = _priority == p;
                final color = p == TaskPriority.high
                    ? AppColors.priorityHigh
                    : p == TaskPriority.medium
                        ? AppColors.priorityMedium
                        : AppColors.priorityLow;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? color : AppColors.textGrey.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        p.name[0].toUpperCase() + p.name.substring(1),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: selected ? color : AppColors.textGrey,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Category
            Text('Category', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                _CategoryChip(
                  label: 'Personal',
                  selected: _category == TaskCategory.personal,
                  color: AppColors.personal,
                  onTap: () =>
                      setState(() => _category = TaskCategory.personal),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Work',
                  selected: _category == TaskCategory.work,
                  color: AppColors.work,
                  onTap: () => setState(() => _category = TaskCategory.work),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recurrence
            Text('Repeat', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RecurrenceType.values.map((r) {
                final selected = _recurrence == r;
                return ChoiceChip(
                  label: Text(r.name[0].toUpperCase() + r.name.substring(1)),
                  selected: selected,
                  onSelected: (_) => setState(() => _recurrence = r),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : AppColors.textGrey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: selected ? color : AppColors.textGrey,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
