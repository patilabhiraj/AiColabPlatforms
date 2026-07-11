part of 'archived_chats_bloc.dart';

abstract class ArchivedChatsState {}

class ArchivedChatsInitial extends ArchivedChatsState {}

class ArchivedChatsLoading extends ArchivedChatsState {}

class ArchivedChatsError extends ArchivedChatsState {
  final String message;
  ArchivedChatsError(this.message);
}

class ArchivedChatsLoaded extends ArchivedChatsState {
  final List<ArchivedChatEntity> chats;
  final String? unarchivingId;
  final String? error;

  ArchivedChatsLoaded({
    required this.chats,
    this.unarchivingId,
    this.error,
  });

  ArchivedChatsLoaded copyWith({
    List<ArchivedChatEntity>? chats,
    String? unarchivingId,
    String? error,
  }) {
    return ArchivedChatsLoaded(
      chats: chats ?? this.chats,
      unarchivingId: unarchivingId,
      error: error,
    );
  }
}
