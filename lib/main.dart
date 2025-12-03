import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_bloc.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_event.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_state.dart';
import 'package:nutrilens/presentation/pages/login_page.dart';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
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
          return const LoginPage();
        },
      ),
    );
  }
}
