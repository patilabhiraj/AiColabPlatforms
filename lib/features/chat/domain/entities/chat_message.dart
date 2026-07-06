import 'package:equatable/equatable.dart';

import 'model_response.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestedQuestions;
  final bool isStarred;
  final String? modelName;
  final bool? isLiked; // null = no feedback, true = liked, false = disliked

  /// Per-model responses for multi-model messages. Empty for normal
  /// single-model messages, in which case [content] holds the answer.
  final List<ModelResponse> modelResponses;

  /// Which model's tab is currently shown (multi-model only).
  final int? activeModelId;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestedQuestions,
    this.isStarred = false,
    this.modelName,
    this.isLiked,
    this.modelResponses = const [],
    this.activeModelId,
  });

  /// True when this assistant message carries more than one model's answer.
  bool get isMultiModel => modelResponses.length > 1;

  @override
  List<Object?> get props => [
        id,
        content,
        isUser,
        timestamp,
        suggestedQuestions,
        isStarred,
        modelName,
        isLiked,
        modelResponses,
        activeModelId,
      ];

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<String>? suggestedQuestions,
    bool? isStarred,
    String? modelName,
    bool? isLiked,
    List<ModelResponse>? modelResponses,
    int? activeModelId,
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
      modelResponses: modelResponses ?? this.modelResponses,
      activeModelId: activeModelId ?? this.activeModelId,
    );
  }
}
