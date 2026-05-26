import 'package:equatable/equatable.dart';

class UserContext extends Equatable {
  final String id;
  final String name;
  final String content;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserContext({
    required this.id,
    required this.name,
    required this.content,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, content, role, createdAt, updatedAt];
}
