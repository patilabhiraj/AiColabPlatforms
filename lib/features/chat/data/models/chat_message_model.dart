import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
    super.modelName,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['_id'] ?? json['id'];
    final String id = idValue != null ? idValue.toString() : '';
    return ChatMessageModel(
      id: id,
      content: json['content'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      modelName: json['model'] as String? ?? json['modelName'] as String?,
    );
  }
}
