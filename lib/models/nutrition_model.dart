class NutritionModel {
  final String id;
  final DateTime date;
  final int totalCalories;
  final int calorieGoal;
  final int protein;
  final int fat;
  final int carbs;

  const NutritionModel({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.calorieGoal,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}
