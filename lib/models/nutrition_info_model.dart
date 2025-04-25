class NutritionInfo {
  final double calories;
  final double fat;
  final double carb;
  final double protein;

  NutritionInfo({
    required this.calories,
    required this.fat,
    required this.carb,
    required this.protein,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['Calories']?.toDouble() ?? 0.0,
      fat: json['Fat']?.toDouble() ?? 0.0,
      carb: json['Carb']?.toDouble() ?? 0.0,
      protein: json['Protein']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Calories': calories,
      'Fat': fat,
      'Carb': carb,
      'Protein': protein,
    };
  }
}