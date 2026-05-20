import '../../domain/entities/chat_conversation.dart';

class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.title,
    required super.lastMessage,
    required super.updatedAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'New Chat',
      lastMessage: json['lastMessage'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
