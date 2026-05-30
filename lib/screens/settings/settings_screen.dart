import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/core/constants/app_constants.dart';
import 'package:flowora/main.dart';
import 'package:flowora/services/api_client.dart';
import 'package:flowora/services/storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  String _dietaryPref = 'No Preference';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await StorageService.getSetting(AppConstants.keyUserName,
        defaultValue: '');
    final diet = await StorageService.getSetting(AppConstants.keyDietaryPref,
        defaultValue: 'No Preference');
    setState(() {
      _nameController.text = name ?? '';
      _dietaryPref = diet ?? 'No Preference';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.heading2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: AppTextStyles.heading3),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  onChanged: (v) => StorageService.setSetting(
                      AppConstants.keyUserName, v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _dietaryPref,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  items: AppConstants.dietaryPreferences
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _dietaryPref = v);
                      StorageService.setSetting(
                          AppConstants.keyDietaryPref, v);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Appearance
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  value: isDark,
                  onChanged: (v) {
                    ref.read(themeModeProvider.notifier).state =
                        v ? ThemeMode.dark : ThemeMode.light;
                  },
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick links
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Links', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.calendar_month,
                      color: AppColors.cooking),
                  title: const Text('Meal Planner'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/meal-planner'),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart,
                      color: AppColors.primary),
                  title: const Text('Shopping List'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/shopping-list'),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet,
                      color: AppColors.error),
                  title: const Text('Expenses'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/expenses'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                ListTile(
                  leading:
                      const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Delete all tasks, recipes, and plans'),
                  onTap: () => _confirmClear(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Logout'),
                  subtitle: const Text('Sign out of your account'),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          Center(
            child: Column(
              children: [
                Text(AppConstants.appName, style: AppTextStyles.heading3),
                Text('v1.0.0', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(AppConstants.appTagline, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will need to sign in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ApiClient.logout();
              ref.read(authStateProvider.notifier).state = false;
              if (mounted) {
                Navigator.pop(ctx);
                context.go('/login');
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will permanently delete all your tasks, recipes, meal plans, habits, and shopping lists.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await StorageService.clearAll();
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
