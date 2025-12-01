// lib/presentation/pages/history_detail_page.dart
import 'package:flutter/material.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/presentation/widgets/card/nutrilent_card_widget.dart';

class HistoryDetailPage extends StatelessWidget {
  final NutritionModel item;

  const HistoryDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isOver = item.totalCalories > item.calorieGoal;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Nutrisi'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_formatDate(item.date), style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
            const SizedBox(height: 20),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOver ? Colors.red : Colors.green,
                border: Border.all(color: isOver ? Colors.redAccent : Colors.lightGreen, width: 6),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${item.totalCalories}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const Text('Kalori', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  NutrientCardWidget(title: 'Protein', value: item.protein, total: 100, color: Colors.yellow),
                  NutrientCardWidget(title: 'Karbohidrat', value: item.carbs, total: 300, color: Colors.orange),
                  NutrientCardWidget(title: 'Lemak', value: item.fat, total: 100, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
