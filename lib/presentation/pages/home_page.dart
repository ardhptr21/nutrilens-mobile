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
import 'package:nutrilens/presentation/widgets/card/nutrilent_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late Future<(UserMeResponse?, NutritionStatisticsResponse?)> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
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
    final textTheme = theme.textTheme;

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
            padding: const EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 65.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hai, NutriZen!', style: textTheme.titleMedium),
                Text(
                  name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 40.0),

                _buildCalorieCircle(
                  calories: totalCalories.toDouble(),
                  target: targetCal.toDouble(),
                ),

                const SizedBox(height: 40.0),

                _buildNutrientCards(
                  protein: protein,
                  carbo: carbo,
                  fat: fat,
                  targetProtein: targetProtein,
                  targetCarbs: targetCarbs,
                  targetFat: targetFat,
                ),

                const SizedBox(height: 40.0),

                Text(
                  'Riwayat Makanan Hari Ini',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildMealsList(meals),
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

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.toDouble()),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 15,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      calories.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dari ${target.toStringAsFixed(0)} kkal',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          NutrientCardWidget(
            title: 'Protein',
            value: protein.toDouble(),
            total: targetProtein.toDouble(),
            color: Colors.yellow,
          ),
          NutrientCardWidget(
            title: 'Karbohidrat',
            value: carbo.toDouble(),
            total: targetCarbs.toDouble(),
            color: Colors.orange,
          ),
          NutrientCardWidget(
            title: 'Lemak',
            value: fat.toDouble(),
            total: targetFat.toDouble(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(List<MealModel> meals) {
    if (meals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: const Center(
          child: Text(
            'Belum ada makanan yang dicatat hari ini.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      children: meals.map((meal) => MealCardWidget(meal: meal)).toList(),
    );
  }
}
