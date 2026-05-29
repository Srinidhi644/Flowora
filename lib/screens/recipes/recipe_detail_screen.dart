import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.read(recipeProvider.notifier).getById(recipeId);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recipe.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              background: Container(
                color: AppColors.cooking.withOpacity(0.1),
                child: Icon(Icons.restaurant,
                    size: 80, color: AppColors.cooking.withOpacity(0.3)),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push('/recipes/edit', extra: recipe.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  ref.read(recipeProvider.notifier).deleteRecipe(recipe.id);
                  context.pop();
                },
              ),
            ],
          ),

          // Info row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _InfoChip(
                    icon: Icons.timer,
                    label: 'Prep',
                    value: '${recipe.prepTimeMinutes} min',
                  ),
                  _InfoChip(
                    icon: Icons.local_fire_department,
                    label: 'Cook',
                    value: '${recipe.cookTimeMinutes} min',
                  ),
                  _InfoChip(
                    icon: Icons.people,
                    label: 'Serves',
                    value: '${recipe.servings}',
                  ),
                  _InfoChip(
                    icon: Icons.schedule,
                    label: 'Total',
                    value: '${recipe.totalTimeMinutes} min',
                  ),
                ],
              ),
            ),
          ),

          // Tags
          if (recipe.tags.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  children: recipe.tags
                      .map((t) => Chip(
                            label: Text(t, style: AppTextStyles.bodySmall),
                            backgroundColor:
                                AppColors.primary.withOpacity(0.1),
                          ))
                      .toList(),
                ),
              ),
            ),

          // Ingredients
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Ingredients', style: AppTextStyles.heading3),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ingredient = recipe.ingredients[index];
                return ListTile(
                  leading: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.cooking,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  dense: true,
                );
              },
              childCount: recipe.ingredients.length,
            ),
          ),

          // Steps
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Steps', style: AppTextStyles.heading3),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(recipe.steps[index],
                            style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                );
              },
              childCount: recipe.steps.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.cooking, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
