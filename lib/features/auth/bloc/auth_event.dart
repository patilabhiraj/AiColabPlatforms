part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class AuthGoogleSignInRequested extends AuthEvent {
  final String token;
  AuthGoogleSignInRequested({required this.token});
}

class AuthLogoutRequested extends AuthEvent {}
