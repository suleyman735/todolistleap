import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isRegistered;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.isRegistered = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({bool? isRegistered, bool? isAuthenticated, String? error}) {
    return AuthState(
      isRegistered: isRegistered ?? this.isRegistered,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isRegistered, isAuthenticated, error];
}