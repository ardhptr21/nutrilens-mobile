import 'package:nutrilens/models/meal_model.dart';

class NutritionModel {
  final DateTime logAt;
  final double cal;
  final double fat;
  final double protein;
  final double carbs;
  final double targetCal;
  final double targetFat;
  final double targetCarbs;
  final double targetProtein;

  NutritionModel({
    required this.logAt,
    required this.cal,
    required this.fat,
    required this.protein,
    required this.carbs,
    required this.targetCal,
    required this.targetFat,
    required this.targetCarbs,
    required this.targetProtein,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['logAt'] as String;
    final parsedDate = DateTime.parse(dateStr);
    final localDate = parsedDate.toLocal();
    final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

    return NutritionModel(
      logAt: dateOnly,
      cal: (json['cal'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      targetCal: (json['targetCal'] as num).toDouble(),
      targetFat: (json['targetFat'] as num).toDouble(),
      targetCarbs: (json['targetCarbs'] as num).toDouble(),
      targetProtein: (json['targetProtein'] as num).toDouble(),
    );
  }
}

class NutritionWithMealsModel extends NutritionModel {
  final List<MealModel> meals;

  NutritionWithMealsModel({
    required super.logAt,
    required super.cal,
    required super.fat,
    required super.protein,
    required super.carbs,
    required super.targetCal,
    required super.targetFat,
    required super.targetCarbs,
    required super.targetProtein,
    required this.meals,
  });

  factory NutritionWithMealsModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['logAt'] as String;
    final parsedDate = DateTime.parse(dateStr);
    final localDate = parsedDate.toLocal();
    final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

    return NutritionWithMealsModel(
      logAt: dateOnly,
      cal: (json['cal'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      targetCal: (json['targetCal'] as num).toDouble(),
      targetFat: (json['targetFat'] as num).toDouble(),
      targetCarbs: (json['targetCarbs'] as num).toDouble(),
      targetProtein: (json['targetProtein'] as num).toDouble(),
      meals: List<MealModel>.from(
        json['meals'].map((meal) => MealModel.fromJson(meal)),
      ),
    );
  }
}
