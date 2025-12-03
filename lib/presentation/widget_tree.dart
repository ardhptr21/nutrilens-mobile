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
        surfaceTintColor: Colors.white,
        leading: Row(
          children: [
            const SizedBox(width: 12),
            Image.asset(
              'assets/images/logo.png', // your logo
              height: 26,
            ),
            const SizedBox(width: 10),
            const Text(
              'Nutrilens',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leadingWidth: 160,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(key: _homePageKey),
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
            ),
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
            if (value == 0) {
              final state = _homePageKey.currentState as HomePageState?;
              state?.refresh();
            }

            if (value == 1) {
              final state = _historyPageKey.currentState as HistoryPageState?;
              state?.refreshHistory();
            }
          });
        },
      ),
    );
  }
}
