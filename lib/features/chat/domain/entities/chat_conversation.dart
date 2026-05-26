import 'package:equatable/equatable.dart';

class ChatConversation extends Equatable {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isPinned;
  final bool isShared;
  final String? shareId;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    this.isArchived = false,
    this.isPinned = false,
    this.isShared = false,
    this.shareId,
  });

  ChatConversation copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isPinned,
    bool? isShared,
    String? shareId,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      isShared: isShared ?? this.isShared,
      shareId: shareId ?? this.shareId,
    );
  }

  @override
  List<Object?> get props => [id, title, lastMessage, updatedAt, isArchived, isPinned, isShared, shareId];
}
