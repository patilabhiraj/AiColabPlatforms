import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImage;

  const AccountEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImage,
  });

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phoneNumber, profileImage];
}

class UserPreferencesEntity extends Equatable {
  final bool enableFollowUpQuestions;

  const UserPreferencesEntity({required this.enableFollowUpQuestions});

  @override
  List<Object?> get props => [enableFollowUpQuestions];
}

class ArchivedChatEntity extends Equatable {
  final String id;
  final String title;
  final DateTime updatedAt;

  const ArchivedChatEntity({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, updatedAt];
}
