import '../../domain/entities/chat_context.dart';

/// Chat context model - data layer representation with JSON serialization
class ChatContextModel extends ChatContext {
  const ChatContextModel({
    required super.role,
    required super.content,
    super.timestamp,
  });

  /// Create model from JSON response
  factory ChatContextModel.fromJson(Map<String, dynamic> json) {
    return ChatContextModel(
      role: json['role'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}
