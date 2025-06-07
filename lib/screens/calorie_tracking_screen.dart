import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../services/recipe_service.dart';
import '../models/nutrition_info_model.dart';
import '../utils/image_validation_util.dart';
import '../utils/app_strings.dart';
import '../providers/calorie_tracking_provider.dart';
import '../widgets/daily_nutrition_summary_widget.dart';
import '../widgets/meal_section_widget.dart';
import '../widgets/food_analysis_widget.dart';
import '../widgets/error_notification_widget.dart';

class CalorieTrackingScreen extends StatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  State<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends State<CalorieTrackingScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isAnalyzing = false;
  NutritionInfo? _nutritionInfo;
  DateTime _selectedDate = DateTime.now();
  String _currentMealType = '';

  static const Color customOrange = Color(0xFFE07E02);

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  void _showError(String message) {
    ErrorNotificationManager.showError(context, message);
  }

  Future<void> _loadDailyData() async {
    final calorieProvider = Provider.of<CalorieTrackingProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      await calorieProvider.loadDailyIntake(
        userProvider.currentUser!.id,
        _selectedDate,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 5);
    final DateTime lastDate = DateTime(now.year + 1, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: customOrange),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDailyData();
    }
  }

  Future<void> _getImage(ImageSource source, String mealType) async {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    try {
      setState(() {
        _currentMealType = mealType;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      if (!imageFile.isValidImage) {
        setState(() {
          _showError(strings.invalidImageFile);
        });
        return;
      }

      setState(() {
        _image = imageFile;
        _nutritionInfo = null;
      });

      _analyzeImage();
    } catch (e) {
      setState(() {
        _showError('${strings.failedToSelectImage}${e.toString()}');
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
      setState(() {
        _showError(strings.userNotLoggedIn);
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    final recipeService = RecipeService();

    try {
      final nutritionInfo = await recipeService.getNutritionInfo(_image!);
      if (mounted) {
        setState(() {
          _nutritionInfo = nutritionInfo;
          _isAnalyzing = false;
        });

        _showFoodAnalysisDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        _showError('${strings.errorAnalyzingNutrition}${e.toString()}');
      }
    }
  }

  void _showFoodAnalysisDialog() {
    if (_nutritionInfo == null) return;

    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${strings.addToMeal} ${_getMealTypeDisplayName(_currentMealType)}?',
          ),
          content: FoodAnalysisWidget(nutritionInfo: _nutritionInfo!),
          actions: [
            TextButton(
              child: Text(strings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(strings.addFood),
              onPressed: () {
                _saveMealData(_currentMealType);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getMealTypeDisplayName(String mealType) {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    switch (mealType) {
      case 'breakfast':
        return strings.breakfast;
      case 'lunch':
        return strings.lunch;
      case 'dinner':
        return strings.dinner;
      case 'snack':
        return strings.snacks;
      default:
        return mealType;
    }
  }

  void _saveMealData(String mealType) async {
    if (_nutritionInfo == null) return;

    final calorieProvider = Provider.of<CalorieTrackingProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      await calorieProvider.addMealData(
        userProvider.currentUser!.id,
        _selectedDate,
        mealType,
        _nutritionInfo!,
      );

      if (mounted) {
        setState(() {
          _image = null;
          _nutritionInfo = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${strings.addFood} ${_getMealTypeDisplayName(mealType)} ${strings.foodAddedSuccessfully}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showAddFoodOptionsForMeal(String mealType) {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${strings.addFoodToMeal} ${_getMealTypeDisplayName(mealType)}',
          ),
          content: Text(strings.chooseHowToAddFood),
          actions: [
            TextButton(
              child: Text(strings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(strings.camera),
              onPressed: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera, mealType);
              },
            ),
            TextButton(
              child: Text(strings.gallery),
              onPressed: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.gallery, mealType);
              },
            ),
          ],
        );
      },
    );
  }

  void _removeItem(String mealType, int index) {
    final calorieProvider = Provider.of<CalorieTrackingProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      calorieProvider.removeMealItem(
        userProvider.currentUser!.id,
        _selectedDate,
        mealType,
        index,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.foodItemRemoved),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CalorieTrackingProvider, LocalizationProvider>(
      builder: (context, calorieProvider, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              strings.calorieTrackingInLine,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.black87),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, MMMM d, yyyy',
                          ).format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  DailyNutritionSummaryWidget(
                    dailyTotal: calorieProvider.dailyTotal,
                  ),

                  const SizedBox(height: 24),

                  if (_isAnalyzing) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: customOrange),
                          const SizedBox(height: 16),
                          Text(strings.analyzingFoodImage),
                        ],
                      ),
                    ),
                  ],

                  MealSectionWidget(
                    title: strings.breakfast,
                    items: calorieProvider.breakfastItems,
                    onRemove: (index) => _removeItem('breakfast', index),
                    onAddPressed: () => _showAddFoodOptionsForMeal('breakfast'),
                  ),
                  const SizedBox(height: 16),
                  MealSectionWidget(
                    title: strings.lunch,
                    items: calorieProvider.lunchItems,
                    onRemove: (index) => _removeItem('lunch', index),
                    onAddPressed: () => _showAddFoodOptionsForMeal('lunch'),
                  ),
                  const SizedBox(height: 16),
                  MealSectionWidget(
                    title: strings.dinner,
                    items: calorieProvider.dinnerItems,
                    onRemove: (index) => _removeItem('dinner', index),
                    onAddPressed: () => _showAddFoodOptionsForMeal('dinner'),
                  ),
                  const SizedBox(height: 16),
                  MealSectionWidget(
                    title: strings.snacks,
                    items: calorieProvider.snackItems,
                    onRemove: (index) => _removeItem('snack', index),
                    onAddPressed: () => _showAddFoodOptionsForMeal('snack'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
