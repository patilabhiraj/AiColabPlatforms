import '../../domain/entities/chat_conversation.dart';

class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.title,
    required super.lastMessage,
    required super.updatedAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    // Handle both integer and string IDs
    final dynamic idValue = json['_id'] ?? json['id'];
    final String id = idValue != null ? idValue.toString() : '';
    
    return ChatConversationModel(
      id: id,
      title: json['title'] ?? 'New Chat',
      lastMessage: json['lastMessage'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
