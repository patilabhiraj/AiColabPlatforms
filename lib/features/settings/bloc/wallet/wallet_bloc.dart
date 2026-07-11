import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/get_wallet_usecase.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletUseCase _getWalletUseCase;
  final GetWalletTransactionsUseCase _getWalletTransactionsUseCase;

  static const int _pageSize = 10;

  WalletBloc(this._getWalletUseCase, this._getWalletTransactionsUseCase)
      : super(WalletInitial()) {
    on<WalletLoadRequested>(_onLoadRequested);
    on<WalletTransactionsPageRequested>(_onTransactionsPageRequested);
  }

  Future<void> _onLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    final result = await _getWalletUseCase();
    await result.fold(
      (failure) async => emit(WalletError(failure.message)),
      (wallet) async {
        emit(WalletLoaded(wallet: wallet));
        add(WalletTransactionsPageRequested(page: 1));
      },
    );
  }

  Future<void> _onTransactionsPageRequested(
    WalletTransactionsPageRequested event,
    Emitter<WalletState> emit,
  ) async {
    final current = state;
    if (current is! WalletLoaded) return;

    emit(current.copyWith(transactionsLoading: true));
    final result = await _getWalletTransactionsUseCase(
      page: event.page,
      pageSize: _pageSize,
    );
    result.fold(
      (failure) => emit(current.copyWith(
        transactionsLoading: false,
        transactionsError: failure.message,
      )),
      (page) => emit(current.copyWith(
        transactions: page.items,
        transactionsLoading: false,
        transactionsError: null,
        page: event.page,
        totalPages: page.totalPages,
        totalRecords: page.totalRecords,
      )),
    );
  }
}
