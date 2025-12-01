// lib/presentation/widgets/card/history_card_widget.dart
import 'package:flutter/material.dart';
import 'package:nutrilens/models/nutrition_model.dart';

class HistoryCardWidget extends StatelessWidget {
  final NutritionModel item;
  final VoidCallback? onTap;
  final Color? highlightColor;

  const HistoryCardWidget({
    super.key,
    required this.item,
    this.onTap,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlightColor ?? (item.totalCalories > item.calorieGoal ? Colors.red : Colors.green);

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DateBadge(date: item.date),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: item.totalCalories > item.calorieGoal ? Colors.red.shade50 : Colors.green.shade50,
                    ),
                    child: Text(
                      '${item.totalCalories} kkal',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: item.totalCalories > item.calorieGoal ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _NutrientProgressRow(item: item),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Lihat Detail',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;
  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date.day.toString().padLeft(2, '0'),
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(_getMonthName(date.month),
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.black54)),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}

class _NutrientProgressRow extends StatelessWidget {
  final NutritionModel item;
  const _NutrientProgressRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NutrientIndicator(label: 'Protein', value: item.protein, max: 100, color: Colors.yellow),
        const SizedBox(width: 12),
        _NutrientIndicator(label: 'Lemak', value: item.fat, max: 80, color: Colors.orange),
        const SizedBox(width: 12),
        _NutrientIndicator(label: 'Karbo', value: item.carbs, max: 300, color: Colors.red),
      ],
    );
  }
}

class _NutrientIndicator extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  const _NutrientIndicator({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (value / max).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: color, minHeight: 6),
          ),
          const SizedBox(height: 4),
          Text('${value}g', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
