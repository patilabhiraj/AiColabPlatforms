import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    // Minimum splash display duration + any init work
    // (e.g., check cached auth token, load remote config)
    await Future.delayed(const Duration(milliseconds: 2800));

    // TODO: Inject CheckAuthStatusUseCase and call it here.
    // Example:
    //   final isLoggedIn = await _checkAuthStatus();
    //   if (isLoggedIn) {
    //     emit(SplashNavigateToHome());
    //   } else {
    //     emit(SplashLoaded());
    //   }

    emit(SplashLoaded());
  }
}
