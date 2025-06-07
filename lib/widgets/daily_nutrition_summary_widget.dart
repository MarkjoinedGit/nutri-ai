import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_info_model.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

class DailyNutritionSummaryWidget extends StatelessWidget {
  final NutritionInfo dailyTotal;
  static const Color customOrange = Color(0xFFE07E02);

  const DailyNutritionSummaryWidget({super.key, required this.dailyTotal});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.dailyNutritionSummary,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutrientSummaryItem(
                        strings.caloriesLabel,
                        dailyTotal.calories.toStringAsFixed(1),
                        strings.kcal,
                        Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNutrientSummaryItem(
                        strings.proteinLabel,
                        dailyTotal.protein.toStringAsFixed(1),
                        strings.grams,
                        Colors.blue.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutrientSummaryItem(
                        strings.carbsLabel,
                        dailyTotal.carb.toStringAsFixed(1),
                        strings.grams,
                        Colors.green.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNutrientSummaryItem(
                        strings.fatLabel,
                        dailyTotal.fat.toStringAsFixed(1),
                        strings.grams,
                        customOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientSummaryItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
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
              Text(unit, style: TextStyle(fontSize: 14, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
