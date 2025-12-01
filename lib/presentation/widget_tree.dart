// lib/presentation/widget_tree.dart
import 'package:flutter/material.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/presentation/pages/history_page.dart';
import 'package:nutrilens/presentation/pages/home_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _selectedIndex = 0;

  final List<NutritionModel> dummyHistory = [
    NutritionModel(id: 'h-1', date: DateTime(2025,12,01), totalCalories: 1280, calorieGoal: 2000, protein: 50, carbs: 80, fat: 13),
    NutritionModel(id: 'h-2', date: DateTime(2025,11,30), totalCalories: 1500, calorieGoal: 2000, protein: 70, carbs: 120, fat: 20),
    NutritionModel(id: 'h-3', date: DateTime(2025,11,29), totalCalories: 2300, calorieGoal: 2000, protein: 90, carbs: 200, fat: 40),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: [
        const HomePage(),
        HistoryPage(history: dummyHistory),
      ]),
      floatingActionButton: SizedBox(width: 70, height: 70, child: FloatingActionButton(shape: const CircleBorder(), backgroundColor: Colors.green, child: const Icon(Icons.camera, size: 40, color: Colors.white), onPressed: () {})),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(currentIndex: _selectedIndex, items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
      ], onTap: (v) => setState(() => _selectedIndex = v)),
    );
  }
}
