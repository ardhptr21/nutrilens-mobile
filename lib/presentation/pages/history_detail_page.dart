import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/meal_model.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';
import 'package:nutrilens/presentation/widgets/card/meal_card_widget.dart';

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
                  _buildCalorieCircle(
                    calories: nutritionData.cal,
                    target: nutritionData.targetCal,
                  ),
                  const SizedBox(height: 32.0),

                  _buildNutrientCards(nutritionData),
                  const SizedBox(height: 32.0),

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

    return Center(
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isAchieved ? Colors.green : Colors.blue)
                          .withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 14,
                          backgroundColor: Colors.grey.shade200,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation(
                            isAchieved
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF2196F3),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            calories.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: isAchieved
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'dari ${target.toStringAsFixed(0)} kkal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isAchieved
                                    ? [
                                        const Color(0xFF4CAF50),
                                        const Color(0xFF66BB6A),
                                      ]
                                    : [
                                        const Color(0xFF2196F3),
                                        const Color(0xFF42A5F5),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isAchieved
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFF2196F3))
                                          .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAchieved
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isAchieved ? 'Tercapai!' : 'Dalam Proses',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
        Row(
          children: [
            Icon(
              Icons.track_changes_rounded,
              size: 24,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 8),
            Text(
              'Target Nutrisi Harian',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3842),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAchieved
                        ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                        : [
                            color.withValues(alpha: 0.2),
                            color.withValues(alpha: 0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}g / ${target.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isAchieved ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.toDouble(),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        Row(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 24,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 8),
            Text(
              'Makanan & Minuman',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              return MealCardWidget(meal: meal);
            },
          ),
      ],
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
