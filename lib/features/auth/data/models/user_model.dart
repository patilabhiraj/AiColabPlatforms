import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Assuming backend returns a token at the root, and user info in a 'user' object.
    // Adjust this parsing based on the actual API response structure!
    final userJson = json['user'] ?? json;
    
    return UserModel(
      id: userJson['_id'] ?? userJson['id'] ?? '',
      email: userJson['email'] ?? '',
      firstName: userJson['firstName'] ?? '',
      lastName: userJson['lastName'] ?? '',
      token: json['token'] ?? '', // Extract token if it comes in the response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
    };
  }
}
