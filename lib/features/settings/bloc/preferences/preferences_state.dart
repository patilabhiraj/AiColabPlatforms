part of 'preferences_bloc.dart';

abstract class PreferencesState {}

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesError extends PreferencesState {
  final String message;
  PreferencesError(this.message);
}

class PreferencesLoaded extends PreferencesState {
  final bool enableFollowUpQuestions;
  final bool updating;
  final String? error;

  PreferencesLoaded({
    required this.enableFollowUpQuestions,
    this.updating = false,
    this.error,
  });

  PreferencesLoaded copyWith({
    bool? enableFollowUpQuestions,
    bool? updating,
    String? error,
  }) {
    return PreferencesLoaded(
      enableFollowUpQuestions:
          enableFollowUpQuestions ?? this.enableFollowUpQuestions,
      updating: updating ?? this.updating,
      error: error,
    );
  }
}
