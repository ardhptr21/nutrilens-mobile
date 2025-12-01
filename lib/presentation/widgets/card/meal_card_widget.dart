import 'package:flutter/material.dart';
import 'package:nutrilens/config/api.dart';
import 'package:nutrilens/models/meal_model.dart';

class MealCardWidget extends StatelessWidget {
  final MealModel meal;

  const MealCardWidget({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConfig.baseUrl}/${meal.image}',
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Text(
                          "${meal.createdAt.hour.toString().padLeft(2, '0')}:${meal.createdAt.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${meal.cal.toStringAsFixed(0)} kkal',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _nutriChip(
                Icons.set_meal,
                'Protein',
                meal.protein,
                Colors.yellow.shade100,
              ),
              const SizedBox(height: 8),
              _nutriChip(
                Icons.rice_bowl,
                'Karbohidrat',
                meal.carbs,
                Colors.orange.shade100,
              ),
              const SizedBox(height: 8),
              _nutriChip(Icons.opacity, 'Lemak', meal.fat, Colors.red.shade100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutriChip(IconData icon, String label, double value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label ${value.toStringAsFixed(1)}g',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
