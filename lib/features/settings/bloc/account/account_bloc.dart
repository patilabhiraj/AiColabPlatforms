import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/account_entity.dart';
import '../../domain/usecases/account_usecases.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  AccountBloc(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._deleteAccountUseCase,
  ) : super(AccountInitial()) {
    on<AccountLoadRequested>(_onLoadRequested);
    on<AccountUpdateRequested>(_onUpdateRequested);
    on<AccountDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    AccountLoadRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await _getProfileUseCase();
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (account) => emit(AccountLoaded(account: account)),
    );
  }

  Future<void> _onUpdateRequested(
    AccountUpdateRequested event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is! AccountLoaded) return;

    emit(current.copyWith(saving: true, saveError: null, saved: false));
    final result = await _updateProfileUseCase(
      firstName: event.firstName,
      lastName: event.lastName,
      phoneNumber: event.phoneNumber,
      profileImagePath: event.profileImagePath,
    );
    result.fold(
      (failure) => emit(current.copyWith(
        saving: false,
        saveError: failure.message,
      )),
      (account) => emit(current.copyWith(
        account: account,
        saving: false,
        saved: true,
      )),
    );
  }

  Future<void> _onDeleteRequested(
    AccountDeleteRequested event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is! AccountLoaded) return;

    emit(current.copyWith(deleting: true, deleteError: null));
    final result = await _deleteAccountUseCase('${current.account.id}');
    result.fold(
      (failure) => emit(current.copyWith(
        deleting: false,
        deleteError: failure.message,
      )),
      (_) => emit(AccountDeleted()),
    );
  }
}
