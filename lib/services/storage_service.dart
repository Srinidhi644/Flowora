import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/core/constants/app_constants.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(AppConstants.tasksBox),
      Hive.openBox(AppConstants.recipesBox),
      Hive.openBox(AppConstants.timeBlocksBox),
      Hive.openBox(AppConstants.habitsBox),
      Hive.openBox(AppConstants.mealPlanBox),
      Hive.openBox(AppConstants.shoppingListBox),
      Hive.openBox(AppConstants.settingsBox),
    ]);
  }

  static Future<void> clearAll() async {
    final boxes = [
      AppConstants.tasksBox,
      AppConstants.recipesBox,
      AppConstants.timeBlocksBox,
      AppConstants.habitsBox,
      AppConstants.mealPlanBox,
      AppConstants.shoppingListBox,
    ];
    for (final name in boxes) {
      final box = await Hive.openBox(name);
      await box.clear();
    }
  }

  // Settings helpers
  static Future<Box> get _settingsBox async =>
      Hive.openBox(AppConstants.settingsBox);

  static Future<void> setSetting(String key, dynamic value) async {
    final box = await _settingsBox;
    await box.put(key, value);
  }

  static Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    final box = await _settingsBox;
    return box.get(key, defaultValue: defaultValue);
  }

  static Future<bool> isOnboardingComplete() async {
    return await getSetting(AppConstants.keyOnboardingComplete,
            defaultValue: false) ==
        true;
  }

  static Future<void> setOnboardingComplete() async {
    await setSetting(AppConstants.keyOnboardingComplete, true);
  }
}
