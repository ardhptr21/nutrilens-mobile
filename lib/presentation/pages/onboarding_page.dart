import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_bloc.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Selamat Datang di NutriLens',
      description:
          'Asisten nutrisi personal Anda untuk hidup yang lebih sehat. Mari mulai perjalanan nutrisi Anda bersama kami!',
      imagePath: 'assets/images/logo.png',
      backgroundColor: Colors.green.shade50,
      iconColor: Colors.green,
    ),
    OnboardingItem(
      title: 'Scan Makanan Anda',
      description:
          'Cukup foto makanan Anda dan dapatkan informasi nutrisi lengkap secara otomatis dengan teknologi AI canggih.',
      icon: Icons.camera_alt,
      backgroundColor: Colors.blue.shade50,
      iconColor: Colors.blue,
    ),
    OnboardingItem(
      title: 'Pantau Nutrisi Harian',
      description:
          'Lacak asupan kalori, protein, lemak, dan karbohidrat harian Anda untuk mencapai target kesehatan yang optimal.',
      icon: Icons.bar_chart,
      backgroundColor: Colors.orange.shade50,
      iconColor: Colors.orange,
    ),
    OnboardingItem(
      title: 'Riwayat & Analisis',
      description:
          'Lihat riwayat makanan dan analisis nutrisi untuk memahami pola makan dan membuat keputusan yang lebih baik.',
      icon: Icons.history,
      backgroundColor: Colors.purple.shade50,
      iconColor: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;
    context.read<AuthBloc>().add(OnboardingCompleted());
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return Container(
                    color: item.backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon or Image
                        if (item.imagePath != null)
                          Image.asset(item.imagePath!, width: 120, height: 120)
                        else if (item.icon != null)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: item.iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              item.icon,
                              size: 60,
                              color: item.iconColor,
                            ),
                          ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section with indicators and button
            Container(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.green
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == _onboardingItems.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String? imagePath;
  final IconData? icon;
  final Color backgroundColor;
  final Color iconColor;

  OnboardingItem({
    required this.title,
    required this.description,
    this.imagePath,
    this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}
