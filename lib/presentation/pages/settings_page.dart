import 'package:flutter/material.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/network/http/user/user_model.dart';
import 'package:nutrilens/network/http/user/user_service.dart';
import 'package:nutrilens/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController caloryController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();

  final UserService _userService = locator<UserService>();
  bool _isLoadingUser = true;
  bool _isLoadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPreferences();
  }

  @override
  void dispose() {
    nameController.dispose();
    caloryController.dispose();
    proteinController.dispose();
    fatController.dispose();
    carbsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final res = await _userService.getUserMe();
      if (res.success && mounted) {
        setState(() {
          nameController.text = res.data!.name;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUser = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data akun: $e')));
      }
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final res = await _userService.getUserPreferences();
      if (res.success && mounted) {
        setState(() {
          caloryController.text = res.data!.targetCal.toString();
          proteinController.text = res.data!.targetProtein.toString();
          fatController.text = res.data!.targetFat.toString();
          carbsController.text = res.data!.targetCarbs.toString();
          _isLoadingPreferences = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPreferences = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat preferensi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF66BB6A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Informasi Akun',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3842),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _isLoadingUser
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama',
                                      hintText: 'Masukkan nama Anda',
                                      prefixIcon: Icon(
                                        Icons.badge_rounded,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: _handleSaveAccount,
                                      icon: const Icon(
                                        Icons.save_rounded,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Simpan Perubahan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9800),
                                    Color(0xFFFFB74D),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.track_changes_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Target Nutrisi',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3842),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _isLoadingPreferences
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  TextField(
                                    controller: caloryController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Kalori (kkal)',
                                      hintText: 'Target kalori harian',
                                      prefixIcon: Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Color(0xFFF44336),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: proteinController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Protein (g)',
                                      hintText: 'Target protein harian',
                                      prefixIcon: Icon(
                                        Icons.set_meal_rounded,
                                        color: Color(0xFFFFB74D),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: fatController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Lemak (g)',
                                      hintText: 'Target lemak harian',
                                      prefixIcon: Icon(
                                        Icons.opacity_rounded,
                                        color: Color(0xFFF44336),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: carbsController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Karbohidrat (g)',
                                      hintText: 'Target karbohidrat harian',
                                      prefixIcon: Icon(
                                        Icons.rice_bowl_rounded,
                                        color: Color(0xFFFF9800),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: _handleSavePreferences,
                                      icon: const Icon(
                                        Icons.save_rounded,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Simpan Preferensi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, size: 22),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSaveAccount() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong.')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await _userService.updateUser(UserUpdateRequest(name: name));

      if (!mounted) return;
      Navigator.pop(context);

      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil disimpan!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.message)));
      }
      return;
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan akun: $e')));
      return;
    }
  }

  void _handleSavePreferences() async {
    final calory = caloryController.text.trim();
    final protein = proteinController.text.trim();
    final fat = fatController.text.trim();
    final carbs = carbsController.text.trim();

    if (calory.isEmpty || protein.isEmpty || fat.isEmpty || carbs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua bidang harus diisi.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await _userService.updateUserPreferences(
        UserUpdatePreferenceRequest(
          targetCal: double.parse(calory),
          targetProtein: double.parse(protein),
          targetFat: double.parse(fat),
          targetCarbs: double.parse(carbs),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferensi berhasil disimpan!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.message)));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan preferensi: $e')));
    }
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
