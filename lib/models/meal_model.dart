class MealModel {
  final String id;
  final String name;
  final String image;
  final String? description;
  final double cal;
  final double fat;
  final double protein;
  final double carbs;
  final DateTime createdAt;

  MealModel({
    required this.id,
    required this.name,
    required this.image,
    this.description,
    required this.cal,
    required this.fat,
    required this.protein,
    required this.carbs,
    required this.createdAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      cal: (json['cal'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
