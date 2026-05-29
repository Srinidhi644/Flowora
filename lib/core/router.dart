import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/services/api_client.dart';
import 'package:flowora/services/storage_service.dart';
import 'package:flowora/screens/onboarding/onboarding_screen.dart';
import 'package:flowora/screens/auth/login_screen.dart';
import 'package:flowora/screens/dashboard/dashboard_screen.dart';
import 'package:flowora/screens/tasks/task_list_screen.dart';
import 'package:flowora/screens/tasks/add_task_screen.dart';
import 'package:flowora/screens/time_blocks/time_block_screen.dart';
import 'package:flowora/screens/time_blocks/add_time_block_screen.dart';
import 'package:flowora/screens/recipes/recipe_list_screen.dart';
import 'package:flowora/screens/recipes/recipe_detail_screen.dart';
import 'package:flowora/screens/recipes/add_recipe_screen.dart';
import 'package:flowora/screens/meal_planner/meal_planner_screen.dart';
import 'package:flowora/screens/shopping_list/shopping_list_screen.dart';
import 'package:flowora/screens/habits/habit_screen.dart';
import 'package:flowora/screens/settings/settings_screen.dart';
import 'package:flowora/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final onboardingDone = await StorageService.isOnboardingComplete();
      final loggedIn = ApiClient.isLoggedIn;
      final path = state.uri.toString();

      if (!onboardingDone && path != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingDone && !loggedIn && path != '/login' && path != '/onboarding') {
        return '/login';
      }
      if (loggedIn && (path == '/login' || path == '/onboarding')) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListScreen(),
          ),
          GoRoute(
            path: '/time-blocks',
            builder: (context, state) => const TimeBlockScreen(),
          ),
          GoRoute(
            path: '/recipes',
            builder: (context, state) => const RecipeListScreen(),
          ),
          GoRoute(
            path: '/habits',
            builder: (context, state) => const HabitScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/tasks/add',
        builder: (context, state) => const AddTaskScreen(),
      ),
      GoRoute(
        path: '/tasks/edit',
        builder: (context, state) {
          final taskId = state.extra as String;
          return AddTaskScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/time-blocks/add',
        builder: (context, state) => const AddTimeBlockScreen(),
      ),
      GoRoute(
        path: '/recipes/add',
        builder: (context, state) => const AddRecipeScreen(),
      ),
      GoRoute(
        path: '/recipes/edit',
        builder: (context, state) {
          final recipeId = state.extra as String;
          return AddRecipeScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/recipes/detail',
        builder: (context, state) {
          final recipeId = state.extra as String;
          return RecipeDetailScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/meal-planner',
        builder: (context, state) => const MealPlannerScreen(),
      ),
      GoRoute(
        path: '/shopping-list',
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
