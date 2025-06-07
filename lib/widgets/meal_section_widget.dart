import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_info_model.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

class MealSectionWidget extends StatelessWidget {
  final String title;
  final List<NutritionInfo> items;
  final Function(int) onRemove;
  final VoidCallback onAddPressed;
  static const Color customOrange = Color(0xFFE07E02);

  const MealSectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onRemove,
    required this.onAddPressed,
  });

  double _calculateMealCalories() {
    double total = 0;
    for (var item in items) {
      total += item.calories;
    }
    return total;
  }

  void _removeItemDialog(BuildContext context, int index) {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.removeFood),
          content: Text(strings.removeConfirmation),
          actions: [
            TextButton(
              child: Text(strings.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(strings.remove),
              onPressed: () {
                onRemove(index);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_calculateMealCalories().toStringAsFixed(0)} ${strings.kcal}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: customOrange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: customOrange,
                          ),
                          tooltip: '${strings.addFoodTooltip}$title',
                          onPressed: onAddPressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    strings.noItemsAdded,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ...items.asMap().entries.map((entry) {
                int index = entry.key;
                NutritionInfo item = entry.value;
                return ListTile(
                  title: Text('${strings.foodItem}${index + 1}'),
                  subtitle: Text(
                    '${strings.calories}${item.calories.toStringAsFixed(0)} ${strings.kcal} · '
                    '${strings.protein}${item.protein.toStringAsFixed(1)}${strings.grams} · '
                    '${strings.carbs}${item.carb.toStringAsFixed(1)}${strings.grams} · '
                    '${strings.fat}${item.fat.toStringAsFixed(1)}${strings.grams}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeItemDialog(context, index),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
