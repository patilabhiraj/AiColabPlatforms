part of 'account_bloc.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}

class AccountDeleted extends AccountState {}

class AccountLoaded extends AccountState {
  final AccountEntity account;
  final bool saving;
  final String? saveError;
  final bool saved;
  final bool deleting;
  final String? deleteError;

  AccountLoaded({
    required this.account,
    this.saving = false,
    this.saveError,
    this.saved = false,
    this.deleting = false,
    this.deleteError,
  });

  AccountLoaded copyWith({
    AccountEntity? account,
    bool? saving,
    String? saveError,
    bool? saved,
    bool? deleting,
    String? deleteError,
  }) {
    return AccountLoaded(
      account: account ?? this.account,
      saving: saving ?? this.saving,
      saveError: saveError,
      saved: saved ?? false,
      deleting: deleting ?? this.deleting,
      deleteError: deleteError,
    );
  }
}
