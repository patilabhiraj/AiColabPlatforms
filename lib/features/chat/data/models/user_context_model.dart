import '../../domain/entities/user_context.dart';

class UserContextModel extends UserContext {
  const UserContextModel({
    required super.id,
    required super.name,
    required super.content,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserContextModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['_id'] ?? json['id'];
    return UserContextModel(
      id: idValue != null ? idValue.toString() : '',
      name: json['name'] as String? ?? '',
      content: json['content'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'content': content,
        'role': role,
      };
}
