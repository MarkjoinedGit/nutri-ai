import 'package:flutter/material.dart';
import '../models/nutrition_info_model.dart';
import '../widgets/nutrition_info_widget.dart';

class FoodAnalysisWidget extends StatelessWidget {
  final NutritionInfo nutritionInfo;

  const FoodAnalysisWidget({
    super.key,
    required this.nutritionInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NutritionInfoWidget(nutritionInfo: nutritionInfo),
        const SizedBox(height: 16),
        const Text('Select a meal to add this food to:'),
      ],
    );
  }
}