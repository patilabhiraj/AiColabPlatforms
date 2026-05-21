import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/entities/user_entity.dart';
import '../domain/usecases/google_login_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/register_usecase.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._googleLoginUseCase,
  ) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.info('🔐 Login attempt for: ${event.email}');
    emit(AuthLoading());
    
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        logger.warning('❌ Login failed for ${event.email}: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        logger.info('✅ Login successful for ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.info('📝 Registration attempt for: ${event.email}');
    emit(AuthLoading());
    
    final result = await _registerUseCase(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        logger.warning('❌ Registration failed for ${event.email}: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        logger.info('✅ Registration successful for ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.info('🔐 Google Sign-In attempt');
    emit(AuthLoading());
    
    final result = await _googleLoginUseCase(event.token);

    result.fold(
      (failure) {
        logger.warning('❌ Google Sign-In failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        logger.info('✅ Google Sign-In successful for ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }
}
