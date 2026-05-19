import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/usecases/get_cached_user_usecase.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCachedUserUseCase _getCachedUserUseCase;

  SplashBloc(this._getCachedUserUseCase) : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    print('DEBUG: SplashBloc started. Checking local session...');
    // Minimum visual splash display duration
    await Future.delayed(const Duration(milliseconds: 2200));

    final result = await _getCachedUserUseCase();

    result.fold(
      (failure) {
        print('DEBUG ERROR: SplashBloc session check failed: ${failure.message}');
        emit(SplashLoaded());
      },
      (user) {
        if (user != null) {
          print('DEBUG: Valid local session found for ${user.email}. Redirecting to ChatPage!');
          emit(SplashNavigateToHome()); // Logged in! Go to Chat
        } else {
          print('DEBUG: No active local session found. Showing Onboarding.');
          emit(SplashLoaded()); // Not logged in! Show sign-in options
        }
      },
    );
  }
}
