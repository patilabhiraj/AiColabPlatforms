part of 'wallet_bloc.dart';

abstract class WalletEvent {}

class WalletLoadRequested extends WalletEvent {}

class WalletTransactionsPageRequested extends WalletEvent {
  final int page;
  WalletTransactionsPageRequested({required this.page});
}
