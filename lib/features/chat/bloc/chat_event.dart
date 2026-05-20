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

class ChatStartNewConversation extends ChatEvent {}
