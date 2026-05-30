class AppConstants {
  AppConstants._();

  static const String appName = 'Flowora';
  static const String appTagline = 'Day. Work. Cooking.';

  // Hive box names
  static const String tasksBox = 'tasks';
  static const String recipesBox = 'recipes';
  static const String timeBlocksBox = 'timeBlocks';
  static const String habitsBox = 'habits';
  static const String mealPlanBox = 'mealPlan';
  static const String shoppingListBox = 'shoppingList';
  static const String inventoryBox = 'inventory';
  static const String expensesBox = 'expenses';
  static const String settingsBox = 'settings';

  // Settings keys
  static const String keyDarkMode = 'darkMode';
  static const String keyUserName = 'userName';
  static const String keyDietaryPref = 'dietaryPreference';
  static const String keyWakeTime = 'wakeTime';
  static const String keySleepTime = 'sleepTime';
  static const String keyOnboardingComplete = 'onboardingComplete';

  // Time block types
  static const List<String> blockTypes = [
    'Work',
    'Deep Work',
    'Cooking',
    'Exercise',
    'Rest',
    'Personal',
  ];

  // Dietary preferences
  static const List<String> dietaryPreferences = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Eggetarian',
    'No Preference',
  ];

  // Meal types
  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  // Expense categories
  static const List<String> expenseCategories = [
    'Groceries',
    'Dining Out',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment',
    'Other',
  ];
}
