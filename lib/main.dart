import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_bloc.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_event.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_state.dart';
import 'package:nutrilens/presentation/pages/login_page.dart';
import 'package:nutrilens/presentation/widget_tree.dart';

void main() {
  setupLocator();
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
      title: 'NutriLens',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.green,
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
