part of 'archived_chats_bloc.dart';

abstract class ArchivedChatsEvent {}

class ArchivedChatsLoadRequested extends ArchivedChatsEvent {}

class ArchivedChatUnarchiveRequested extends ArchivedChatsEvent {
  final String chatId;
  ArchivedChatUnarchiveRequested(this.chatId);
}
