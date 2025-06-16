import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../services/recipe_service.dart';
import '../models/nutrition_info_model.dart';
import '../widgets/recipe_result_widget.dart';
import '../widgets/nutrition_info_widget.dart';
import '../utils/image_validation_util.dart';
import '../utils/app_strings.dart';

class RecipeRecognitionScreen extends StatefulWidget {
  const RecipeRecognitionScreen({super.key});

  @override
  State<RecipeRecognitionScreen> createState() =>
      _RecipeRecognitionScreenState();
}

class _RecipeRecognitionScreenState extends State<RecipeRecognitionScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isAnalyzing = false;
  bool _isLoadingNutrition = false;
  bool _isLoadingDish = false;
  bool _isLoadingRecipe = false;
  NutritionInfo? _nutritionInfo;
  String? _dishName;
  String? _recipeResult;
  String? _errorMessage;

  static const Color customOrange = Color(0xFFE07E02);

  Future<void> _getImage(ImageSource source) async {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      if (!imageFile.isValidImage) {
        setState(() {
          _errorMessage = strings.invalidImage;
        });
        return;
      }

      setState(() {
        _image = imageFile;
        _nutritionInfo = null;
        _dishName = null;
        _recipeResult = null;
        _errorMessage = null;
      });

      _analyzeImage();
    } catch (e) {
      setState(() {
        _errorMessage = '${strings.invalidImage} ${e.toString()}';
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
        _errorMessage = strings.userNotLoggedIn;
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _isLoadingNutrition = true;
      _isLoadingDish = true;
      _errorMessage = null;
    });

    final recipeService = RecipeService();

    // Analyze nutrition info
    try {
      final nutritionInfo = await recipeService.getNutritionInfo(_image!);
      if (mounted) {
        setState(() {
          _nutritionInfo = nutritionInfo;
          _isLoadingNutrition = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${strings.errorAnalyzingNutrition} ${e.toString()}';
          _isLoadingNutrition = false;
        });
      }
    }

    // Recognize dish name
    try {
      final dishName = await recipeService.getDishName(_image!);
      if (mounted) {
        setState(() {
          _dishName = dishName;
          _isLoadingDish = false;
        });

        // Show confirmation dialog after getting dish name
        _showDishConfirmationDialog(dishName);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error recognizing dish: ${e.toString()}';
          _isLoadingDish = false;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isAnalyzing = _isLoadingNutrition || _isLoadingDish;
      });
    }
  }

  Future<void> _showDishConfirmationDialog(String recognizedDishName) async {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    final TextEditingController dishController = TextEditingController(
      text: recognizedDishName,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.confirmDishNameShort),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.weRecognizedThisDishAs,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dishController,
                decoration: InputDecoration(
                  labelText: strings.dishName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Text(
                strings.confirmDishName,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(strings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: customOrange,
                foregroundColor: Colors.white,
              ),
              child: Text(strings.recipeGenerated),
              onPressed: () {
                final confirmedDishName = dishController.text.trim();
                Navigator.of(context).pop();
                if (confirmedDishName.isNotEmpty) {
                  _generateRecipe(confirmedDishName);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateRecipe(String confirmedDishName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    if (!userProvider.isLoggedIn || userProvider.currentUser == null) {
      setState(() {
        _errorMessage = strings.userNotLoggedIn;
      });
      return;
    }

    setState(() {
      _isLoadingRecipe = true;
      _isAnalyzing = true;
      _errorMessage = null;
    });

    final recipeService = RecipeService();
    final userId = userProvider.currentUser!.id;

    try {
      final recipeResult = await recipeService.generateRecipe(
        userId,
        confirmedDishName,
      );
      if (mounted) {
        setState(() {
          _recipeResult = recipeResult;
          _isLoadingRecipe = false;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error generating recipe: ${e.toString()}';
          _isLoadingRecipe = false;
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(
              strings.recipeRecognitionInLine,
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
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _image == null
                            ? Center(
                              child: Text(
                                strings.noImageSelected,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: Text(strings.camera),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customOrange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _getImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: Text(strings.gallery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black87,
                        ),
                        onPressed: () => _getImage(ImageSource.gallery),
                      ),
                    ],
                  ),

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

                  if (_isAnalyzing) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: customOrange),
                          const SizedBox(height: 16),
                          Text(
                            _isLoadingRecipe
                                ? strings.recipeGenerated
                                : strings.analyzingImage,
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_nutritionInfo != null) ...[
                    const SizedBox(height: 24),
                    NutritionInfoWidget(nutritionInfo: _nutritionInfo!),
                  ],

                  if (_recipeResult != null) ...[
                    const SizedBox(height: 24),
                    RecipeResultWidget(recipeResult: _recipeResult!),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
