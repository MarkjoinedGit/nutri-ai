import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/recipe_service.dart';
import '../models/nutrition_info_model.dart';
import '../widgets/recipe_result_widget.dart';
import '../widgets/nutrition_info_widget.dart';
import '../utils/image_validation_util.dart';

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
  bool _isLoadingRecipe = false;
  NutritionInfo? _nutritionInfo;
  String? _recipeResult;
  String? _errorMessage;

  static const Color customOrange = Color(0xFFE07E02);

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      if (!imageFile.isValidImage) {
        setState(() {
          _errorMessage = 'The selected file is not a valid image.';
        });
        return;
      }

      setState(() {
        _image = imageFile;
        _nutritionInfo = null;
        _recipeResult = null;
        _errorMessage = null;
      });

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
      _isLoadingNutrition = true;
      _isLoadingRecipe = true;
      _errorMessage = null;
    });

    final recipeService = RecipeService();
    final userId = userProvider.currentUser!.id;

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
          _errorMessage = 'Error analyzing nutrition: ${e.toString()}';
          _isLoadingNutrition = false;
        });
      }
    }

    try {
      final recipeResult = await recipeService.getRecipe(_image!, userId);
      if (mounted) {
        setState(() {
          _recipeResult = recipeResult;
          _isLoadingRecipe = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error generating recipe: ${e.toString()}';
          _isLoadingRecipe = false;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isAnalyzing = _isLoadingNutrition || _isLoadingRecipe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Recognition',
          style: TextStyle(color: Colors.black87),
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
                            'No image selected',
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
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customOrange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _getImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
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
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: customOrange),
                      SizedBox(height: 16),
                      Text('Analyzing image...'),
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
  }
}
