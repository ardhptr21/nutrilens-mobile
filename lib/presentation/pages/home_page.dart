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
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 65.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text('Hai, NutriZen!', style: theme.textTheme.titleMedium),
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32.0),

                // Calorie Circle
                _buildCalorieCircle(
                  calories: totalCalories.toDouble(),
                  target: targetCal.toDouble(),
                ),
                const SizedBox(height: 32.0),

                // Nutrient Cards
                _buildNutrientCards(
                  protein: protein,
                  carbo: carbo,
                  fat: fat,
                  targetProtein: targetProtein,
                  targetCarbs: targetCarbs,
                  targetFat: targetFat,
                ),
                const SizedBox(height: 32.0),

                // Meals Section
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
                            isAchieved ? '✓ Tercapai' : 'Belum Tercapai',
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
        Text(
          'Target',
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
                value: protein.toDouble(),
                target: targetProtein.toDouble(),
                color: Colors.yellow,
                icon: Icons.set_meal,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildNutrientRow(
                title: 'Karbohidrat',
                value: carbo.toDouble(),
                target: targetCarbs.toDouble(),
                color: Colors.orange,
                icon: Icons.rice_bowl,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildNutrientRow(
                title: 'Lemak',
                value: fat.toDouble(),
                target: targetFat.toDouble(),
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
          'Makanan & Minuman',
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
                'Belum ada makanan yang dicatat hari ini.',
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
}
