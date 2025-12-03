import 'package:flutter/material.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/main.dart';
import 'package:nutrilens/models/api_model.dart';
import 'package:nutrilens/models/meal_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';
import 'package:nutrilens/network/http/user/user_model.dart';
import 'package:nutrilens/network/http/user/user_service.dart';
import 'package:nutrilens/presentation/widgets/card/meal_card_widget.dart';

abstract class HomePageState {
  void refresh();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with RouteAware
    implements HomePageState {
  late Future<(UserMeResponse?, NutritionStatisticsResponse?)> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  @override
  void refresh() {
    setState(() {
      _loadFuture = _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refresh();
  }

  Future<(UserMeResponse?, NutritionStatisticsResponse?)> _loadData() async {
    final userService = locator<UserService>();
    final nutritionService = locator<NutritionService>();

    final results = await Future.wait([
      userService.getUserMe(),
      nutritionService.getNutritionStatisticsToday(),
    ]);

    final userResponse = results[0] as APIResponse<UserMeResponse>;
    final nutritionResponse =
        results[1] as APIResponse<NutritionStatisticsResponse>;

    return (userResponse.data, nutritionResponse.data);
  }

  void _refresh() {
    setState(() {
      _loadFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<(UserMeResponse?, NutritionStatisticsResponse?)>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final (user, nutrition) = snapshot.data!;
        final name = user?.name ?? 'User';

        final totalCalories = nutrition?.cal ?? 0;
        final protein = nutrition?.protein ?? 0;
        final carbo = nutrition?.carbs ?? 0;
        final fat = nutrition?.fat ?? 0;
        final targetCal = nutrition?.targetCal ?? 0;
        final targetProtein = nutrition?.targetProtein ?? 0;
        final targetCarbs = nutrition?.targetCarbs ?? 0;
        final targetFat = nutrition?.targetFat ?? 0;
        final meals = nutrition?.meals ?? [];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 65.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.waving_hand_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hai, NutriZen!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),

                _buildCalorieCircle(
                  calories: totalCalories.toDouble(),
                  target: targetCal.toDouble(),
                ),
                const SizedBox(height: 32.0),

                _buildNutrientCards(
                  protein: protein,
                  carbo: carbo,
                  fat: fat,
                  targetProtein: targetProtein,
                  targetCarbs: targetCarbs,
                  targetFat: targetFat,
                ),
                const SizedBox(height: 32.0),

                _buildMealsSection(meals, context),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        );
      },
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

  Widget _buildNutrientCards({
    required num protein,
    required num carbo,
    required num fat,
    required num targetProtein,
    required num targetCarbs,
    required num targetFat,
  }) {
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
                value: protein.toDouble(),
                target: targetProtein.toDouble(),
                color: const Color(0xFFFFB74D),
                icon: Icons.set_meal_rounded,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildNutrientRow(
                title: 'Karbohidrat',
                value: carbo.toDouble(),
                target: targetCarbs.toDouble(),
                color: const Color(0xFFFF9800),
                icon: Icons.rice_bowl_rounded,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildNutrientRow(
                title: 'Lemak',
                value: fat.toDouble(),
                target: targetFat.toDouble(),
                color: const Color(0xFFF44336),
                icon: Icons.opacity_rounded,
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
                  color: isAchieved
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}g / ${target.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isAchieved
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2E3842),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.toDouble()),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.8), color],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.no_meals_rounded,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada makanan yang dicatat hari ini',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final meal = meals[index];
              return MealCardWidget(meal: meal);
            },
          ),
      ],
    );
  }
}
