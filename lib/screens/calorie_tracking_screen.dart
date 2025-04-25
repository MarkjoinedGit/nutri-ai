import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/recipe_service.dart';
import '../models/nutrition_info_model.dart';
import '../utils/image_validation_util.dart';
import '../providers/calorie_tracking_provider.dart';
import '../widgets/daily_nutrition_summary_widget.dart';
import '../widgets/meal_section_widget.dart';
import '../widgets/food_analysis_widget.dart';

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
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  // Colors
  static const Color customOrange = Color(0xFFE07E02);

  @override
  void initState() {
    super.initState();
    _loadDailyData();
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
    // Dynamic date range: from 5 years ago to 1 year in the future
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

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      // Validate if file is an image
      if (!imageFile.isValidImage) {
        setState(() {
          _errorMessage = 'The selected file is not a valid image.';
        });
        return;
      }

      setState(() {
        _image = imageFile;
        _nutritionInfo = null;
        _errorMessage = null;
      });

      // Analyze food image
      _analyzeImage();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select image: ${e.toString()}';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
      setState(() {
        _errorMessage = 'User not logged in. Please log in again.';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    final recipeService = RecipeService();

    try {
      final nutritionInfo = await recipeService.getNutritionInfo(_image!);
      if (mounted) {
        setState(() {
          _nutritionInfo = nutritionInfo;
          _isAnalyzing = false;
        });

        // Show meal selection dialog
        _showMealSelectionDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error analyzing nutrition: ${e.toString()}';
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showMealSelectionDialog() {
    if (_nutritionInfo == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to which meal?'),
          content: FoodAnalysisWidget(nutritionInfo: _nutritionInfo!),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Breakfast'),
              onPressed: () {
                _saveMealData('breakfast');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lunch'),
              onPressed: () {
                _saveMealData('lunch');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Dinner'),
              onPressed: () {
                _saveMealData('dinner');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Snack'),
              onPressed: () {
                _saveMealData('snack');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveMealData(String mealType) async {
    if (_nutritionInfo == null) return;

    final calorieProvider = Provider.of<CalorieTrackingProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
            content: Text('Food added to $mealType successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Food'),
          content: const Text('Choose how you want to add food'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera);
              },
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.gallery);
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

    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      calorieProvider.removeMealItem(
        userProvider.currentUser!.id,
        _selectedDate,
        mealType,
        index,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food item removed'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final calorieProvider = Provider.of<CalorieTrackingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calorie Tracking',
          style: TextStyle(color: Colors.black87),
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
              // Date selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Daily totals card
              DailyNutritionSummaryWidget(
                dailyTotal: calorieProvider.dailyTotal,
              ),

              const SizedBox(height: 24),

              // Meal sections
              MealSectionWidget(
                title: 'Breakfast',
                items: calorieProvider.breakfastItems,
                onRemove: (index) => _removeItem('breakfast', index),
              ),
              const SizedBox(height: 16),
              MealSectionWidget(
                title: 'Lunch',
                items: calorieProvider.lunchItems,
                onRemove: (index) => _removeItem('lunch', index),
              ),
              const SizedBox(height: 16),
              MealSectionWidget(
                title: 'Dinner',
                items: calorieProvider.dinnerItems,
                onRemove: (index) => _removeItem('dinner', index),
              ),
              const SizedBox(height: 16),
              MealSectionWidget(
                title: 'Snacks',
                items: calorieProvider.snackItems,
                onRemove: (index) => _removeItem('snack', index),
              ),

              const SizedBox(height: 24),

              // Add Food Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customOrange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _showAddFoodDialog,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Add Food with Camera',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Error message if any
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],

              // Loading indicator
              if (_isAnalyzing) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: customOrange),
                      SizedBox(height: 16),
                      Text('Analyzing food image...'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
