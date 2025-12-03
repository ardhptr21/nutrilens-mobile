import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_event.dart';
import 'package:nutrilens/presentation/bloc/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<OnboardingCompleted>(_onOnboardingCompleted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated());
    } else if (onboardingCompleted) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthOnboardingRequired());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', event.token);
    emit(AuthAuthenticated());
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    emit(AuthUnauthenticated());
  }

  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    emit(AuthUnauthenticated());
  }
}
