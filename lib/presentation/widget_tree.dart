import 'package:flutter/material.dart';
import 'package:nutrilens/presentation/pages/history_page.dart';
import 'package:nutrilens/presentation/pages/home_page.dart';
import 'package:nutrilens/presentation/pages/scan_page.dart';
import 'package:nutrilens/presentation/pages/settings_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _selectedIndex = 0;
  final GlobalKey _historyPageKey = GlobalKey();
  final GlobalKey _homePageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  width: 32,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Nutrilens',
                style: TextStyle(
                  color: Color(0xFF2E3842),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        leadingWidth: 160,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF4CAF50)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(key: _homePageKey),
          HistoryPage(key: _historyPageKey),
        ],
      ),
      floatingActionButton: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 32,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanPage()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        notchMargin: 8,
        padding: EdgeInsets.zero,
        height: 65,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: _selectedIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                    final state = _homePageKey.currentState as HomePageState?;
                    state?.refresh();
                  });
                },
              ),
              const SizedBox(width: 72),
              _buildNavItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                isSelected: _selectedIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                    final state =
                        _historyPageKey.currentState as HistoryPageState?;
                    state?.refreshHistory();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
