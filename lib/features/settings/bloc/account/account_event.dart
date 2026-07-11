part of 'account_bloc.dart';

abstract class AccountEvent {}

class AccountLoadRequested extends AccountEvent {}

class AccountUpdateRequested extends AccountEvent {
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImagePath;

  AccountUpdateRequested({
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImagePath,
  });
}

class AccountDeleteRequested extends AccountEvent {}
