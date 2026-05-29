import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/models/task.dart';
import 'package:flowora/providers/task_provider.dart';
import 'package:flowora/widgets/task_card.dart';
import 'package:flowora/widgets/empty_state.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Task> _filterTasks(List<Task> tasks, int tabIndex) {
    List<Task> filtered;
    switch (tabIndex) {
      case 0: // All
        filtered = tasks.where((t) => !t.isComplete).toList();
        break;
      case 1: // Today
        final today = DateTime.now();
        filtered = tasks.where((t) {
          if (t.isComplete || t.dueDate == null) return false;
          return t.dueDate!.year == today.year &&
              t.dueDate!.month == today.month &&
              t.dueDate!.day == today.day;
        }).toList();
        break;
      case 2: // Completed
        filtered = tasks.where((t) => t.isComplete).toList();
        break;
      default:
        filtered = tasks;
    }

    if (_filterCategory != null) {
      filtered =
          filtered.where((t) => t.category == _filterCategory).toList();
    }

    filtered.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: AppTextStyles.heading2),
        actions: [
          PopupMenuButton<TaskCategory?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (cat) => setState(() => _filterCategory = cat),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(
                  value: TaskCategory.work, child: Text('Work')),
              const PopupMenuItem(
                  value: TaskCategory.personal, child: Text('Personal')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Today'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (tabIndex) {
          final filtered = _filterTasks(tasks, tabIndex);
          if (filtered.isEmpty) {
            return EmptyState(
              icon: tabIndex == 2
                  ? Icons.celebration
                  : Icons.check_circle_outline,
              title: tabIndex == 2
                  ? 'No completed tasks'
                  : 'All clear!',
              subtitle: tabIndex == 2
                  ? 'Completed tasks will appear here'
                  : 'Add a task to get started',
              buttonText: tabIndex != 2 ? 'Add Task' : null,
              onButtonTap:
                  tabIndex != 2 ? () => context.push('/tasks/add') : null,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final task = filtered[index];
              return TaskCard(
                task: task,
                onToggle: () =>
                    ref.read(taskProvider.notifier).toggleComplete(task.id),
                onTap: () => context.push('/tasks/edit', extra: task.id),
                onDelete: () =>
                    ref.read(taskProvider.notifier).deleteTask(task.id),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
