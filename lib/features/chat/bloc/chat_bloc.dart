import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/chat_conversation.dart';
import '../domain/entities/chat_message.dart';
import '../domain/usecases/get_conversations_usecase.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase _getConversations;
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;

  ChatBloc(this._getConversations, this._getMessages, this._sendMessage)
      : super(ChatInitial()) {
    on<ChatLoadConversations>(_onLoadConversations);
    on<ChatSelectConversation>(_onSelectConversation);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatStartNewConversation>(_onStartNew);
  }

  Future<void> _onLoadConversations(
    ChatLoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await _getConversations();
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversations) => emit(ChatLoaded(conversations: conversations)),
    );
  }

  Future<void> _onSelectConversation(
    ChatSelectConversation event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    emit(current.copyWith(
      selectedConversation: event.conversation,
      messages: [],
      isSending: false,
    ));

    final result = await _getMessages(event.conversation.id);
    result.fold(
      (_) {},
      (messages) => emit((state as ChatLoaded).copyWith(messages: messages)),
    );
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    // Optimistically add user message
    final userMsg = ChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      content: event.content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(current.copyWith(
      messages: [...current.messages, userMsg],
      isSending: true,
    ));

    final conversationId = current.selectedConversation?.id ?? 'new';
    final result = await _sendMessage(conversationId, event.content);

    if (state is! ChatLoaded) return;
    final updated = state as ChatLoaded;

    result.fold(
      (_) => emit(updated.copyWith(isSending: false)),
      (aiMsg) => emit(updated.copyWith(
        messages: [...updated.messages, aiMsg],
        isSending: false,
      )),
    );
  }

  void _onStartNew(ChatStartNewConversation event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    emit((state as ChatLoaded).copyWith(
      selectedConversation: null,
      messages: [],
      isSending: false,
    ));
  }
}
