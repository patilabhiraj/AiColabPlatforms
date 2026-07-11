part of 'preferences_bloc.dart';

abstract class PreferencesEvent {}

class PreferencesLoadRequested extends PreferencesEvent {}

class PreferencesFollowUpToggled extends PreferencesEvent {
  final bool value;
  PreferencesFollowUpToggled(this.value);
}
