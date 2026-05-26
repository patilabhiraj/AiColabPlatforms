import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/chat_conversation.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/get_conversations_usecase.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase _getConversations;
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final ChatRepository _repository;

  ChatBloc(
    this._getConversations,
    this._getMessages,
    this._sendMessage,
    this._repository,
  ) : super(ChatInitial()) {
    on<ChatLoadConversations>(_onLoadConversations);
    on<ChatSelectConversation>(_onSelectConversation);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatSendMessageStreaming>(_onSendMessageStreaming);
    on<ChatStartNewConversation>(_onStartNew);
    on<ChatDeleteConversation>(_onDeleteConversation);
    on<ChatToggleStarMessage>(_onToggleStar);
    on<ChatRegenerateMessage>(_onRegenerateMessage);
    on<ChatSubmitFeedback>(_onSubmitFeedback);
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

    String conversationId;
    ChatConversation? newConversation;

    if (current.selectedConversation == null) {
      final createResult = await _repository.createConversation(event.content);
      final conversation = createResult.fold((failure) => null, (conv) => conv);
      if (conversation == null) {
        emit(current.copyWith(isSending: false));
        return;
      }
      conversationId = conversation.id;
      newConversation = conversation;

      if (state is! ChatLoaded) return;
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(
        selectedConversation: newConversation,
        conversations: [newConversation, ...currentState.conversations],
        messages: currentState.messages,
        isSending: true,
      ));
    } else {
      conversationId = current.selectedConversation!.id;
    }

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
      clearStreaming: true,
    ));
  }

  Future<void> _onDeleteConversation(
    ChatDeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    await _repository.deleteChat(event.conversationId);

    final updatedConversations = current.conversations
        .where((conv) => conv.id != event.conversationId)
        .toList();
    final updatedSelection = current.selectedConversation?.id == event.conversationId
        ? null
        : current.selectedConversation;

    emit(current.copyWith(
      conversations: updatedConversations,
      selectedConversation: updatedSelection,
      messages: updatedSelection == null ? [] : current.messages,
      clearStreaming: true,
    ));
  }

  void _onToggleStar(ChatToggleStarMessage event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    final wasStarred = event.message.isStarred;
    final toggled = event.message.copyWith(isStarred: !wasStarred);

    final updatedMessages = current.messages
        .map((m) => m.id == event.message.id ? toggled : m)
        .toList();

    final updatedStarred = wasStarred
        ? current.starredMessages.where((m) => m.id != event.message.id).toList()
        : [...current.starredMessages, toggled];

    emit(current.copyWith(
      messages: updatedMessages,
      starredMessages: updatedStarred,
    ));
  }

  Future<void> _onRegenerateMessage(
    ChatRegenerateMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    // Remove the message being regenerated
    final updatedMessages = current.messages
        .where((m) => m.id != event.messageId)
        .toList();

    emit(current.copyWith(
      messages: updatedMessages,
      isSending: true,
    ));

    final streamingMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';

    await emit.forEach<Either<Failure, String>>(
      _repository.regenerateMessage(event.chatId, event.messageId),
      onData: (either) {
        return either.fold(
          (failure) {
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(isSending: false, clearStreaming: true);
          },
          (content) {
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(
              streamingContent: content,
              streamingMessageId: streamingMessageId,
              isSending: true,
            );
          },
        );
      },
    );

    if (state is! ChatLoaded) return;
    final finalState = state as ChatLoaded;

    if (finalState.streamingContent != null) {
      final rawContent = finalState.streamingContent!;
      final suggestedQuestions = _extractSuggestedQuestions(rawContent);
      final cleanedContent = _cleanStreamedContent(rawContent);

      emit(finalState.copyWith(
        messages: [
          ...finalState.messages,
          ChatMessage(
            id: streamingMessageId,
            content: cleanedContent,
            isUser: false,
            timestamp: DateTime.now(),
            suggestedQuestions: suggestedQuestions.isNotEmpty ? suggestedQuestions : null,
          ),
        ],
        isSending: false,
        clearStreaming: true,
      ));
    }
  }

  Future<void> _onSubmitFeedback(
    ChatSubmitFeedback event,
    Emitter<ChatState> emit,
  ) async {
    // Fire-and-forget — no UI state change needed
    await _repository.submitFeedback(event.chatId, event.messageId, event.isPositive);
  }

  Future<void> _onSendMessageStreaming(
    ChatSendMessageStreaming event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

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

    String conversationId;
    ChatConversation? newConversation;

    if (current.selectedConversation == null) {
      final createResult = await _repository.createConversation(event.content);
      final conversation = createResult.fold((failure) => null, (conv) => conv);
      if (conversation == null) {
        emit(current.copyWith(isSending: false));
        return;
      }
      conversationId = conversation.id;
      newConversation = conversation;

      if (state is! ChatLoaded) return;
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(
        selectedConversation: newConversation,
        conversations: [newConversation, ...currentState.conversations],
        messages: currentState.messages,
        isSending: true,
      ));
    } else {
      conversationId = current.selectedConversation!.id;
    }

    final streamingMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';

    await emit.forEach<Either<Failure, String>>(
      _repository.sendMessageStream(conversationId, event.content),
      onData: (either) {
        return either.fold(
          (failure) {
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(isSending: false, clearStreaming: true);
          },
          (content) {
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(
              streamingContent: content,
              streamingMessageId: streamingMessageId,
              isSending: true,
            );
          },
        );
      },
    );

    if (state is! ChatLoaded) return;
    final finalState = state as ChatLoaded;

    if (finalState.streamingContent != null) {
      final rawContent = finalState.streamingContent!;
      final suggestedQuestions = _extractSuggestedQuestions(rawContent);
      final cleanedContent = _cleanStreamedContent(rawContent);

      emit(finalState.copyWith(
        messages: [
          ...finalState.messages,
          ChatMessage(
            id: streamingMessageId,
            content: cleanedContent,
            isUser: false,
            timestamp: DateTime.now(),
            suggestedQuestions: suggestedQuestions.isNotEmpty ? suggestedQuestions : null,
          ),
        ],
        isSending: false,
        clearStreaming: true,
      ));
    }
  }

  String _cleanStreamedContent(String content) {
    return content
        .replaceAll(RegExp(r'```json[\s\S]*?```', multiLine: true), '')
        .replaceAll(RegExp(r'```[\s\S]*?```', multiLine: true), '')
        .replaceAll(RegExp(r'\[\s*"[^"]*"(?:\s*,\s*"[^"]*")*\s*\]', multiLine: true), '')
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .replaceAll('***json', '')
        .replaceAll('***', '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  List<String> _extractSuggestedQuestions(String content) {
    final questions = <String>[];
    final jsonArrayPattern = RegExp(r'\[\s*"([^"]+)"(?:\s*,\s*"([^"]+)")*\s*\]', multiLine: true);

    for (final match in jsonArrayPattern.allMatches(content)) {
      try {
        final jsonStr = match.group(0);
        if (jsonStr != null) {
          final decoded = jsonDecode(jsonStr);
          if (decoded is List) {
            questions.addAll(decoded.map((e) => e.toString()));
          }
        }
      } catch (_) {}
    }

    return questions;
  }
}
