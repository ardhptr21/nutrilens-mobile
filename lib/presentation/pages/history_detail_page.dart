import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nutrilens/config/api.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/meal_model.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';

class HistoryDetailPage extends StatefulWidget {
  final NutritionModel nutrition;

  const HistoryDetailPage({required this.nutrition, super.key});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  late Future<NutritionWithMealsModel?> _mealsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for Indonesian locale
    initializeDateFormatting('id_ID');
    _mealsFuture = _fetchMealsForDate();
  }

  Future<NutritionWithMealsModel?> _fetchMealsForDate() async {
    try {
      final nutritionService = locator<NutritionService>();
      final formattedDate =
          '${widget.nutrition.logAt.year}-${widget.nutrition.logAt.month.toString().padLeft(2, '0')}-${widget.nutrition.logAt.day.toString().padLeft(2, '0')}';

      final response = await nutritionService.getNutritionHistoryDetail(
        formattedDate,
      );

      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Detail Riwayat - ${DateFormat('d MMMM yyyy', 'id_ID').format(widget.nutrition.logAt)}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<NutritionWithMealsModel?>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final nutritionData =
              snapshot.data ?? _convertToWithMeals(widget.nutrition);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calorie Circle
                  _buildCalorieCircle(
                    calories: nutritionData.cal,
                    target: nutritionData.targetCal,
                  ),
                  const SizedBox(height: 32.0),

                  // Nutrient Cards
                  _buildNutrientCards(nutritionData),
                  const SizedBox(height: 32.0),

                  // Meals Section
                  _buildMealsSection(nutritionData.meals, context),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalorieCircle({
    required double calories,
    required double target,
  }) {
    final progress = (target == 0) ? 0 : (calories / target).clamp(0, 1);
    final isAchieved = calories >= target;

    // Check if the date is today or in the past
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final isToday = widget.nutrition.logAt == dateOnly;
    final statusText = isAchieved
        ? '✓ Tercapai'
        : (isToday ? 'Belum Tercapai' : 'Tidak Tercapai');

    return Center(
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.toDouble()),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          isAchieved ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          calories.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'dari ${target.toStringAsFixed(0)} kkal',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAchieved
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isAchieved
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCards(NutritionWithMealsModel nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Nutrisi',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              _buildNutrientRow(
                title: 'Protein',
                value: nutrition.protein,
                target: nutrition.targetProtein,
                color: Colors.yellow,
                icon: Icons.set_meal,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildNutrientRow(
                title: 'Karbohidrat',
                value: nutrition.carbs,
                target: nutrition.targetCarbs,
                color: Colors.orange,
                icon: Icons.rice_bowl,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildNutrientRow(
                title: 'Lemak',
                value: nutrition.fat,
                target: nutrition.targetFat,
                color: Colors.red,
                icon: Icons.opacity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientRow({
    required String title,
    required double value,
    required double target,
    required Color color,
    required IconData icon,
  }) {
    final progress = (target == 0) ? 0 : (value / target).clamp(0, 1);
    final isAchieved = value >= target;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${value.toStringAsFixed(1)}g / ${target.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isAchieved ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              backgroundColor: Colors.grey.shade300,
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSection(List<MealModel> meals, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Makanan Hari Ini',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'Tidak ada makanan yang tercatat',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final meal = meals[index];
              return _buildMealCard(meal);
            },
          ),
      ],
    );
  }

  Widget _buildMealCard(MealModel meal) {
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

  NutritionWithMealsModel _convertToWithMeals(NutritionModel nutrition) {
    return NutritionWithMealsModel(
      logAt: nutrition.logAt,
      cal: nutrition.cal,
      fat: nutrition.fat,
      protein: nutrition.protein,
      carbs: nutrition.carbs,
      targetCal: nutrition.targetCal,
      targetFat: nutrition.targetFat,
      targetCarbs: nutrition.targetCarbs,
      targetProtein: nutrition.targetProtein,
      meals: [],
    );
  }
}
