import 'package:flutter/material.dart';
import 'package:nutrilens/presentation/pages/history_page.dart';
import 'package:nutrilens/presentation/pages/home_page.dart';
import 'package:nutrilens/presentation/pages/login_page.dart';
import 'package:nutrilens/presentation/pages/scan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _selectedIndex = 0;
  final GlobalKey _historyPageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _handleLogout,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Logout', style: TextStyle(color: Colors.red)),
                SizedBox(width: 10),
                Icon(Icons.logout, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomePage(),
          HistoryPage(key: _historyPageKey),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.green,
          child: const Icon(Icons.camera, size: 40, color: Colors.white),
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanPage()),
            ).then((_) {
              // Refresh history when returning from scan
              final state = _historyPageKey.currentState as HistoryPageState?;
              state?.refreshHistory();
            }),
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
            // Refresh history when navigating to history tab
            if (value == 1) {
              final state = _historyPageKey.currentState as HistoryPageState?;
              state?.refreshHistory();
            }
          });
        },
      ),
    );
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
