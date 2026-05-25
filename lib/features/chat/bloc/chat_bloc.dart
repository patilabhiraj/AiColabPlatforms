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

    // If no conversation selected, create new one first
    String conversationId;
    ChatConversation? newConversation;
    
    if (current.selectedConversation == null) {
      // Create new conversation
      final createResult = await _repository.createConversation(event.content);
      
      final conversation = createResult.fold(
        (failure) => null,
        (conv) => conv,
      );
      
      if (conversation == null) {
        // Failed to create conversation
        emit(current.copyWith(isSending: false));
        return;
      }
      
      conversationId = conversation.id;
      newConversation = conversation;
      
      // Update state with new conversation - KEEP the user message!
      if (state is! ChatLoaded) return;
      final currentState = state as ChatLoaded;
      
      emit(currentState.copyWith(
        selectedConversation: newConversation,
        conversations: [newConversation, ...currentState.conversations],
        messages: currentState.messages, // ✅ Keep existing messages (user message)
        isSending: true,
      ));
    } else {
      conversationId = current.selectedConversation!.id;
    }

    // Send message
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

  Future<void> _onSendMessageStreaming(
    ChatSendMessageStreaming event,
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

    // If no conversation selected, create new one first
    String conversationId;
    ChatConversation? newConversation;
    
    if (current.selectedConversation == null) {
      // Create new conversation
      final createResult = await _repository.createConversation(event.content);
      
      final conversation = createResult.fold(
        (failure) => null,
        (conv) => conv,
      );
      
      if (conversation == null) {
        // Failed to create conversation
        emit(current.copyWith(isSending: false));
        return;
      }
      
      conversationId = conversation.id;
      newConversation = conversation;
      
      // Update state with new conversation - KEEP the user message!
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

    // Start streaming
    final streamingMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    
    await emit.forEach<Either<Failure, String>>(
      _repository.sendMessageStream(conversationId, event.content),
      onData: (either) {
        return either.fold(
          (failure) {
            // Error during streaming
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(
              isSending: false,
              clearStreaming: true,
            );
          },
          (content) {
            // New token received - update streaming content
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

    // Stream complete - add final message with suggested questions
    if (state is! ChatLoaded) return;
    final finalState = state as ChatLoaded;
    
    if (finalState.streamingContent != null) {
      // Extract suggested questions from the content
      final suggestedQuestions = _extractSuggestedQuestions(finalState.streamingContent!);
      
      final finalMessage = ChatMessage(
        id: streamingMessageId,
        content: finalState.streamingContent!,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedQuestions: suggestedQuestions.isNotEmpty ? suggestedQuestions : null,
      );
      
      emit(finalState.copyWith(
        messages: [...finalState.messages, finalMessage],
        isSending: false,
        clearStreaming: true,
      ));
    }
  }
  
  /// Extract suggested questions from response content
  List<String> _extractSuggestedQuestions(String content) {
    final questions = <String>[];
    
    // Try to find JSON array pattern
    final jsonArrayPattern = RegExp(r'\[\s*"([^"]+)"(?:\s*,\s*"([^"]+)")*\s*\]', multiLine: true);
    final matches = jsonArrayPattern.allMatches(content);
    
    for (final match in matches) {
      try {
        final jsonStr = match.group(0);
        if (jsonStr != null) {
          final decoded = jsonDecode(jsonStr);
          if (decoded is List) {
            questions.addAll(decoded.map((e) => e.toString()));
          }
        }
      } catch (e) {
        // Ignore parse errors
      }
    }
    
    return questions;
  }
}
