import 'package:flutter/material.dart';
import 'history_page.dart' show NutritionHistory;

class HistoryDetailPage extends StatelessWidget {
  final NutritionHistory nutritionHistory;

  const HistoryDetailPage({
    required this.nutritionHistory,
    super.key,
  });

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
