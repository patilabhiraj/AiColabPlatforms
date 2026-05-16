part of 'splash_bloc.dart';

abstract class SplashState {}

/// Initial — nothing has happened yet
class SplashInitial extends SplashState {}

/// Checking auth / loading config
class SplashLoading extends SplashState {}

/// Config loaded, stay on screen for user to log in
class SplashLoaded extends SplashState {}

/// User IS authenticated → go to home/chat
class SplashNavigateToHome extends SplashState {}
