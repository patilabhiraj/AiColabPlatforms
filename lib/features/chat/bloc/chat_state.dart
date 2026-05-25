part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatConversation> conversations;
  final ChatConversation? selectedConversation;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? streamingContent;
  final String? streamingMessageId;

  ChatLoaded({
    required this.conversations,
    this.selectedConversation,
    this.messages = const [],
    this.isSending = false,
    this.streamingContent,
    this.streamingMessageId,
  });

  bool get isStreaming => streamingContent != null;

  ChatLoaded copyWith({
    List<ChatConversation>? conversations,
    ChatConversation? selectedConversation,
    bool clearConversation = false,
    List<ChatMessage>? messages,
    bool? isSending,
    String? streamingContent,
    bool clearStreaming = false,
    String? streamingMessageId,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      selectedConversation: clearConversation
          ? null
          : selectedConversation ?? this.selectedConversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      streamingContent: clearStreaming ? null : (streamingContent ?? this.streamingContent),
      streamingMessageId: clearStreaming ? null : (streamingMessageId ?? this.streamingMessageId),
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
