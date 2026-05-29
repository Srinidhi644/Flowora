import 'package:flowora/models/task.dart';
import 'package:flowora/models/recipe.dart';
import 'package:flowora/models/time_block.dart';
import 'package:flowora/models/habit.dart';
import 'package:flowora/models/meal_plan.dart';
import 'package:flowora/models/shopping_item.dart';

class SeedData {
  SeedData._();

  static final DateTime _today = DateTime.now();
  static DateTime _date(int daysFromToday) =>
      DateTime(_today.year, _today.month, _today.day + daysFromToday);

  // ─── Tasks ───────────────────────────────────────────────

  static List<Task> get tasks => [
        Task(
          title: 'Review project proposal',
          description: 'Go through the Q3 project proposal and add comments',
          dueDate: _date(0),
          priority: TaskPriority.high,
          category: TaskCategory.work,
        ),
        Task(
          title: 'Buy groceries for the week',
          description: 'Check the shopping list before heading out',
          dueDate: _date(0),
          priority: TaskPriority.medium,
          category: TaskCategory.personal,
        ),
        Task(
          title: 'Fix login page bug',
          description: 'Users report password reset link not working',
          dueDate: _date(0),
          priority: TaskPriority.high,
          category: TaskCategory.work,
        ),
        Task(
          title: 'Call dentist for appointment',
          dueDate: _date(1),
          priority: TaskPriority.low,
          category: TaskCategory.personal,
        ),
        Task(
          title: 'Prepare sprint demo slides',
          description: 'Include metrics and screenshots',
          dueDate: _date(1),
          priority: TaskPriority.high,
          category: TaskCategory.work,
        ),
        Task(
          title: 'Water the plants',
          dueDate: _date(0),
          priority: TaskPriority.low,
          category: TaskCategory.personal,
          isComplete: true,
        ),
        Task(
          title: 'Reply to client email',
          description: 'Follow up on the integration timeline',
          dueDate: _date(0),
          priority: TaskPriority.medium,
          category: TaskCategory.work,
          isComplete: true,
        ),
        Task(
          title: 'Update portfolio website',
          dueDate: _date(2),
          priority: TaskPriority.low,
          category: TaskCategory.personal,
        ),
        Task(
          title: 'Team standup notes',
          description: 'Summarize blockers and action items',
          dueDate: _date(-1),
          priority: TaskPriority.medium,
          category: TaskCategory.work,
        ),
        Task(
          title: 'Renew gym membership',
          dueDate: _date(3),
          priority: TaskPriority.medium,
          category: TaskCategory.personal,
        ),
      ];

  // ─── Recipes ─────────────────────────────────────────────

