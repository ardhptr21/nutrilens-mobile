import 'package:flutter/material.dart';
import 'package:nutrilens/presentation/pages/login_page.dart';
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
      backgroundColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF4CAF50),
    ),
    OnboardingItem(
      title: 'Scan Makanan Anda',
      description:
          'Cukup foto makanan Anda dan dapatkan informasi nutrisi lengkap secara otomatis dengan teknologi AI canggih.',
      icon: Icons.camera_alt_rounded,
      backgroundColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF2196F3),
    ),
    OnboardingItem(
      title: 'Pantau Nutrisi Harian',
      description:
          'Lacak asupan kalori, protein, lemak, dan karbohidrat harian Anda untuk mencapai target kesehatan yang optimal.',
      icon: Icons.analytics_rounded,
      backgroundColor: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFFF9800),
    ),
    OnboardingItem(
      title: 'Riwayat & Analisis',
      description:
          'Lihat riwayat makanan dan analisis nutrisi untuk memahami pola makan dan membuat keputusan yang lebih baik.',
      icon: Icons.history_rounded,
      backgroundColor: const Color(0xFFF3E5F5),
      iconColor: const Color(0xFF9C27B0),
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: item.backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: item.imagePath != null
                              ? Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: item.iconColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    item.imagePath!,
                                    width: 100,
                                    height: 100,
                                  ),
                                )
                              : Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        item.iconColor.withValues(alpha: 0.8),
                                        item.iconColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(35),
                                    boxShadow: [
                                      BoxShadow(
                                        color: item.iconColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 70,
                                    color: Colors.white,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 60),

                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3842),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                color: _onboardingItems[_currentPage].backgroundColor,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: _currentPage == index
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF66BB6A),
                                  ],
                                )
                              : null,
                          color: _currentPage != index
                              ? Colors.grey.shade400
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(
                          0xFF4CAF50,
                        ).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _onboardingItems.length - 1
                                ? 'Mulai Sekarang'
                                : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _onboardingItems.length - 1
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward_rounded,
                            size: 22,
                          ),
                        ],
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
