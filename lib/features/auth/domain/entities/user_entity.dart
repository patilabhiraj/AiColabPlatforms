import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String token;
  final String? profileImageUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.token,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [id, email, firstName, lastName, token, profileImageUrl];
}
