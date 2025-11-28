import 'package:flutter/material.dart';
import 'package:nutrilens/presentation/widgets/card/nutrilent_card_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 65.0, horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hai, NutriZen!', style: TextStyle(fontSize: 18.0)),
            const Text(
              'Ardhi Putra Pradana',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 40.0),
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
                    children: [
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
            SizedBox(height: 40.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
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
