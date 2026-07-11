import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/entities/user_entity.dart';
import '../domain/usecases/get_cached_user_usecase.dart';
import '../domain/usecases/google_login_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCachedUserUseCase _getCachedUserUseCase;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._googleLoginUseCase,
    this._logoutUseCase,
    this._getCachedUserUseCase,
  ) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCachedUserUseCase();

    result.fold(
      (failure) {
        logger.warning('No cached session found: ${failure.message}');
      },
      (user) {
        if (user != null) {
          logger.info('✅ Restored session for ${user.email}');
          emit(AuthAuthenticated(user));
        }
      },
    );
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
        if (failure is EmailVerificationFailure) {
          logger.warning('📧 Email verification required for ${failure.email}');
          emit(AuthEmailVerificationRequired(failure.email));
        } else {
          logger.warning('❌ Login failed for ${event.email}: ${failure.message}');
          emit(AuthError(failure.message));
        }
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
        if (failure is EmailVerificationFailure) {
          logger.warning('📧 Email verification required for ${failure.email}');
          emit(AuthEmailVerificationRequired(failure.email));
        } else {
          logger.warning('❌ Registration failed for ${event.email}: ${failure.message}');
          emit(AuthError(failure.message));
        }
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

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.info('🚪 Logout requested');
    
    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        logger.warning('❌ Logout failed: ${failure.message}');
        // Even if logout fails, clear the state
        emit(AuthInitial());
      },
      (_) {
        logger.info('✅ Logout successful');
        emit(AuthInitial());
      },
    );
  }
}
