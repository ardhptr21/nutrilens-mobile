import 'package:flutter/material.dart';

class NutrientCardWidget extends StatelessWidget {
  final String title;
  final double value;
  final double total;
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
    double progress = (total == 0) ? 0 : value / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
          const SizedBox(height: 5.0),

          Row(
            children: [
              Text(
                '${value}g ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              Text(
                '/ ${total}g',
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: Colors.grey.shade300,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
