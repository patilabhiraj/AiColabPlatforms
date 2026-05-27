import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestedQuestions;
  final bool isStarred;
  final String? modelName;
  final bool? isLiked; // null = no feedback, true = liked, false = disliked

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestedQuestions,
    this.isStarred = false,
    this.modelName,
    this.isLiked,
  });

  @override
  List<Object?> get props => [id, content, isUser, timestamp, suggestedQuestions, isStarred, modelName, isLiked];

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<String>? suggestedQuestions,
    bool? isStarred,
    String? modelName,
    bool? isLiked,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
      isStarred: isStarred ?? this.isStarred,
      modelName: modelName ?? this.modelName,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

