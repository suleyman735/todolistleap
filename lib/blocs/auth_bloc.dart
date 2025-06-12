import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<RegisterEvent>(_onRegisterEvent);
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    print('_onRegisterEvent${event.email}');
    try {
      final prefs = await SharedPreferences.getInstance();
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
        emit(state.copyWith(isAuthenticated: true, error: null));
      } else {
        emit(state.copyWith(error: 'Invalid email or password', isAuthenticated: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isAuthenticated: false));
    }
  }
}