import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.token,
    super.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend wraps response in a 'data' block
    final dataJson = json['data'] as Map<String, dynamic>?;
    final userJson = dataJson?['user'] ?? dataJson ?? json['user'] ?? json;
    
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
    
    // Extract profile image URL (common field names from Google OAuth and other providers)
    final profileImageUrl = userJson['profileImageUrl'] ?? 
                           userJson['profileImage'] ?? 
                           userJson['photoUrl'] ?? 
                           userJson['photo'] ?? 
                           userJson['picture'] ?? 
                           userJson['avatar'] ?? 
                           userJson['image'];
    
    return UserModel(
      id: (userJson['_id'] ?? userJson['id'] ?? '').toString(),
      email: userJson['email'] ?? '',
      firstName: userJson['firstName'] ?? '',
      lastName: userJson['lastName'] ?? '',
      token: extractedToken,
      profileImageUrl: profileImageUrl?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }
}
