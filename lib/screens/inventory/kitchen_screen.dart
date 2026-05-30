import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/providers/shopping_list_provider.dart';
import 'package:flowora/screens/inventory/inventory_screen.dart';
import 'package:flowora/screens/shopping_list/shopping_list_screen.dart';

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Refresh shared data from API
    Future.microtask(() {
      ref.read(shoppingListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory_2),
              text: 'Inventory',
            ),
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'Shopping List',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _InventoryTab(),
          _ShoppingTab(),
        ],
      ),
    );
  }
}

/// Inventory tab — reuses inventory screen body without its own scaffold/appbar
class _InventoryTab extends ConsumerWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const InventoryScreen(embedded: true);
  }
}

/// Shopping tab — reuses shopping list screen body without its own scaffold/appbar
class _ShoppingTab extends ConsumerWidget {
  const _ShoppingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ShoppingListScreen(embedded: true);
  }
}
