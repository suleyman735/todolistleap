import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  const RegisterEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}