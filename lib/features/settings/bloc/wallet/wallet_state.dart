part of 'wallet_bloc.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}

class WalletLoaded extends WalletState {
  final WalletEntity wallet;
  final List<WalletTransactionEntity> transactions;
  final bool transactionsLoading;
  final String? transactionsError;
  final int page;
  final int totalPages;
  final int totalRecords;

  WalletLoaded({
    required this.wallet,
    this.transactions = const [],
    this.transactionsLoading = false,
    this.transactionsError,
    this.page = 1,
    this.totalPages = 1,
    this.totalRecords = 0,
  });

  WalletLoaded copyWith({
    WalletEntity? wallet,
    List<WalletTransactionEntity>? transactions,
    bool? transactionsLoading,
    String? transactionsError,
    int? page,
    int? totalPages,
    int? totalRecords,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      transactionsLoading: transactionsLoading ?? this.transactionsLoading,
      transactionsError: transactionsError,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
    );
  }
}
