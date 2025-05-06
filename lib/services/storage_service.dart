import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nutrition_info_model.dart';

class StorageService {
  Future<void> saveCalorieData(
    String userId,
    String mealType,
    String date,
    List<NutritionInfo> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'calorie_${userId}_${date}_$mealType';

    final List<Map<String, dynamic>> jsonList =
        items.map((item) => item.toJson()).toList();

    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<dynamic>?> getCalorieData(
    String userId,
    String mealType,
    String date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'calorie_${userId}_${date}_$mealType';

    final String? jsonData = prefs.getString(key);
    if (jsonData == null) return null;

    return jsonDecode(jsonData) as List<dynamic>;
  }

  Future<void> clearCalorieData(String userId, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

    for (final mealType in mealTypes) {
      final key = 'calorie_${userId}_${date}_$mealType';
      await prefs.remove(key);
    }
  }
}