  static final List<Recipe> recipes = [
    Recipe(
      name: 'Paneer Butter Masala',
      ingredients: [
        const Ingredient(name: 'Paneer', quantity: '250', unit: 'g'),
        const Ingredient(name: 'Tomato', quantity: '4', unit: 'medium'),
        const Ingredient(name: 'Butter', quantity: '3', unit: 'tbsp'),
        const Ingredient(name: 'Cream', quantity: '100', unit: 'ml'),
        const Ingredient(name: 'Onion', quantity: '2', unit: 'medium'),
        const Ingredient(name: 'Ginger-garlic paste', quantity: '1', unit: 'tbsp'),
        const Ingredient(name: 'Garam masala', quantity: '1', unit: 'tsp'),
        const Ingredient(name: 'Kashmiri red chilli', quantity: '1', unit: 'tsp'),
      ],
      steps: [
        'Blend tomatoes, onions, and cashews into a smooth paste.',
        'Heat butter in a pan, add ginger-garlic paste and saut\u00e9.',
        'Add the tomato-onion paste and cook for 8-10 minutes.',
        'Add spices: garam masala, red chilli powder, salt, and sugar.',
        'Add cubed paneer and mix gently.',
        'Pour in cream, simmer for 5 minutes. Serve hot with naan.',
      ],
      prepTimeMinutes: 15,
      cookTimeMinutes: 25,
      servings: 4,
      tags: ['Indian', 'Vegetarian', 'Dinner'],
      dietaryType: 'Vegetarian',
    ),
    Recipe(
      name: 'Chicken Fried Rice',
      ingredients: [
        const Ingredient(name: 'Cooked rice', quantity: '3', unit: 'cups'),
        const Ingredient(name: 'Chicken breast', quantity: '200', unit: 'g'),
        const Ingredient(name: 'Egg', quantity: '2', unit: ''),
        const Ingredient(name: 'Soy sauce', quantity: '2', unit: 'tbsp'),
        const Ingredient(name: 'Spring onion', quantity: '4', unit: 'stalks'),
        const Ingredient(name: 'Garlic', quantity: '4', unit: 'cloves'),
        const Ingredient(name: 'Carrot', quantity: '1', unit: 'medium'),
        const Ingredient(name: 'Oil', quantity: '2', unit: 'tbsp'),
      ],
      steps: [
        'Dice chicken and vegetables. Mince garlic.',
        'Heat oil on high flame, scramble eggs and set aside.',
        'Cook chicken until golden brown, about 5 minutes.',
        'Add garlic and vegetables, stir-fry for 2 minutes.',
        'Add cold rice and soy sauce, toss everything on high heat.',
        'Mix in scrambled eggs and spring onions. Serve hot.',
      ],
      prepTimeMinutes: 10,
      cookTimeMinutes: 15,
      servings: 3,
      tags: ['Asian', 'Quick', 'Lunch'],
      dietaryType: 'Non-Vegetarian',
    ),
    Recipe(
      name: 'Masala Dosa',
      ingredients: [
        const Ingredient(name: 'Dosa batter', quantity: '2', unit: 'cups'),
        const Ingredient(name: 'Potato', quantity: '3', unit: 'medium'),
        const Ingredient(name: 'Onion', quantity: '2', unit: 'medium'),
        const Ingredient(name: 'Green chilli', quantity: '2', unit: ''),
        const Ingredient(name: 'Mustard seeds', quantity: '1', unit: 'tsp'),
        const Ingredient(name: 'Curry leaves', quantity: '8', unit: ''),
        const Ingredient(name: 'Turmeric', quantity: '1/2', unit: 'tsp'),
        const Ingredient(name: 'Oil', quantity: '2', unit: 'tbsp'),
      ],
      steps: [
        'Boil and mash potatoes. Chop onions and green chillies.',
        'Heat oil, add mustard seeds and curry leaves until they splutter.',
        'Add onions and green chillies, saut\u00e9 until golden.',
        'Add turmeric and mashed potatoes, mix well. Season with salt.',
        'Heat a tawa, pour dosa batter and spread thin.',
        'Cook until crispy, add potato filling, fold and serve with chutney.',
      ],
      prepTimeMinutes: 20,
      cookTimeMinutes: 20,
      servings: 4,
      tags: ['South Indian', 'Vegetarian', 'Breakfast'],
      dietaryType: 'Vegetarian',
    ),
    Recipe(
      name: 'Overnight Oats',
      ingredients: [
        const Ingredient(name: 'Rolled oats', quantity: '1/2', unit: 'cup'),
        const Ingredient(name: 'Milk', quantity: '1/2', unit: 'cup'),
        const Ingredient(name: 'Yogurt', quantity: '1/4', unit: 'cup'),
        const Ingredient(name: 'Honey', quantity: '1', unit: 'tbsp'),
        const Ingredient(name: 'Chia seeds', quantity: '1', unit: 'tsp'),
        const Ingredient(name: 'Banana', quantity: '1', unit: ''),
        const Ingredient(name: 'Mixed berries', quantity: '1/4', unit: 'cup'),
      ],
      steps: [
        'Mix oats, milk, yogurt, honey, and chia seeds in a jar.',
        'Stir well, cover and refrigerate overnight.',
        'In the morning, top with sliced banana and berries.',
        'Enjoy cold or microwave for 1 minute if you prefer warm.',
      ],
      prepTimeMinutes: 5,
      cookTimeMinutes: 0,
      servings: 1,
      tags: ['Healthy', 'Quick', 'Breakfast', 'No Cook'],
      dietaryType: 'Vegetarian',
    ),
    Recipe(
      name: 'Egg Bhurji',
      ingredients: [
        const Ingredient(name: 'Eggs', quantity: '4', unit: ''),
        const Ingredient(name: 'Onion', quantity: '1', unit: 'medium'),
        const Ingredient(name: 'Tomato', quantity: '1', unit: 'medium'),
        const Ingredient(name: 'Green chilli', quantity: '2', unit: ''),
        const Ingredient(name: 'Turmeric', quantity: '1/4', unit: 'tsp'),
        const Ingredient(name: 'Coriander leaves', quantity: '2', unit: 'tbsp'),
        const Ingredient(name: 'Oil', quantity: '1', unit: 'tbsp'),
      ],
      steps: [
        'Chop onions, tomatoes, green chillies, and coriander.',
        'Heat oil, add onions and saut\u00e9 until translucent.',
        'Add tomatoes and green chillies, cook for 2 minutes.',
        'Beat eggs with turmeric and salt, pour into the pan.',
        'Scramble on medium heat until eggs are cooked through.',
        'Garnish with coriander. Serve with toast or roti.',
      ],
      prepTimeMinutes: 5,
      cookTimeMinutes: 10,
      servings: 2,
      tags: ['Indian', 'Quick', 'Breakfast'],
      dietaryType: 'Eggetarian',
    ),
    Recipe(
      name: 'Dal Tadka',
      ingredients: [
        const Ingredient(name: 'Toor dal', quantity: '1', unit: 'cup'),
        const Ingredient(name: 'Tomato', quantity: '2', unit: 'medium'),
        const Ingredient(name: 'Onion', quantity: '1', unit: 'medium'),
        const Ingredient(name: 'Ghee', quantity: '2', unit: 'tbsp'),
        const Ingredient(name: 'Cumin seeds', quantity: '1', unit: 'tsp'),
        const Ingredient(name: 'Garlic', quantity: '4', unit: 'cloves'),
        const Ingredient(name: 'Red chilli', quantity: '2', unit: 'dried'),
        const Ingredient(name: 'Turmeric', quantity: '1/2', unit: 'tsp'),
      ],
      steps: [
        'Wash dal and pressure cook with turmeric for 3-4 whistles.',
        'Mash the cooked dal and set aside.',
        'Heat ghee, add cumin seeds, garlic, and dried red chillies.',
        'Add chopped onions, saut\u00e9 until golden brown.',
        'Add tomatoes and cook until soft.',
        'Pour the tadka over the dal, mix well. Serve with rice or roti.',
      ],
      prepTimeMinutes: 10,
      cookTimeMinutes: 25,
      servings: 4,
      tags: ['Indian', 'Vegetarian', 'Comfort Food', 'Dinner'],
      dietaryType: 'Vegetarian',
    ),
  ];

