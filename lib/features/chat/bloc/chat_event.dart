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

// ── Catalog / model selection ─────────────────────────────────────────────────

/// Fetch available models + assistants (called once after conversations load).
class ChatLoadCatalog extends ChatEvent {}

/// Toggle a model in the selection (respects single/multi mode + capability).
class ChatToggleModel extends ChatEvent {
  final int modelId;
  ChatToggleModel(this.modelId);
}

/// Switch the active capability (STANDARD | WEB_SEARCH | IMAGE_GENERATION).
class ChatSetCapability extends ChatEvent {
  final String capability;
  ChatSetCapability(this.capability);
}

/// Switch between single-model and multi-model comparison modes.
class ChatSetMultiMode extends ChatEvent {
  final bool multiMode;
  ChatSetMultiMode(this.multiMode);
}

/// Select an assistant (null clears it) and start a fresh conversation.
class ChatSelectAssistant extends ChatEvent {
  final Assistant? assistant;
  ChatSelectAssistant(this.assistant);
}
