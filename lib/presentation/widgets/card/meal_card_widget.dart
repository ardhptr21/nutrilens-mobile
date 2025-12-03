import 'package:flutter/material.dart';
import 'package:nutrilens/config/api.dart';
import 'package:nutrilens/models/meal_model.dart';

class MealCardWidget extends StatelessWidget {
  final MealModel meal;

  const MealCardWidget({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${ApiConfig.baseUrl}/${meal.image}',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Title and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${meal.createdAt.hour.toString().padLeft(2, '0')}:${meal.createdAt.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Calories badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${meal.cal.toStringAsFixed(0)} kkal',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description if available
            if (meal.description != null && meal.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  meal.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),

            // Nutrients grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: [
                _buildNutrientBox(
                  'Protein',
                  '${meal.protein.toStringAsFixed(1)}g',
                  Colors.yellow.shade100,
                  Icons.set_meal,
                ),
                _buildNutrientBox(
                  'Karbohidrat',
                  '${meal.carbs.toStringAsFixed(1)}g',
                  Colors.orange.shade100,
                  Icons.rice_bowl,
                ),
                _buildNutrientBox(
                  'Lemak',
                  '${meal.fat.toStringAsFixed(1)}g',
                  Colors.red.shade100,
                  Icons.opacity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBox(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
