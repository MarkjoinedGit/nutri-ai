import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/nutrition_info_model.dart';
import '../services/storage_service.dart';

class CalorieTrackingProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  // Storage for meal items
  List<NutritionInfo> _breakfastItems = [];
  List<NutritionInfo> _lunchItems = [];
  List<NutritionInfo> _dinnerItems = [];
  List<NutritionInfo> _snackItems = [];
  
  // Daily totals
  NutritionInfo _dailyTotal = NutritionInfo(
    calories: 0, 
    protein: 0, 
    carb: 0, 
    fat: 0
  );
  
  // Getters
  List<NutritionInfo> get breakfastItems => _breakfastItems;
  List<NutritionInfo> get lunchItems => _lunchItems;
  List<NutritionInfo> get dinnerItems => _dinnerItems;
  List<NutritionInfo> get snackItems => _snackItems;
  NutritionInfo get dailyTotal => _dailyTotal;
  
  // Format date for storage keys
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Calculate daily totals
  void _calculateDailyTotal() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarb = 0;
    double totalFat = 0;
    
    for (var item in [..._breakfastItems, ..._lunchItems, ..._dinnerItems, ..._snackItems]) {
      totalCalories += item.calories;
      totalProtein += item.protein;
      totalCarb += item.carb;
      totalFat += item.fat;
    }
    
    _dailyTotal = NutritionInfo(
      calories: totalCalories,
      protein: totalProtein,
      carb: totalCarb,
      fat: totalFat
    );
    
    notifyListeners();
  }
  
  // Load daily intake data
  Future<void> loadDailyIntake(String userId, DateTime date) async {
    final String dateStr = _formatDate(date);
    
    try {
      // Load breakfast
      final breakfastData = await _storageService.getCalorieData(
        userId, 
        'breakfast', 
        dateStr
      );
      _breakfastItems = _parseNutritionList(breakfastData);
      
      // Load lunch
      final lunchData = await _storageService.getCalorieData(
        userId, 
        'lunch', 
        dateStr
      );
      _lunchItems = _parseNutritionList(lunchData);
      
      // Load dinner
      final dinnerData = await _storageService.getCalorieData(
        userId, 
        'dinner', 
        dateStr
      );
      _dinnerItems = _parseNutritionList(dinnerData);
      
      // Load snacks
      final snackData = await _storageService.getCalorieData(
        userId, 
        'snack', 
        dateStr
      );
      _snackItems = _parseNutritionList(snackData);
      
      // Calculate totals
      _calculateDailyTotal();
      
    } catch (e) {
      // Reset all values on error
      _breakfastItems = [];
      _lunchItems = [];
      _dinnerItems = [];
      _snackItems = [];
      _dailyTotal = NutritionInfo(calories: 0, protein: 0, carb: 0, fat: 0);
      notifyListeners();
    }
  }
  
  // Parse nutrition info list from storage
  List<NutritionInfo> _parseNutritionList(List<dynamic>? data) {
    if (data == null) return [];
    
    return data.map((item) => NutritionInfo.fromJson(item)).toList();
  }
  
  // Add meal data
  Future<void> addMealData(
    String userId, 
    DateTime date, 
    String mealType, 
    NutritionInfo nutritionInfo
  ) async {
    final String dateStr = _formatDate(date);
    
    try {
      switch (mealType) {
        case 'breakfast':
          _breakfastItems.add(nutritionInfo);
          await _storageService.saveCalorieData(
            userId, 
            'breakfast', 
            dateStr, 
            _breakfastItems
          );
          break;
        case 'lunch':
          _lunchItems.add(nutritionInfo);
          await _storageService.saveCalorieData(
            userId, 
            'lunch', 
            dateStr, 
            _lunchItems
          );
          break;
        case 'dinner':
          _dinnerItems.add(nutritionInfo);
          await _storageService.saveCalorieData(
            userId, 
            'dinner', 
            dateStr, 
            _dinnerItems
          );
          break;
        case 'snack':
          _snackItems.add(nutritionInfo);
          await _storageService.saveCalorieData(
            userId, 
            'snack', 
            dateStr, 
            _snackItems
          );
          break;
      }
      
      // Update daily totals
      _calculateDailyTotal();
      
    } catch (e) {
      
      print('Error adding meal data: $e');
    }
  }
  
  // Remove meal item
  Future<void> removeMealItem(
    String userId,
    DateTime date,
    String mealType,
    int index
  ) async {
    final String dateStr = _formatDate(date);
    
    try {
      switch (mealType) {
        case 'breakfast':
          if (index >= 0 && index < _breakfastItems.length) {
            _breakfastItems.removeAt(index);
            await _storageService.saveCalorieData(
              userId, 
              'breakfast', 
              dateStr, 
              _breakfastItems
            );
          }
          break;
        case 'lunch':
          if (index >= 0 && index < _lunchItems.length) {
            _lunchItems.removeAt(index);
            await _storageService.saveCalorieData(
              userId, 
              'lunch', 
              dateStr, 
              _lunchItems
            );
          }
          break;
        case 'dinner':
          if (index >= 0 && index < _dinnerItems.length) {
            _dinnerItems.removeAt(index);
            await _storageService.saveCalorieData(
              userId, 
              'dinner', 
              dateStr, 
              _dinnerItems
            );
          }
          break;
        case 'snack':
          if (index >= 0 && index < _snackItems.length) {
            _snackItems.removeAt(index);
            await _storageService.saveCalorieData(
              userId, 
              'snack', 
              dateStr, 
              _snackItems
            );
          }
          break;
      }
      
      // Update daily totals
      _calculateDailyTotal();
      
    } catch (e) {
      print('Error removing calorie data: $e');
    }
  }
  
  // Clear all data for a specific day
  Future<void> clearDailyData(String userId, DateTime date) async {
    final String dateStr = _formatDate(date);
    
    try {
      await _storageService.clearCalorieData(userId, dateStr);
      
      _breakfastItems = [];
      _lunchItems = [];
      _dinnerItems = [];
      _snackItems = [];
      _dailyTotal = NutritionInfo(calories: 0, protein: 0, carb: 0, fat: 0);
      
      notifyListeners();
    } catch (e) {
      print('Error clearing calorie data: $e');
    }
  }
}