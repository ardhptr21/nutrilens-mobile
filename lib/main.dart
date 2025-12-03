import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_bloc.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_event.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_state.dart';
import 'package:nutrilens/presentation/pages/onboarding_page.dart';
import 'package:nutrilens/presentation/widget_tree.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('dotenv loaded: ${dotenv.env['BASE_API_URL']}');
  } catch (e, st) {
    debugPrint('Failed to load .env: $e\n$st');
  }

  try {
    setupLocator();
    debugPrint('Locator setup complete');
  } catch (e, st) {
    debugPrint('Error during setupLocator: $e\n$st');
  }

  runApp(
    BlocProvider(
      create: (_) => AuthBloc()..add(AppStarted()),
      child: const NutriLens(),
    ),
  );
}

class NutriLens extends StatelessWidget {
  const NutriLens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      title: 'NutriLens',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF66BB6A),
          tertiary: const Color(0xFF81C784),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF2E3842)),
          titleTextStyle: TextStyle(
            color: Color(0xFF2E3842),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shadowColor: Color(0x14000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3842),
            letterSpacing: -0.5,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3842),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3842),
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3842),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3842),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3842),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4A5568)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
        ),
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (_, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthAuthenticated) {
            return const WidgetTree();
          }
          return const OnboardingPage();
        },
      ),
    );
  }
}
