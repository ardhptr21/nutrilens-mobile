// lib/models/nutrition_model.dart
class NutritionModel {
  final String id;
  final DateTime date;
  final int totalCalories;
  final int calorieGoal;
  final int protein;
  final int carbs;
  final int fat;

  const NutritionModel({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.calorieGoal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
