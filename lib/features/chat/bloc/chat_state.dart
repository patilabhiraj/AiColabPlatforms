part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatConversation> conversations;
  final ChatConversation? selectedConversation;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? streamingContent;
  final String? streamingMessageId;
  final List<ChatMessage> starredMessages;

  // ── Conversation list pagination ──────────────────────────────────────────
  /// Highest conversation page loaded so far (starts at 1).
  final int conversationsPage;

  /// Whether the backend has more conversation pages to load.
  final bool hasMoreConversations;

  /// True while a "Load More Chats" request is in flight.
  final bool isLoadingMoreConversations;

  // ── Model selection / capabilities ────────────────────────────────────────
  /// All active models available for selection (from `/api/models`).
  final List<AiModel> availableModels;

  /// IDs of currently selected models. In single mode this holds exactly one.
  final List<int> selectedModelIds;

  /// Active capability: STANDARD | WEB_SEARCH | IMAGE_GENERATION.
  final String capability;

  /// false = single model, true = multi-model comparison.
  final bool multiMode;

  // ── Assistants ────────────────────────────────────────────────────────────
  final List<Assistant> assistants;
  final Assistant? selectedAssistant;

  ChatLoaded({
    required this.conversations,
    this.selectedConversation,
    this.messages = const [],
    this.isSending = false,
    this.streamingContent,
    this.streamingMessageId,
    this.starredMessages = const [],
    this.conversationsPage = 1,
    this.hasMoreConversations = false,
    this.isLoadingMoreConversations = false,
    this.availableModels = const [],
    this.selectedModelIds = const [],
    this.capability = 'STANDARD',
    this.multiMode = false,
    this.assistants = const [],
    this.selectedAssistant,
  });

  bool get isStreaming => streamingContent != null;

  ChatLoaded copyWith({
    List<ChatConversation>? conversations,
    ChatConversation? selectedConversation,
    bool clearConversation = false,
    List<ChatMessage>? messages,
    bool? isSending,
    String? streamingContent,
    bool clearStreaming = false,
    String? streamingMessageId,
    List<ChatMessage>? starredMessages,
    int? conversationsPage,
    bool? hasMoreConversations,
    bool? isLoadingMoreConversations,
    List<AiModel>? availableModels,
    List<int>? selectedModelIds,
    String? capability,
    bool? multiMode,
    List<Assistant>? assistants,
    Assistant? selectedAssistant,
    bool clearAssistant = false,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      selectedConversation: clearConversation
          ? null
          : selectedConversation ?? this.selectedConversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      streamingContent: clearStreaming ? null : (streamingContent ?? this.streamingContent),
      streamingMessageId: clearStreaming ? null : (streamingMessageId ?? this.streamingMessageId),
      starredMessages: starredMessages ?? this.starredMessages,
      conversationsPage: conversationsPage ?? this.conversationsPage,
      hasMoreConversations: hasMoreConversations ?? this.hasMoreConversations,
      isLoadingMoreConversations:
          isLoadingMoreConversations ?? this.isLoadingMoreConversations,
      availableModels: availableModels ?? this.availableModels,
      selectedModelIds: selectedModelIds ?? this.selectedModelIds,
      capability: capability ?? this.capability,
      multiMode: multiMode ?? this.multiMode,
      assistants: assistants ?? this.assistants,
      selectedAssistant:
          clearAssistant ? null : (selectedAssistant ?? this.selectedAssistant),
    );
  }

  /// Models valid for the active capability (mirrors the web filtering).
  List<AiModel> get modelsForCapability =>
      availableModels.where((m) => m.supportsCapability(capability)).toList();
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
