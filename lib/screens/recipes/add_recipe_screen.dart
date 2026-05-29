import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flowora/core/theme/app_colors.dart';
import 'package:flowora/core/theme/app_text_styles.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/providers/recipe_provider.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  final String? recipeId;

  const AddRecipeScreen({super.key, this.recipeId});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _nameController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController(text: '2');
  final List<Ingredient> _ingredients = [];
  final List<String> _steps = [];
  final List<String> _tags = [];

  bool get _isEditing => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final recipe =
          ref.read(recipeProvider.notifier).getById(widget.recipeId!);
      if (recipe != null) {
        _nameController.text = recipe.name;
        _prepTimeController.text = recipe.prepTimeMinutes.toString();
        _cookTimeController.text = recipe.cookTimeMinutes.toString();
        _servingsController.text = recipe.servings.toString();
        _ingredients.addAll(recipe.ingredients);
        _steps.addAll(recipe.steps);
        _tags.addAll(recipe.tags);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;

    final recipe = Recipe(
      id: widget.recipeId,
      name: _nameController.text.trim(),
      ingredients: _ingredients,
      steps: _steps,
      prepTimeMinutes: int.tryParse(_prepTimeController.text) ?? 0,
      cookTimeMinutes: int.tryParse(_cookTimeController.text) ?? 0,
      servings: int.tryParse(_servingsController.text) ?? 2,
      tags: _tags,
    );

    if (_isEditing) {
      ref.read(recipeProvider.notifier).updateRecipe(recipe);
    } else {
      ref.read(recipeProvider.notifier).addRecipe(recipe);
    }
    context.pop();
  }

  void _addIngredient() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: 'Name (e.g. Onion)'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(hintText: 'Qty'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: unitCtrl,
                    decoration:
                        const InputDecoration(hintText: 'Unit (cup, g)'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _ingredients.add(Ingredient(
                    name: nameCtrl.text.trim(),
                    quantity: qtyCtrl.text.trim(),
                    unit: unitCtrl.text.trim(),
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addStep() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Step ${_steps.length + 1}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Describe this step...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _steps.add(controller.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Recipe' : 'New Recipe',
          style: AppTextStyles.heading3,
        ),
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
              controller: _nameController,
              style: AppTextStyles.heading3,
              decoration: const InputDecoration(
                hintText: 'Recipe name',
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 16),

            // Time & servings
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Prep (min)',
                      prefixIcon: Icon(Icons.timer, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _cookTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Cook (min)',
                      prefixIcon:
                          Icon(Icons.local_fire_department, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Serves',
                      prefixIcon: Icon(Icons.people, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ingredients
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ingredients', style: AppTextStyles.heading3),
                IconButton(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                ),
              ],
            ),
            if (_ingredients.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No ingredients added',
                    style: AppTextStyles.bodySmall),
              )
            else
              ...List.generate(_ingredients.length, (i) {
                final ing = _ingredients[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.circle, size: 8),
                  title: Text('${ing.quantity} ${ing.unit} ${ing.name}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () =>
                        setState(() => _ingredients.removeAt(i)),
                  ),
                );
              }),
            const SizedBox(height: 16),

            // Steps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Steps', style: AppTextStyles.heading3),
                IconButton(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                ),
              ],
            ),
            if (_steps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child:
                    Text('No steps added', style: AppTextStyles.bodySmall),
              )
            else
              ...List.generate(_steps.length, (i) {
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text('${i + 1}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary)),
                  ),
                  title: Text(_steps[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _steps.removeAt(i)),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
