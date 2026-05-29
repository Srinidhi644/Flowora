import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/providers/task_provider.dart';
import 'package:flowora/providers/time_block_provider.dart';
import 'package:flowora/providers/habit_provider.dart';
import 'package:flowora/providers/meal_plan_provider.dart';
import 'package:flowora/providers/recipe_provider.dart';
import 'package:flowora/providers/shopping_list_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') return 0;
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/time-blocks')) return 2;
    if (location.startsWith('/recipes')) return 3;
    if (location.startsWith('/habits')) return 4;
    return 0;
  }

  void _refreshAllProviders(WidgetRef ref) {
    ref.invalidate(taskProvider);
    ref.invalidate(timeBlockProvider);
    ref.invalidate(habitProvider);
    ref.invalidate(mealPlanProvider);
    ref.invalidate(recipeProvider);
    ref.invalidate(shoppingListProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          // Refresh providers when switching tabs so data is always fresh
          _refreshAllProviders(ref);

          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/tasks');
              break;
            case 2:
              context.go('/time-blocks');
              break;
            case 3:
              context.go('/recipes');
              break;
            case 4:
              context.go('/habits');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_day_outlined),
            selectedIcon: Icon(Icons.calendar_view_day),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Habits',
          ),
        ],
      ),
    );
  }
}
