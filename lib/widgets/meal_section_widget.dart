import 'package:flutter/material.dart';
import '../models/nutrition_info_model.dart';

class MealSectionWidget extends StatelessWidget {
  final String title;
  final List<NutritionInfo> items;
  final Function(int) onRemove;
  static const Color customOrange = Color(0xFFE07E02);

  const MealSectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onRemove,
  });

  double _calculateMealCalories() {
    double total = 0;
    for (var item in items) {
      total += item.calories;
    }
    return total;
  }

  void _removeItemDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove Food'),
          content: const Text(
            'Are you sure you want to remove this food item?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Remove'),
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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                Text(
                  '${_calculateMealCalories().toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: customOrange,
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No items added yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...items.asMap().entries.map((entry) {
            int index = entry.key;
            NutritionInfo item = entry.value;
            return ListTile(
              title: Text('Food Item ${index + 1}'),
              subtitle: Text(
                'Calories: ${item.calories.toStringAsFixed(0)} kcal · '
                'P: ${item.protein.toStringAsFixed(1)}g · '
                'C: ${item.carb.toStringAsFixed(1)}g · '
                'F: ${item.fat.toStringAsFixed(1)}g',
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
  }
}
