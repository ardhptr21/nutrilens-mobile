import 'dart:io';

import 'package:nutrilens/models/nutrition_model.dart';

typedef NutritionStatisticsResponse = NutritionWithMealsModel;

class NutritionScanRequest {
  final File image;
  final String detail;

  NutritionScanRequest({required this.image, required this.detail});
}

class NutritionScanResponse {
  final String name;
  final double cal;
  final double fat;
  final double protein;
  final double carbs;

  NutritionScanResponse({
    required this.name,
    required this.cal,
    required this.fat,
    required this.protein,
    required this.carbs,
  });

  factory NutritionScanResponse.fromJson(Map<String, dynamic> json) {
    return NutritionScanResponse(
      name: json['name'],
      cal: (json['cal'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );
  }
}

class NutritionUploadMealRequest {
  final String name;
  final double cal;
  final double fat;
  final double protein;
  final double carbs;
  final String description;
  final File image;

  NutritionUploadMealRequest({
    required this.name,
    required this.cal,
    required this.fat,
    required this.protein,
    required this.carbs,
    required this.description,
    required this.image,
  });
}

class NutritionUploadMealResponse {
  final String id;
  final String nutritionId;
  final String name;

  NutritionUploadMealResponse({
    required this.id,
    required this.nutritionId,
    required this.name,
  });

  factory NutritionUploadMealResponse.fromJson(Map<String, dynamic> json) {
    return NutritionUploadMealResponse(
      id: json['id'],
      nutritionId: json['nutritionId'],
      name: json['name'],
    );
  }
}
