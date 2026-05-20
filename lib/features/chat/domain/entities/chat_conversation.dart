import 'package:equatable/equatable.dart';

class ChatConversation extends Equatable {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, lastMessage, updatedAt];
}
