import 'package:flutter/material.dart';
import 'package:nutrilens/presentation/widget_tree.dart';

void main() {
  runApp(const NutriLens());
}

class NutriLens extends StatelessWidget {
  const NutriLens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriLens',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const WidgetTree(),
    );
  }
}
