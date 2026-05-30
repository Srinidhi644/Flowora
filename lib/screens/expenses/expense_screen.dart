import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/models/expense.dart';
import 'package:flowora/providers/expense_provider.dart';
import 'package:flowora/widgets/empty_state.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final todayTotal = ref.watch(todayExpensesProvider);
    final weekTotal = ref.watch(weekExpensesProvider);
    final monthTotal = ref.watch(monthExpensesProvider);
    final categoryTotals = ref.watch(categoryExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses', style: AppTextStyles.heading2),
      ),
      body: expenses.isEmpty
          ? EmptyState(
              icon: Icons.account_balance_wallet,
              title: 'No expenses yet',
              subtitle: 'Track your daily spending',
              buttonText: 'Add Expense',
              onButtonTap: () => _showAddExpense(context, ref),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Summary cards
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('This Month',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${monthTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _MiniStat(
                              label: 'Today', value: '₹${todayTotal.toStringAsFixed(0)}'),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _MiniStat(
                              label: 'This Week', value: '₹${weekTotal.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category breakdown
                if (categoryTotals.isNotEmpty) ...[
                  Text('By Category', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  ...categoryTotals.entries.map((entry) {
                    final percent = monthTotal > 0
                        ? (entry.value / monthTotal)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(_categoryIcon(entry.key),
                                color: _categoryColor(entry.key), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key, style: AppTextStyles.bodyMedium),
                                      Text('₹${entry.value.toStringAsFixed(0)}',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: percent,
                                    backgroundColor:
                                        AppColors.textGrey.withOpacity(0.2),
                                    color: _categoryColor(entry.key),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Recent expenses
                Text('Recent', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                ...expenses.take(20).map((expense) => Dismissible(
                      key: Key(expense.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) =>
                          ref.read(expenseProvider.notifier).deleteExpense(expense.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _categoryColor(expense.category)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _categoryIcon(expense.category),
                                color: _categoryColor(expense.category),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense.title,
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(fontWeight: FontWeight.w600)),
                                  Text(
                                    '${expense.category} · ${DateFormat('MMM d').format(expense.date)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${expense.amount.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpense(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpense(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String category = 'Groceries';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Expense', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What did you spend on?',
                  prefixIcon: Icon(Icons.receipt_long),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.expenseCategories.map((c) {
                  final selected = category == c;
                  return ChoiceChip(
                    label: Text(c, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) => setSheetState(() => category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  hintText: 'Note (optional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty ||
                        amountCtrl.text.trim().isEmpty) return;
                    ref.read(expenseProvider.notifier).addExpense(
                          Expense(
                            title: titleCtrl.text.trim(),
                            amount:
                                double.tryParse(amountCtrl.text.trim()) ?? 0,
                            category: category,
                            note: noteCtrl.text.trim().isEmpty
                                ? null
                                : noteCtrl.text.trim(),
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Groceries': return AppColors.success;
      case 'Dining Out': return AppColors.cooking;
      case 'Transport': return AppColors.info;
      case 'Shopping': return AppColors.primary;
      case 'Bills': return AppColors.warning;
      case 'Health': return AppColors.error;
      case 'Entertainment': return AppColors.primaryLight;
      default: return AppColors.textGrey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Groceries': return Icons.shopping_cart;
      case 'Dining Out': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Shopping': return Icons.shopping_bag;
      case 'Bills': return Icons.receipt;
      case 'Health': return Icons.medical_services;
      case 'Entertainment': return Icons.movie;
      default: return Icons.attach_money;
    }
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
