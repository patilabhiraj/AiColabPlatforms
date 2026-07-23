import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/ai_model.dart';
import '../domain/entities/assistant.dart';
import '../domain/entities/chat_conversation.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/model_response.dart';
import '../domain/entities/multi_model.dart';
import '../domain/entities/user_context.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/create_conversation_usecase.dart';
import '../domain/usecases/get_assistants_usecase.dart';
import '../domain/usecases/get_conversations_usecase.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/get_models_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase _getConversations;
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final GetModelsUseCase _getModels;
  final GetAssistantsUseCase _getAssistants;
  final CreateConversationUseCase _createConversation;
  final ChatRepository _repository;

  ChatBloc(
    this._getConversations,
    this._getMessages,
    this._sendMessage,
    this._getModels,
    this._getAssistants,
    this._createConversation,
    this._repository,
  ) : super(ChatInitial()) {
    on<ChatLoadConversations>(_onLoadConversations);
    on<ChatClearSendError>(_onClearSendError);
    on<ChatLoadMoreConversations>(_onLoadMoreConversations);
    on<ChatSelectConversation>(_onSelectConversation);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatSendMessageStreaming>(_onSendMessageStreaming);
    on<ChatStartNewConversation>(_onStartNew);
    on<ChatDeleteConversation>(_onDeleteConversation);
    on<ChatToggleStarMessage>(_onToggleStar);
    on<ChatToggleLikeMessage>(_onToggleLike);
    on<ChatRegenerateMessage>(_onRegenerateMessage);
    on<ChatSubmitFeedback>(_onSubmitFeedback);
    on<ChatLoadCatalog>(_onLoadCatalog);
    on<ChatToggleModel>(_onToggleModel);
    on<ChatSetCapability>(_onSetCapability);
    on<ChatSetMultiMode>(_onSetMultiMode);
    on<ChatSelectAssistant>(_onSelectAssistant);
    on<ChatSelectModelTab>(_onSelectModelTab);
    on<ChatModelChunk>(_onModelChunk);
    on<ChatModelDone>(_onModelDone);
    // ── Context handlers ────────────────────────────────────────────────
    on<ChatLoadContexts>(_onLoadContexts);
    on<ChatToggleContext>(_onToggleContext);
    on<ChatDeleteContext>(_onDeleteContext);
  }

  void _onClearSendError(ChatClearSendError event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    emit((state as ChatLoaded).copyWith(clearSendError: true));
  }

  Future<void> _onLoadConversations(
    ChatLoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    // Load only the first page (5 chats); the rest come via "Load More Chats".
    final result = await _getConversations.page(
      page: 1,
      pageSize: _conversationsPageSize,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (paged) => emit(
        ChatLoaded(
          conversations: paged.conversations,
          conversationsPage: paged.page,
          hasMoreConversations: paged.hasNextPage,
        ),
      ),
    );
    // Load models + assistants + contexts in the background once the chat shell is ready.
    if (state is ChatLoaded) {
      add(ChatLoadCatalog());
      add(ChatLoadContexts());
    }
  }

  static const int _conversationsPageSize = 5;

  Future<void> _onLoadMoreConversations(
    ChatLoadMoreConversations event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    // Guard against double-taps and requesting past the last page.
    if (current.isLoadingMoreConversations || !current.hasMoreConversations) {
      return;
    }

    emit(current.copyWith(isLoadingMoreConversations: true));

    final nextPage = current.conversationsPage + 1;
    final result = await _getConversations.page(
      page: nextPage,
      pageSize: _conversationsPageSize,
    );
    if (state is! ChatLoaded) return;
    final latest = state as ChatLoaded;

    result.fold(
      (_) => emit(latest.copyWith(isLoadingMoreConversations: false)),
      (paged) {
        // Append, de-duplicating by id so an overlapping page can't create
        // duplicate rows.
        final existingIds = latest.conversations.map((c) => c.id).toSet();
        final merged = [
          ...latest.conversations,
          ...paged.conversations.where((c) => !existingIds.contains(c.id)),
        ];
        emit(
          latest.copyWith(
            conversations: merged,
            conversationsPage: paged.page,
            hasMoreConversations: paged.hasNextPage,
            isLoadingMoreConversations: false,
          ),
        );
      },
    );
  }

  // ── Catalog: models & assistants ──────────────────────────────────────────

  Future<void> _onLoadCatalog(
    ChatLoadCatalog event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final modelsResult = await _getModels();
    if (state is! ChatLoaded) return;
    modelsResult.fold((_) {}, (models) {
      final current = state as ChatLoaded;
      // Pick sensible defaults only if nothing is selected yet.
      final selected = current.selectedModelIds.isNotEmpty
          ? current.selectedModelIds
          : _defaultSelection(models);
      emit(
        current.copyWith(availableModels: models, selectedModelIds: selected),
      );
    });

    final assistantsResult = await _getAssistants();
    if (state is! ChatLoaded) return;
    assistantsResult.fold((_) {}, (assistants) {
      emit((state as ChatLoaded).copyWith(assistants: assistants));
    });
  }

  /// Default model selection: models flagged default for STANDARD, else the
  /// first available model. Mirrors the web new-chat behaviour.
  List<int> _defaultSelection(List<AiModel> models) {
    if (models.isEmpty) return const [];
    final defaults = models
        .where((m) => m.defaultForCapabilities.contains('STANDARD'))
        .map((m) => m.id)
        .toList();
    if (defaults.isNotEmpty) return [defaults.first];
    return [models.first.id];
  }

  void _onToggleModel(ChatToggleModel event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final selected = List<int>.from(current.selectedModelIds);

    // There is no separate Single/Multi switch anymore — the mode is derived
    // from how many models are selected. Tapping a model toggles it in/out of
    // the selection (never dropping below one), and multiMode follows the count.
    if (selected.contains(event.modelId)) {
      // Removing — keep at least one model selected.
      if (selected.length > 1) selected.remove(event.modelId);
    } else {
      selected.add(event.modelId);
    }

    emit(
      current.copyWith(
        selectedModelIds: selected,
        multiMode: selected.length > 1,
      ),
    );
  }

  void _onSetCapability(ChatSetCapability event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final capability = event.capability;

    final validModels = current.availableModels
        .where((m) => m.supportsCapability(capability))
        .toList();
    final compatibleSelected = current.selectedModelIds
        .where((id) => validModels.any((m) => m.id == id))
        .toList();

    // Specialised modes (web search / image) work best with a single model.
    final forceSingle = capability != 'STANDARD';

    List<int> newSelection = compatibleSelected;
    if (compatibleSelected.isEmpty ||
        (forceSingle && compatibleSelected.length > 1)) {
      final defaultForType = validModels
          .where((m) => m.defaultForCapabilities.contains(capability))
          .toList();
      if (defaultForType.isNotEmpty) {
        newSelection = [defaultForType.first.id];
      } else if (validModels.isNotEmpty) {
        newSelection = [validModels.first.id];
      } else {
        newSelection = const [];
      }
    }

    emit(
      current.copyWith(capability: capability, selectedModelIds: newSelection),
    );
  }

  void _onSetMultiMode(ChatSetMultiMode event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    var selected = current.selectedModelIds;
    if (!event.multiMode && selected.length > 1) {
      selected = [selected.first];
    }
    emit(
      current.copyWith(multiMode: event.multiMode, selectedModelIds: selected),
    );
  }

  void _onSelectAssistant(ChatSelectAssistant event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final assistant = event.assistant;

    // Selecting an assistant starts a fresh conversation.
    var selectedModelIds = current.selectedModelIds;
    if (assistant?.defaultModelId != null &&
        current.availableModels.any((m) => m.id == assistant!.defaultModelId)) {
      selectedModelIds = [assistant!.defaultModelId!];
    }

    emit(
      current.copyWith(
        selectedAssistant: assistant,
        clearAssistant: assistant == null,
        selectedModelIds: selectedModelIds,
        clearConversation: true,
        messages: const [],
        isSending: false,
        clearStreaming: true,
      ),
    );
  }

  Future<void> _onSelectConversation(
    ChatSelectConversation event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    // Open the selected conversation immediately (mirrors ChatGPT): show it as
    // selected, clear any previous/streaming messages and start loading.
    emit(
      current.copyWith(
        selectedConversation: event.conversation,
        clearAssistant: true,
        messages: [],
        isSending: false,
        clearStreaming: true,
      ),
    );

    final result = await _getMessages(event.conversation.id);
    if (state is! ChatLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ChatLoaded).copyWith(
          messages: [
            ChatMessage(
              id: 'load_error',
              content: 'Could not load this chat. ${failure.message}',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        ),
      ),
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

    emit(
      current.copyWith(
        messages: [...current.messages, userMsg],
        isSending: true,
        clearSendError: true,
      ),
    );

    String conversationId;
    ChatConversation? newConversation;

    if (current.selectedConversation == null) {
      final createResult = await _createConversation(
        event.content,
        modelIds: current.selectedModelIds,
        capability: current.capability,
        assistantId: current.selectedAssistant?.id,
      );
      final conversation = createResult.fold((failure) => null, (conv) => conv);
      if (conversation == null) {
        emit(current.copyWith(isSending: false));
        return;
      }
      conversationId = conversation.id;
      newConversation = conversation;

      if (state is! ChatLoaded) return;
      final currentState = state as ChatLoaded;
      emit(
        currentState.copyWith(
          selectedConversation: newConversation,
          conversations: [newConversation, ...currentState.conversations],
          messages: currentState.messages,
          isSending: true,
        ),
      );
    } else {
      conversationId = current.selectedConversation!.id;
    }

    final result = await _sendMessage(conversationId, event.content);
    if (state is! ChatLoaded) return;
    final updated = state as ChatLoaded;

    result.fold(
      (_) => emit(updated.copyWith(isSending: false)),
      (aiMsg) => emit(
        updated.copyWith(
          messages: [...updated.messages, aiMsg],
          isSending: false,
        ),
      ),
    );
  }

  void _onStartNew(ChatStartNewConversation event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    emit(
      (state as ChatLoaded).copyWith(
        clearConversation: true,
        clearAssistant: true,
        messages: [],
        isSending: false,
        clearStreaming: true,
      ),
    );
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
    final updatedSelection =
        current.selectedConversation?.id == event.conversationId
        ? null
        : current.selectedConversation;

    emit(
      current.copyWith(
        conversations: updatedConversations,
        selectedConversation: updatedSelection,
        messages: updatedSelection == null ? [] : current.messages,
        clearStreaming: true,
      ),
    );
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
        ? current.starredMessages
              .where((m) => m.id != event.message.id)
              .toList()
        : [...current.starredMessages, toggled];

    emit(
      current.copyWith(
        messages: updatedMessages,
        starredMessages: updatedStarred,
      ),
    );
  }

  void _onToggleLike(ChatToggleLikeMessage event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    final toggled = event.message.copyWith(isLiked: event.isLiked);

    final updatedMessages = current.messages
        .map((m) => m.id == event.message.id ? toggled : m)
        .toList();

    emit(current.copyWith(messages: updatedMessages));
  }

  Future<void> _onRegenerateMessage(
    ChatRegenerateMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    // Find the AI message being regenerated
    final aiMessageIndex = current.messages.indexWhere(
      (m) => m.id == event.messageId,
    );
    if (aiMessageIndex == -1) return;

    // Find the user message before this AI message
    String? userMessageContent;
    for (int i = aiMessageIndex - 1; i >= 0; i--) {
      if (current.messages[i].isUser) {
        userMessageContent = current.messages[i].content;
        break;
      }
    }

    if (userMessageContent == null) return;

    // Remove the AI message being regenerated
    final updatedMessages = current.messages
        .where((m) => m.id != event.messageId)
        .toList();

    emit(current.copyWith(messages: updatedMessages, isSending: true));

    // Resend the user's message to get new response
    final streamingMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';

    await emit.forEach<Either<Failure, String>>(
      _repository.sendMessageStream(event.chatId, userMessageContent),
      onData: (either) {
        return either.fold(
          (failure) {
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(
              isSending: false,
              clearStreaming: true,
            );
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

      emit(
        finalState.copyWith(
          messages: [
            ...finalState.messages,
            ChatMessage(
              id: streamingMessageId,
              content: cleanedContent,
              isUser: false,
              timestamp: DateTime.now(),
              suggestedQuestions: suggestedQuestions.isNotEmpty
                  ? suggestedQuestions
                  : null,
            ),
          ],
          isSending: false,
          clearStreaming: true,
        ),
      );
    }
  }

  Future<void> _onSubmitFeedback(
    ChatSubmitFeedback event,
    Emitter<ChatState> emit,
  ) async {
    // Fire-and-forget — no UI state change needed
    await _repository.submitFeedback(
      event.chatId,
      event.messageId,
      event.isPositive,
    );
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

    emit(
      current.copyWith(
        messages: [...current.messages, userMsg],
        isSending: true,
        clearSendError: true,
      ),
    );

    String conversationId;
    ChatConversation? newConversation;

    if (current.selectedConversation == null) {
      final createResult = await _createConversation(
        event.content,
        modelIds: current.selectedModelIds,
        capability: current.capability,
        assistantId: current.selectedAssistant?.id,
      );
      final conversation = createResult.fold((failure) => null, (conv) => conv);
      if (conversation == null) {
        emit(current.copyWith(isSending: false));
        return;
      }
      conversationId = conversation.id;
      newConversation = conversation;

      if (state is! ChatLoaded) return;
      final currentState = state as ChatLoaded;
      emit(
        currentState.copyWith(
          selectedConversation: newConversation,
          conversations: [newConversation, ...currentState.conversations],
          messages: currentState.messages,
          isSending: true,
        ),
      );
    } else {
      conversationId = current.selectedConversation!.id;
    }

    if (state is! ChatLoaded) return;
    final loaded = state as ChatLoaded;

    // Never send with an empty selection — the backend rejects modelId 0 with
    // a 400. Fall back to the default selection when nothing is selected.
    var selectedIds = loaded.selectedModelIds;
    if (selectedIds.isEmpty) {
      selectedIds = _defaultSelection(loaded.availableModels);
      if (selectedIds.isEmpty) {
        emit(loaded.copyWith(isSending: false, clearStreaming: true));
        return;
      }
      emit(loaded.copyWith(selectedModelIds: selectedIds));
    }

    if (selectedIds.length > 1) {
      await _streamMultiModel(conversationId, event.content, selectedIds, emit);
    } else {
      await _streamSingleModel(
        conversationId,
        event.content,
        selectedIds.first,
        emit,
      );
    }
  }

  // ── Single-model streaming ────────────────────────────────────────────────
  Future<void> _streamSingleModel(
    String conversationId,
    String content,
    int modelId,
    Emitter<ChatState> emit,
  ) async {
    final streamingMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';

    await emit.forEach<Either<Failure, ModelStreamChunk>>(
      _repository.sendMessageStreamForModel(conversationId, content, modelId),
      onData: (either) {
        return either.fold(
          (failure) {
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(
              isSending: false,
              clearStreaming: true,
              sendError: failure.message,
            );
          },
          (chunk) {
            if (state is! ChatLoaded) return state;
            return (state as ChatLoaded).copyWith(
              streamingContent: chunk.content,
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
      print('📨 DEBUG: Final streaming content received (length: ${rawContent.length})');
      
      final suggestedQuestions = _extractSuggestedQuestions(rawContent);
      final cleanedContent = _cleanStreamedContent(rawContent);
      final modelName = _modelName(modelId);

      print('✨ DEBUG: Creating message with ${suggestedQuestions.length} suggested questions');
      if (suggestedQuestions.isNotEmpty) {
        print('📝 DEBUG: Suggested questions: $suggestedQuestions');
      }

      emit(
        finalState.copyWith(
          messages: [
            ...finalState.messages,
            ChatMessage(
              id: streamingMessageId,
              content: cleanedContent,
              isUser: false,
              timestamp: DateTime.now(),
              modelName: modelName,
              suggestedQuestions: suggestedQuestions.isNotEmpty
                  ? suggestedQuestions
                  : null,
            ),
          ],
          isSending: false,
          clearStreaming: true,
        ),
      );
    } else {
      emit(finalState.copyWith(isSending: false, clearStreaming: true));
    }
  }

  // ── Multi-model streaming ─────────────────────────────────────────────────
  Future<void> _streamMultiModel(
    String conversationId,
    String content,
    List<int> modelIds,
    Emitter<ChatState> emit,
  ) async {
    // 1. Reserve the shared user + assistant message ids on the backend.
    final prepResult = await _repository.prepareMulti(conversationId, content);
    final prep = prepResult.fold((_) => null, (r) => r);
    if (prep == null) {
      if (state is ChatLoaded) {
        emit(
          (state as ChatLoaded).copyWith(
            isSending: false,
            clearStreaming: true,
          ),
        );
      }
      return;
    }

    if (state is! ChatLoaded) return;
    final base = state as ChatLoaded;

    // 2. Seed a single assistant message holding one slot per model.
    final messageId = 'multi_${prep.assistantMessageId}';
    final responses = modelIds
        .map(
          (id) => ModelResponse(
            modelId: id,
            modelName: _modelName(id) ?? 'AI',
            externalId: _externalId(id),
          ),
        )
        .toList();

    emit(
      base.copyWith(
        messages: [
          ...base.messages,
          ChatMessage(
            id: messageId,
            content: '',
            isUser: false,
            timestamp: DateTime.now(),
            modelResponses: responses,
            activeModelId: modelIds.first,
          ),
        ],
        isSending: true,
      ),
    );

    // 3. Fan out one stream per model WITHOUT awaiting here: chunks are routed
    //    back through internal events, which can only be processed once this
    //    handler returns. Completion is tracked in [_onModelDone].
    for (final modelId in modelIds) {
      _runModelStream(conversationId, content, modelId, messageId, prep);
    }
  }

  /// Drives one model's stream, forwarding chunks/completion as internal events.
  Future<void> _runModelStream(
    String conversationId,
    String content,
    int modelId,
    String messageId,
    PrepareMultiResult prep,
  ) async {
    try {
      await for (final either in _repository.sendMessageStreamForModel(
        conversationId,
        content,
        modelId,
        userMessageId: prep.userMessageId,
        assistantMessageId: prep.assistantMessageId,
      )) {
        either.fold(
          (failure) => add(
            ChatModelDone(
              messageId,
              modelId,
              failed: true,
              errorContent: failure.message,
            ),
          ),
          (chunk) => add(ChatModelChunk(messageId, modelId, chunk.content)),
        );
      }
      add(ChatModelDone(messageId, modelId));
    } catch (e) {
      add(ChatModelDone(messageId, modelId, failed: true, errorContent: '$e'));
    }
  }

  void _onModelChunk(ChatModelChunk event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    // Parse follow-up questions out of the raw chunk (the model appends them as
    // a trailing JSON array) and clean them from the displayed content. Doing
    // this per chunk means the final chunk leaves the right questions in place.
    final questions = _extractSuggestedQuestions(event.content);
    emit(
      _updateModelResponse(
        state as ChatLoaded,
        event.messageId,
        event.modelId,
        (mr) => mr.copyWith(
          content: _cleanStreamedContent(event.content),
          status: ModelResponseStatus.streaming,
          suggestedQuestions: questions.isNotEmpty
              ? questions
              : mr.suggestedQuestions,
        ),
      ),
    );
  }

  void _onModelDone(ChatModelDone event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final updated = _updateModelResponse(
      state as ChatLoaded,
      event.messageId,
      event.modelId,
      (mr) => mr.copyWith(
        content: event.failed && mr.content.isEmpty
            ? (event.errorContent ?? 'Failed to generate a response.')
            : mr.content,
        status: event.failed
            ? ModelResponseStatus.failed
            : ModelResponseStatus.completed,
      ),
    );

    // Once every model in this message has finished, re-enable the composer.
    final msg = updated.messages.firstWhere(
      (m) => m.id == event.messageId,
      orElse: () => updated.messages.last,
    );
    final allDone = msg.modelResponses.every(
      (mr) => mr.status != ModelResponseStatus.streaming,
    );

    emit(updated.copyWith(isSending: !allDone));
  }

  void _onSelectModelTab(ChatSelectModelTab event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final messages = current.messages.map((m) {
      if (m.id != event.messageId) return m;
      return m.copyWith(activeModelId: event.modelId);
    }).toList();
    emit(current.copyWith(messages: messages));
  }

  /// Replaces one model's slot inside the assistant message [messageId].
  ChatLoaded _updateModelResponse(
    ChatLoaded current,
    String messageId,
    int modelId,
    ModelResponse Function(ModelResponse) update,
  ) {
    final messages = current.messages.map((m) {
      if (m.id != messageId) return m;
      final updated = m.modelResponses
          .map((mr) => mr.modelId == modelId ? update(mr) : mr)
          .toList();
      return m.copyWith(modelResponses: updated);
    }).toList();
    return current.copyWith(messages: messages);
  }

  String? _modelName(int modelId) {
    if (state is! ChatLoaded) return null;
    for (final m in (state as ChatLoaded).availableModels) {
      if (m.id == modelId) return m.name;
    }
    return null;
  }

  String _externalId(int modelId) {
    if (state is! ChatLoaded) return '';
    for (final m in (state as ChatLoaded).availableModels) {
      if (m.id == modelId) return m.externalId;
    }
    return '';
  }

  /// Strips only the trailing suggested-questions block from a streamed
  /// answer, leaving the real content — including genuine code blocks — intact.
  ///
  /// The earlier version deleted everything between any pair of ``` fences (and
  /// any `[".."]` array anywhere), which silently ate legitimate content: e.g. a
  /// roadmap's sub-bullets vanished the moment the stream finished. We now reuse
  /// the same conservative "trailing follow-up array only" logic the history
  /// parser uses, so live streaming and reloaded history render identically.
  String _cleanStreamedContent(String content) {
    final withoutQuestions = _stripTrailingQuestionArray(content);
    return withoutQuestions
        // Drop a lone ***json / *** marker some prompts emit around the block,
        // but never a range spanning content.
        .replaceAll(RegExp(r'\*\*\*json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\s*\*\*\*\s*$', multiLine: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Removes a trailing `["q1","q2"]` (optionally fenced in ```json```) that
  /// carries follow-up questions, but only when nothing meaningful follows it —
  /// so a JSON array in the middle of the real answer is never touched.
  String _stripTrailingQuestionArray(String content) {
    final pattern = RegExp(
      r'(?:```(?:json)?\s*)?(\[\s*"(?:[^"\\]|\\.)*"(?:\s*,\s*"(?:[^"\\]|\\.)*")*\s*\])(?:\s*```)?',
      caseSensitive: false,
    );
    final matches = pattern.allMatches(content).toList();
    if (matches.isEmpty) return content;

    final last = matches.last;
    final trailing = content.substring(last.end);
    // Only strip when the array sits at the very end of the message.
    if (!RegExp(r'^(\s|`)*$').hasMatch(trailing)) return content;

    return content.substring(0, last.start).replaceAll(RegExp(r'[\s`]+$'), '');
  }

  List<String> _extractSuggestedQuestions(String content) {
    print('🔍 DEBUG: Extracting questions from content (length: ${content.length})');
    print('🔍 DEBUG: Content preview: ${content.substring(0, content.length > 200 ? 200 : content.length)}...');
    
    final questions = <String>[];
    final jsonArrayPattern = RegExp(
      r'\[\s*"([^"]+)"(?:\s*,\s*"([^"]+)")*\s*\]',
      multiLine: true,
    );

    final matches = jsonArrayPattern.allMatches(content).toList();
    print('🔍 DEBUG: Found ${matches.length} potential JSON arrays');

    for (final match in matches) {
      try {
        final jsonStr = match.group(0);
        print('🔍 DEBUG: Trying to parse: $jsonStr');
        if (jsonStr != null) {
          final decoded = jsonDecode(jsonStr);
          if (decoded is List) {
            questions.addAll(decoded.map((e) => e.toString()));
            print('✅ DEBUG: Successfully extracted ${decoded.length} questions');
          }
        }
      } catch (e) {
        print('❌ DEBUG: Failed to parse JSON: $e');
      }
    }

    print('🔍 DEBUG: Total questions extracted: ${questions.length}');
    if (questions.isNotEmpty) {
      print('📝 DEBUG: Questions: $questions');
    }
    
    return questions;
  }

  // ── Context handlers ───────────────────────────────────────────────────────

  Future<void> _onLoadContexts(
    ChatLoadContexts event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final result = await _repository.getSidebarContexts();
    if (state is! ChatLoaded) return;
    result.fold(
      (_) {}, // silently ignore: sidebar is non-critical
      (contexts) {
        final current = state as ChatLoaded;
        // Auto-activate all contexts on first load
        final activeIds = current.activeContextIds.isEmpty
            ? contexts.map((c) => c.id).toSet()
            : current.activeContextIds;
        emit(current.copyWith(
          sidebarContexts: contexts,
          activeContextIds: activeIds,
        ));
      },
    );
  }

  void _onToggleContext(
    ChatToggleContext event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final updated = Set<String>.from(current.activeContextIds);
    if (updated.contains(event.contextId)) {
      updated.remove(event.contextId);
    } else {
      updated.add(event.contextId);
    }
    emit(current.copyWith(activeContextIds: updated));
  }

  Future<void> _onDeleteContext(
    ChatDeleteContext event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    await _repository.deleteContext(event.contextId);
    final updatedContexts = current.sidebarContexts
        .where((c) => c.id != event.contextId)
        .toList();
    final updatedActive = Set<String>.from(current.activeContextIds)
      ..remove(event.contextId);
    emit(current.copyWith(
      sidebarContexts: updatedContexts,
      activeContextIds: updatedActive,
    ));
  }
}
