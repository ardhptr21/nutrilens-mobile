import 'package:flutter/material.dart';
import 'history_detail_page.dart';

/// Model untuk 1 item riwayat nutrisi dengan data lengkap.
/// Field dapat mudah ditambah/dikurangi saat integrasi dengan backend.
class NutritionHistory {
  final String id;
  final DateTime date;
  final int totalCalories;
  final int calorieGoal;
  final int protein; // dalam gram
  final int fat; // dalam gram
  final int carbs; // dalam gram
  final List<String> mealSummary; // ringkasan menu

  const NutritionHistory({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.calorieGoal,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.mealSummary,
  });
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Data palsu untuk demo (nanti diganti dengan data dari backend/database)
  late final List<NutritionHistory> _items;

  @override
  void initState() {
    super.initState();
    _generateDummyData();
  }

  void _generateDummyData() {
    _items = [
      NutritionHistory(
        id: 'history-0',
        date: DateTime(2024, 12, 28),
        totalCalories: 2150,
        calorieGoal: 2000,
        protein: 85,
        fat: 65,
        carbs: 250,
        mealSummary: ['Nasi Kuning', 'Ayam Goreng', 'Sayur Asem'],
      ),
      NutritionHistory(
        id: 'history-1',
        date: DateTime(2024, 12, 27),
        totalCalories: 1950,
        calorieGoal: 2000,
        protein: 78,
        fat: 58,
        carbs: 238,
        mealSummary: ['Oatmeal', 'Chicken Salad', 'Sandwich'],
      ),
      NutritionHistory(
        id: 'history-2',
        date: DateTime(2024, 12, 26),
        totalCalories: 2300,
        calorieGoal: 2000,
        protein: 92,
        fat: 72,
        carbs: 275,
        mealSummary: ['Soto Ayam', 'Perkedel', 'Tahu Goreng', 'Rujak'],
      ),
      NutritionHistory(
        id: 'history-3',
        date: DateTime(2024, 12, 25),
        totalCalories: 1850,
        calorieGoal: 2000,
        protein: 72,
        fat: 52,
        carbs: 220,
        mealSummary: ['Smoothie Bowl', 'Wrap Sayuran'],
      ),
      NutritionHistory(
        id: 'history-4',
        date: DateTime(2024, 12, 24),
        totalCalories: 2050,
        calorieGoal: 2000,
        protein: 81,
        fat: 62,
        carbs: 245,
        mealSummary: ['Nasi Goreng', 'Telur Ceplok', 'Tempe Goreng'],
      ),
      NutritionHistory(
        id: 'history-5',
        date: DateTime(2024, 12, 23),
        totalCalories: 1900,
        calorieGoal: 2000,
        protein: 75,
        fat: 55,
        carbs: 230,
        mealSummary: ['Pasta Carbonara', 'Salad Caesar'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header halaman
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Riwayat Nutrisi',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // List riwayat
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                96, // ruang ekstra untuk bottom nav + FAB
              ),
              itemCount: _items.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _HistoryItemCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HistoryDetailPage(nutritionHistory: item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card untuk 1 item riwayat dengan layout yang informatif dan menarik.
/// Menampilkan: tanggal, total kalori, ringkasan menu, dan status nutrisi.
class _HistoryItemCard extends StatelessWidget {
  final NutritionHistory item;
  final VoidCallback? onTap;

  const _HistoryItemCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverCalorie = item.totalCalories > item.calorieGoal;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Tanggal + Status Kalori
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DateBadge(date: item.date),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isOverCalorie
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                    ),
                    child: Text(
                      '${item.totalCalories} kkal',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOverCalorie
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2: Progress Nutrisi Makro (protein, fat, carbs)
              _NutrientProgressRow(item: item),
              const SizedBox(height: 12),
              // Row 3: Ringkasan Menu
              _MealSummary(meals: item.mealSummary),
              const SizedBox(height: 12),
              // Row 4: Tombol Lihat Detail
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Lihat Detail',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge tanggal yang menampilkan hari dan bulan.
class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date.day.toString().padLeft(2, '0'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            _getMonthName(date.month),
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

/// Row yang menampilkan progress bar untuk protein, fat, dan carbs.
class _NutrientProgressRow extends StatelessWidget {
  final NutritionHistory item;

  const _NutrientProgressRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NutrientIndicator(
          label: 'Protein',
          value: item.protein,
          max: 100,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _NutrientIndicator(
          label: 'Lemak',
          value: item.fat,
          max: 80,
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _NutrientIndicator(
          label: 'Karbo',
          value: item.carbs,
          max: 300,
          color: Colors.amber,
        ),
      ],
    );
  }
}

/// Indikator nutrisi dengan progress bar mini.
class _NutrientIndicator extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _NutrientIndicator({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (value / max).clamp(0.0, 1.0);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value}g',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan ringkasan menu yang dimakan.
class _MealSummary extends StatelessWidget {
  final List<String> meals;

  const _MealSummary({required this.meals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Hari Ini',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: meals
              .map(
                (meal) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    meal,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
