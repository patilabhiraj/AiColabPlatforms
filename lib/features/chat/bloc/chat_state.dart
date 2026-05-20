part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatConversation> conversations;
  final ChatConversation? selectedConversation;
  final List<ChatMessage> messages;
  final bool isSending;

  ChatLoaded({
    required this.conversations,
    this.selectedConversation,
    this.messages = const [],
    this.isSending = false,
  });

  ChatLoaded copyWith({
    List<ChatConversation>? conversations,
    ChatConversation? selectedConversation,
    bool clearConversation = false,
    List<ChatMessage>? messages,
    bool? isSending,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      selectedConversation: clearConversation
          ? null
          : selectedConversation ?? this.selectedConversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
