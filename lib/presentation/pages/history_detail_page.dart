import 'package:flutter/material.dart';
import 'package:nutrilens/models/nutrition_model.dart';

class HistoryDetailPage extends StatelessWidget {
  final NutritionModel nutrition;

  const HistoryDetailPage({required this.nutrition, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Pakai warna background dari theme supaya konsisten dengan halaman lain
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Detail Riwayat'),
        centerTitle: true,
        elevation: 0,
      ),
      // Body kosong, temanmu bisa isi nanti
      body: const SizedBox.expand(),
    );
  }
}
