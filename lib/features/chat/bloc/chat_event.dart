part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatLoadConversations extends ChatEvent {}

class ChatSelectConversation extends ChatEvent {
  final ChatConversation conversation;
  ChatSelectConversation(this.conversation);
}

class ChatSendMessage extends ChatEvent {
  final String content;
  ChatSendMessage(this.content);
}

class ChatSendMessageStreaming extends ChatEvent {
  final String content;
  ChatSendMessageStreaming(this.content);
}

class ChatStartNewConversation extends ChatEvent {}

class ChatDeleteConversation extends ChatEvent {
  final String conversationId;
  ChatDeleteConversation(this.conversationId);
}

class ChatToggleStarMessage extends ChatEvent {
  final ChatMessage message;
  ChatToggleStarMessage(this.message);
}

class ChatToggleLikeMessage extends ChatEvent {
  final ChatMessage message;
  final bool? isLiked; // null = remove feedback, true = like, false = dislike
  ChatToggleLikeMessage(this.message, this.isLiked);
}

class ChatRegenerateMessage extends ChatEvent {
  final String chatId;
  final String messageId;
  ChatRegenerateMessage(this.chatId, this.messageId);
}

class ChatSubmitFeedback extends ChatEvent {
  final String chatId;
  final String messageId;
  final bool isPositive;
  ChatSubmitFeedback(this.chatId, this.messageId, this.isPositive);
}
