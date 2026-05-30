import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/models/expense.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/core/utils/date_utils.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final box = await Hive.openBox(AppConstants.expensesBox);
    final expenses = box.values
        .map((e) => Expense.fromJson(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    state = expenses..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _saveExpenses() async {
    final box = await Hive.openBox(AppConstants.expensesBox);
    await box.clear();
    for (final expense in state) {
      await box.put(expense.id, jsonEncode(expense.toJson()));
    }
  }

  void addExpense(Expense expense) {
    state = [expense, ...state];
    _saveExpenses();
  }

  void updateExpense(Expense updated) {
    state = state.map((e) => e.id == updated.id ? updated : e).toList();
    _saveExpenses();
  }

  void deleteExpense(String id) {
    state = state.where((e) => e.id != id).toList();
    _saveExpenses();
  }
}

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier();
});

final todayExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseProvider);
  final today = DateTime.now();
  return expenses
      .where((e) => AppDateUtils.isSameDay(e.date, today))
      .fold(0.0, (sum, e) => sum + e.amount);
});

final weekExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseProvider);
  final weekStart = AppDateUtils.startOfWeek(DateTime.now());
  return expenses
      .where((e) => e.date.isAfter(weekStart))
      .fold(0.0, (sum, e) => sum + e.amount);
});

final monthExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  return expenses
      .where((e) => e.date.isAfter(monthStart))
      .fold(0.0, (sum, e) => sum + e.amount);
});

final categoryExpensesProvider =
    Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expenseProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final thisMonth = expenses.where((e) => e.date.isAfter(monthStart));

  final map = <String, double>{};
  for (final e in thisMonth) {
    map[e.category] = (map[e.category] ?? 0) + e.amount;
  }
  return map;
});
