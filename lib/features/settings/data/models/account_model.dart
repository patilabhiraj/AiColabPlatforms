import '../../domain/entities/account_entity.dart';
import 'json_parsing.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phoneNumber,
    super.profileImage,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: parseInt(json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }
}

class UserPreferencesModel extends UserPreferencesEntity {
  const UserPreferencesModel({required super.enableFollowUpQuestions});

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      enableFollowUpQuestions: json['enableFollowUpQuestions'] == true,
    );
  }
}

class ArchivedChatModel extends ArchivedChatEntity {
  const ArchivedChatModel({
    required super.id,
    required super.title,
    required super.updatedAt,
  });

  factory ArchivedChatModel.fromJson(Map<String, dynamic> json) {
    return ArchivedChatModel(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? 'Untitled Chat',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}