  // ─── Time Blocks ─────────────────────────────────────────

  static List<TimeBlock> get timeBlocks => [
        TimeBlock(
          date: _date(0),
          startHour: 6,
          startMinute: 30,
          endHour: 7,
          endMinute: 0,
          type: 'Exercise',
          label: 'Morning Run',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 7,
          startMinute: 30,
          endHour: 8,
          endMinute: 0,
          type: 'Cooking',
          label: 'Breakfast Prep',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 9,
          startMinute: 0,
          endHour: 11,
          endMinute: 30,
          type: 'Deep Work',
          label: 'Feature Development',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 11,
          startMinute: 30,
          endHour: 12,
          endMinute: 0,
          type: 'Work',
          label: 'Team Standup',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 13,
          startMinute: 0,
          endHour: 15,
          endMinute: 0,
          type: 'Work',
          label: 'Code Reviews & PRs',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 15,
          startMinute: 0,
          endHour: 15,
          endMinute: 30,
          type: 'Rest',
          label: 'Coffee Break',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 15,
          startMinute: 30,
          endHour: 17,
          endMinute: 30,
          type: 'Deep Work',
          label: 'Bug Fixes',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 18,
          startMinute: 30,
          endHour: 19,
          endMinute: 15,
          type: 'Cooking',
          label: 'Dinner - Paneer Butter Masala',
        ),
        TimeBlock(
          date: _date(0),
          startHour: 20,
          startMinute: 0,
          endHour: 21,
          endMinute: 0,
          type: 'Personal',
          label: 'Reading / Learning',
        ),
        // Tomorrow
        TimeBlock(
          date: _date(1),
          startHour: 7,
          startMinute: 0,
          endHour: 7,
          endMinute: 45,
          type: 'Exercise',
          label: 'Gym - Upper Body',
        ),
        TimeBlock(
          date: _date(1),
          startHour: 9,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
          type: 'Deep Work',
          label: 'Sprint Tasks',
        ),
        TimeBlock(
          date: _date(1),
          startHour: 14,
          startMinute: 0,
          endHour: 15,
          endMinute: 0,
          type: 'Work',
          label: 'Sprint Demo',
        ),
      ];

  // ─── Habits ──────────────────────────────────────────────

