import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/preferences_usecases.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetPreferencesUseCase _getPreferencesUseCase;
  final UpdatePreferencesUseCase _updatePreferencesUseCase;

  PreferencesBloc(this._getPreferencesUseCase, this._updatePreferencesUseCase)
      : super(PreferencesInitial()) {
    on<PreferencesLoadRequested>(_onLoadRequested);
    on<PreferencesFollowUpToggled>(_onFollowUpToggled);
  }

  Future<void> _onLoadRequested(
    PreferencesLoadRequested event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(PreferencesLoading());
    final result = await _getPreferencesUseCase();
    result.fold(
      (failure) => emit(PreferencesError(failure.message)),
      (prefs) => emit(PreferencesLoaded(
        enableFollowUpQuestions: prefs.enableFollowUpQuestions,
      )),
    );
  }

  Future<void> _onFollowUpToggled(
    PreferencesFollowUpToggled event,
    Emitter<PreferencesState> emit,
  ) async {
    final current = state;
    if (current is! PreferencesLoaded) return;

    emit(current.copyWith(updating: true));
    final result = await _updatePreferencesUseCase(
      enableFollowUpQuestions: event.value,
    );
    result.fold(
      (failure) => emit(current.copyWith(
        updating: false,
        error: failure.message,
      )),
      (prefs) => emit(current.copyWith(
        enableFollowUpQuestions: prefs.enableFollowUpQuestions,
        updating: false,
        error: null,
      )),
    );
  }
}
