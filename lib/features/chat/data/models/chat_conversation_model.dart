import '../../domain/entities/chat_conversation.dart';

class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.title,
    required super.lastMessage,
    required super.updatedAt,
    super.isArchived,
    super.isPinned,
    super.isShared,
    super.shareId,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['_id'] ?? json['id'];
    return ChatConversationModel(
      id: idValue != null ? idValue.toString() : '',
      title: json['title'] ?? 'New Chat',
      lastMessage: json['lastMessage'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isArchived: json['isArchived'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      isShared: json['isShared'] as bool? ?? false,
      shareId: json['shareId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'isArchived': isArchived,
        'isPinned': isPinned,
        'isShared': isShared,
        if (shareId != null) 'shareId': shareId,
      };
}
