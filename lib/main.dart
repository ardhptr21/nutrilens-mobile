import 'package:flutter/material.dart';
import 'package:nutrilens/presentation/pages/home_page.dart';

void main() {
  runApp(const NutriLens());
}

class NutriLens extends StatelessWidget {
  const NutriLens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriLens',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.amberAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
