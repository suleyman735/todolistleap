import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<RegisterEvent>(_onRegisterEvent);
    on<LoginEvent>(_onLoginEvent);
    on<CheckAuthEvent>(_onCheckAuthEvent);
    on<LogoutEvent>(_onLogoutEvent);
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    print('_onRegisterEvent${event.email}');
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('email');

      // Check if email is already registered
      if (storedEmail != null && storedEmail == event.email) {
        emit(state.copyWith(
          error: 'This email is already registered.',
          isRegistered: false,
        ));
        return;
      }
      // Store email and password
      await prefs.setString('email', event.email);
      await prefs.setString('password', event.password);
      emit(state.copyWith(isRegistered: true, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isRegistered: false));
    }
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    print('storeemail {storedEmail}');
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('email');
      final storedPassword = prefs.getString('password');


      if (storedEmail == event.email && storedPassword == event.password) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUserEmail', event.email);
        emit(state.copyWith(isAuthenticated: true, error: null));
      } else {
        emit(state.copyWith(error: 'Invalid email or password', isAuthenticated: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isAuthenticated: false));
    }
  }


  Future<void> _onCheckAuthEvent(CheckAuthEvent event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final storedEmail = prefs.getString('email');
      final storedPassword = prefs.getString('password');

      if (isLoggedIn && storedEmail != null && storedPassword != null) {
        emit(state.copyWith(isAuthenticated: true, error: null));
      } else {
        emit(state.copyWith(isAuthenticated: false, error: null));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isAuthenticated: false));
    }
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false); // Clear logged-in status
      await prefs.remove('currentUserEmail');
      emit(state.copyWith(isAuthenticated: false, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isAuthenticated: false));
    }
  }
}