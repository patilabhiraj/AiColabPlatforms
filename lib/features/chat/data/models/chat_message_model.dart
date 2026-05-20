import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
