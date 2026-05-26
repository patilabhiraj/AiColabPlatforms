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
