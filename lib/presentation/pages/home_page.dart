import 'package:flutter/material.dart';
import 'package:nutrilens/presentation/widgets/card/nutrilent_card_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 65.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hai, NutriZen!', style: textTheme.titleMedium),
            Text(
              'Ardhi Putra Pradana',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 40.0),

            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  border: Border.all(color: Colors.lightGreen, width: 5.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '1280',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32.0,
                        ),
                      ),
                      Text(
                        'Kalori',
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  NutrientCardWidget(
                    title: 'Protein',
                    value: 50,
                    total: 100,
                    color: Colors.yellow,
                  ),
                  NutrientCardWidget(
                    title: 'Karbohidrat',
                    value: 80,
                    total: 100,
                    color: Colors.orange,
                  ),
                  NutrientCardWidget(
                    title: 'Lemak',
                    value: 13,
                    total: 100,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
