import 'package:flutter/material.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';
import 'package:nutrilens/presentation/widgets/card/history_card_widget.dart';

import 'history_detail_page.dart';

abstract class HistoryPageState {
  void refreshHistory();
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> implements HistoryPageState {
  late final NutritionService _nutritionService;
  late Future<List<NutritionModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _nutritionService = locator<NutritionService>();
    _historyFuture = _fetchNutritionHistory();
  }

  @override
  void refreshHistory() {
    setState(() {
      _historyFuture = _fetchNutritionHistory();
    });
  }

  Future<List<NutritionModel>> _fetchNutritionHistory() async {
    try {
      final response = await _nutritionService.getNutritionHistory(30);
      if (response.success && response.data != null) {
        final Map<String, NutritionModel> uniqueByDate = {};

        for (final nutrition in response.data!) {
          final dateKey =
              '${nutrition.logAt.year}-${nutrition.logAt.month}-${nutrition.logAt.day}';

          if (uniqueByDate.containsKey(dateKey)) {
            if (nutrition.cal > uniqueByDate[dateKey]!.cal) {
              uniqueByDate[dateKey] = NutritionModel(
                logAt: nutrition.logAt,
                cal: nutrition.cal,
                fat: nutrition.fat,
                protein: nutrition.protein,
                carbs: nutrition.carbs,
                targetCal: nutrition.targetCal,
                targetFat: nutrition.targetFat,
                targetCarbs: nutrition.targetCarbs,
                targetProtein: nutrition.targetProtein,
              );
            }
          } else {
            uniqueByDate[dateKey] = NutritionModel(
              logAt: nutrition.logAt,
              cal: nutrition.cal,
              fat: nutrition.fat,
              protein: nutrition.protein,
              carbs: nutrition.carbs,
              targetCal: nutrition.targetCal,
              targetFat: nutrition.targetFat,
              targetCarbs: nutrition.targetCarbs,
              targetProtein: nutrition.targetProtein,
            );
          }
        }

        final items = uniqueByDate.values.toList();
        items.sort((a, b) => b.logAt.compareTo(a.logAt));

        return items;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Riwayat',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<NutritionModel>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat riwayat...',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _historyFuture = _fetchNutritionHistory();
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Belum ada riwayat',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai catat makanan Anda untuk\nmelihat riwayat nutrisi',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return HistoryCardWidget(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryDetailPage(nutrition: item),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
