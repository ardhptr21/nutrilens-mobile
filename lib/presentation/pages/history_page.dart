import 'package:flutter/material.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/presentation/widgets/card/history_card_widget.dart';

import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final List<NutritionModel> _items;

  @override
  void initState() {
    super.initState();
    _generateDummyData();
  }

  void _generateDummyData() {
    _items = [
      NutritionModel(
        id: 'history-0',
        date: DateTime(2024, 12, 28),
        totalCalories: 2150,
        calorieGoal: 2000,
        protein: 85,
        fat: 65,
        carbs: 250,
      ),
      NutritionModel(
        id: 'history-1',
        date: DateTime(2024, 12, 27),
        totalCalories: 1950,
        calorieGoal: 2000,
        protein: 78,
        fat: 58,
        carbs: 238,
      ),
      NutritionModel(
        id: 'history-2',
        date: DateTime(2024, 12, 26),
        totalCalories: 2300,
        calorieGoal: 2000,
        protein: 92,
        fat: 72,
        carbs: 275,
      ),
      NutritionModel(
        id: 'history-3',
        date: DateTime(2024, 12, 25),
        totalCalories: 1850,
        calorieGoal: 2000,
        protein: 72,
        fat: 52,
        carbs: 220,
      ),
      NutritionModel(
        id: 'history-4',
        date: DateTime(2024, 12, 24),
        totalCalories: 2050,
        calorieGoal: 2000,
        protein: 81,
        fat: 62,
        carbs: 245,
      ),
      NutritionModel(
        id: 'history-5',
        date: DateTime(2024, 12, 23),
        totalCalories: 1900,
        calorieGoal: 2000,
        protein: 75,
        fat: 55,
        carbs: 230,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Riwayat Nutrisi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return HistoryCardWidget(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HistoryDetailPage(nutrition: item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
