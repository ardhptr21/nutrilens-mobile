import 'package:flutter/material.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/nutrition_model.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';
import 'package:nutrilens/presentation/widgets/card/history_card_widget.dart';

import 'history_detail_page.dart';

// Public interface for HistoryPage state
abstract class HistoryPageState {
  void refreshHistory();
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

// Export this state for use in widget tree
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
        // Deduplicate by date - keep only one entry per day
        final Map<String, NutritionModel> uniqueByDate = {};

        for (final nutrition in response.data!) {
          final dateKey =
              '${nutrition.logAt.year}-${nutrition.logAt.month}-${nutrition.logAt.day}';

          // If already exists for this date, keep the one with more calories (more complete)
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

        // Sort by date descending (newest first)
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
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Riwayat Nutrisi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<NutritionModel>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _historyFuture = _fetchNutritionHistory();
                              });
                            },
                            child: const Text('Retry'),
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
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat nutrisi',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 12),
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
