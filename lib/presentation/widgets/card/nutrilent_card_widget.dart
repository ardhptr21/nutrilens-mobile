// lib/presentation/widgets/card/nutrilent_card_widget.dart
import 'package:flutter/material.dart';

class NutrientCardWidget extends StatelessWidget {
  final String title;
  final int value;
  final int total;
  final Color color;

  const NutrientCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (total == 0) ? 0.0 : (value / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text("$value g"),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              color: color,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
            ),
          )
        ],
      ),
    );
  }
}
