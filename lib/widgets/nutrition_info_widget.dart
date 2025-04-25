import 'package:flutter/material.dart';
import '../../models/nutrition_info_model.dart';

class NutritionInfoWidget extends StatelessWidget {
  final NutritionInfo nutritionInfo;
  static const Color customOrange = Color(0xFFE07E02);

  const NutritionInfoWidget({super.key, required this.nutritionInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientItem(
                    'Calories',
                    nutritionInfo.calories.toStringAsFixed(1),
                    'kcal',
                    Colors.red.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNutrientItem(
                    'Protein',
                    nutritionInfo.protein.toStringAsFixed(1),
                    'g',
                    Colors.blue.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientItem(
                    'Carbs',
                    nutritionInfo.carb.toStringAsFixed(1),
                    'g',
                    Colors.green.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNutrientItem(
                    'Fat',
                    nutritionInfo.fat.toStringAsFixed(1),
                    'g',
                    customOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}