  static List<Habit> get habits {
    final now = DateTime.now();
    return [
      Habit(
        name: 'Drink 8 glasses of water',
        icon: 'water_drop',
        type: HabitType.quantity,
        targetValue: 8,
        unit: 'glasses',
        logs: List.generate(7, (i) {
          final date = now.subtract(Duration(days: i));
          return HabitLog(date: date, completed: i < 5, value: i < 5 ? 8 : 3);
        }),
      ),
      Habit(
        name: 'Exercise 30 minutes',
        icon: 'fitness_center',
        logs: List.generate(7, (i) {
          final date = now.subtract(Duration(days: i));
          return HabitLog(date: date, completed: i != 2 && i != 5);
        }),
      ),
      Habit(
        name: 'Read for 20 minutes',
        icon: 'menu_book',
        logs: List.generate(7, (i) {
          final date = now.subtract(Duration(days: i));
          return HabitLog(date: date, completed: i < 4);
        }),
      ),
      Habit(
        name: 'Meditate',
        icon: 'self_improvement',
        logs: List.generate(7, (i) {
          final date = now.subtract(Duration(days: i));
          return HabitLog(date: date, completed: i < 3);
        }),
      ),
      Habit(
        name: 'No junk food',
        icon: 'no_food',
        logs: List.generate(7, (i) {
          final date = now.subtract(Duration(days: i));
          return HabitLog(date: date, completed: i != 3);
        }),
      ),
    ];
  }

  // ─── Meal Plans (this week) ──────────────────────────────

  static List<MealPlan> mealPlans(List<Recipe> seededRecipes) {
    // Map recipe names to IDs for easy lookup
    String id(String name) =>
        seededRecipes.firstWhere((r) => r.name == name).id;

    return [
      MealPlan(
        date: _date(0),
        breakfastRecipeId: id('Overnight Oats'),
        lunchRecipeId: id('Chicken Fried Rice'),
        dinnerRecipeId: id('Paneer Butter Masala'),
        snackRecipeId: null,
      ),
      MealPlan(
        date: _date(1),
        breakfastRecipeId: id('Masala Dosa'),
        lunchRecipeId: id('Dal Tadka'),
        dinnerRecipeId: id('Chicken Fried Rice'),
        snackRecipeId: null,
      ),
      MealPlan(
        date: _date(2),
        breakfastRecipeId: id('Egg Bhurji'),
        lunchRecipeId: null,
        dinnerRecipeId: id('Dal Tadka'),
        snackRecipeId: null,
      ),
      MealPlan(
        date: _date(3),
        breakfastRecipeId: id('Overnight Oats'),
        lunchRecipeId: id('Paneer Butter Masala'),
        dinnerRecipeId: null,
        snackRecipeId: null,
      ),
    ];
  }

  // ─── Shopping List ───────────────────────────────────────

  static final List<ShoppingItem> shoppingItems = [
    ShoppingItem(
      name: 'Paneer',
      quantity: '250',
      unit: 'g',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Tomatoes',
      quantity: '6',
      unit: '',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Onions',
      quantity: '5',
      unit: '',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Butter',
      quantity: '1',
      unit: 'pack',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Fresh cream',
      quantity: '200',
      unit: 'ml',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Chicken breast',
      quantity: '500',
      unit: 'g',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Eggs',
      quantity: '6',
      unit: '',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Rolled oats',
      quantity: '1',
      unit: 'pack',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Mixed berries',
      quantity: '1',
      unit: 'pack',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Toor dal',
      quantity: '500',
      unit: 'g',
      source: ShoppingItemSource.auto,
    ),
    ShoppingItem(
      name: 'Bananas',
      quantity: '6',
      unit: '',
      source: ShoppingItemSource.manual,
    ),
    ShoppingItem(
      name: 'Milk',
      quantity: '1',
      unit: 'litre',
      source: ShoppingItemSource.manual,
    ),
    ShoppingItem(
      name: 'Bread',
      quantity: '1',
      unit: 'loaf',
      source: ShoppingItemSource.manual,
    ),
    ShoppingItem(
      name: 'Curd',
      quantity: '500',
      unit: 'g',
      source: ShoppingItemSource.manual,
    ),
    ShoppingItem(
      name: 'Rice',
      quantity: '2',
      unit: 'kg',
      source: ShoppingItemSource.manual,
      isChecked: true,
    ),
    ShoppingItem(
      name: 'Oil',
      quantity: '1',
      unit: 'litre',
      source: ShoppingItemSource.manual,
      isChecked: true,
    ),
  ];
}
