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
    // Backend wraps response in a 'data' block
    final dataJson = json['data'] as Map<String, dynamic>?;
    final userJson = dataJson?['user'] ?? json['user'] ?? json;
    
    final extractedToken = json['token'] ?? 
                           json['accessToken'] ?? 
                           json['access_token'] ?? 
                           dataJson?['token'] ?? 
                           dataJson?['accessToken'] ?? 
                           dataJson?['access_token'] ?? 
                           userJson['token'] ?? 
                           userJson['accessToken'] ?? 
                           userJson['access_token'] ?? 
                           '';
    
    return UserModel(
      id: (userJson['_id'] ?? userJson['id'] ?? '').toString(),
      email: userJson['email'] ?? '',
      firstName: userJson['firstName'] ?? '',
      lastName: userJson['lastName'] ?? '',
      token: extractedToken,
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
