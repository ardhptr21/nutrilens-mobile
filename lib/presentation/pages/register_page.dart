import 'package:flutter/material.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/network/http/auth/auth_model.dart';
import 'package:nutrilens/network/http/auth/auth_service.dart';
import 'package:nutrilens/presentation/pages/login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50).withValues(alpha: 0.05),
              const Color(0xFF81C784).withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 40.0,
                  horizontal: 32.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'NutriLens',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Daftar Akun Baru 🌟',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat akun untuk memulai perjalanan hidup sehat Anda bersama kami.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const _RegisterForm(),
                    const SizedBox(height: 32),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Masuk Sekarang',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFF4CAF50),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => __RegisterFormState();
}

class __RegisterFormState extends State<_RegisterForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama',
            hintText: 'Masukkan nama lengkap',
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Masukkan email Anda',
            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Kata Sandi',
            hintText: 'Buat kata sandi',
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Daftar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      if (!mounted) return;
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

    final AuthService authService = locator<AuthService>();

    final res = await authService.register(
      RegisterRequest(email: email, password: password, name: name),
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan masuk.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }
}
