// lib/presentation/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/presentation/pages/history_detail_page.dart';
import 'package:nutrilens/presentation/widgets/card/history_card_widget.dart';

class HistoryPage extends StatelessWidget {
  final List<NutritionModel> history;

  const HistoryPage({super.key, this.history = const []});

  @override
  Widget build(BuildContext context) {
    final defaultHistory = [
      NutritionModel(
        id: 'h-1',
        date: DateTime(2025, 12, 1),
        totalCalories: 1280,
        calorieGoal: 2000,
        protein: 50,
        carbs: 80,
        fat: 13,
      ),
      NutritionModel(
        id: 'h-2',
        date: DateTime(2025, 11, 30),
        totalCalories: 1500,
        calorieGoal: 2000,
        protein: 70,
        carbs: 120,
        fat: 20,
      ),
      NutritionModel(
        id: 'h-3',
        date: DateTime(2025, 11, 29),
        totalCalories: 2300,
        calorieGoal: 2000,
        protein: 90,
        carbs: 200,
        fat: 40,
      ),
    ];

    final items = history.isNotEmpty ? history : defaultHistory;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Nutrisi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return HistoryCardWidget(
            item: item,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryDetailPage(item: item)));
            },
          );
        },
      ),
    );
  }
}
