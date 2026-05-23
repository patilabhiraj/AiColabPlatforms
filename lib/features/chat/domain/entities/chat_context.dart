import 'package:equatable/equatable.dart';

/// Chat context entity - represents conversation context/history
class ChatContext extends Equatable {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime? timestamp;

  const ChatContext({
    required this.role,
    required this.content,
    this.timestamp,
  });

  @override
  List<Object?> get props => [role, content, timestamp];
}
