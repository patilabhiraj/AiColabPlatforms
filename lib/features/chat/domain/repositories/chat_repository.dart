import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ai_model.dart';
import '../entities/assistant.dart';
import '../entities/chat_context.dart';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';
import '../entities/multi_model.dart';
import '../entities/paginated_conversations.dart';
import '../entities/shared_chat.dart';
import '../entities/user_context.dart';

abstract class ChatRepository {
  // ── Legacy (kept for backward compatibility) ──────────────────────────────
  Future<Either<Failure, List<ChatConversation>>> getConversations();

  /// Fetches one page of conversations for the sidebar's "Load More" pagination.
  Future<Either<Failure, PaginatedConversations>> getConversationsPage({
    required int page,
    int pageSize,
  });
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content);
  Future<Either<Failure, ChatConversation>> createConversation(
    String firstMessage, {
    List<int>? modelIds,
    String? capability,
    int? assistantId,
  });

  // ── Catalog (models & assistants) ─────────────────────────────────────────
  Future<Either<Failure, List<AiModel>>> getModels();
  Future<Either<Failure, List<Assistant>>> getAssistants();

  // ── Streaming ─────────────────────────────────────────────────────────────
  Stream<Either<Failure, String>> sendMessageStream(String conversationId, String content);

  // ── Multi-model send ──────────────────────────────────────────────────────
  Future<Either<Failure, PrepareMultiResult>> prepareMulti(
    String conversationId,
    String content,
  );

  /// Per-model stream. Yields [ModelStreamChunk]s tagged with [modelId].
  Stream<Either<Failure, ModelStreamChunk>> sendMessageStreamForModel(
    String conversationId,
    String content,
    int modelId, {
    int userMessageId,
    int assistantMessageId,
  });

  // ── Chat CRUD ─────────────────────────────────────────────────────────────
  Future<Either<Failure, List<ChatConversation>>> listChats();
  Future<Either<Failure, ChatConversation>> createChat(String title);
  Future<Either<Failure, ChatConversation>> getChatById(String id);
  Future<Either<Failure, ChatConversation>> updateChat(String id, String title);
  Future<Either<Failure, void>> deleteChat(String id);

  // ── Chat state toggles ────────────────────────────────────────────────────
  Future<Either<Failure, ChatConversation>> archiveChat(String id);
  Future<Either<Failure, ChatConversation>> pinChat(String id);
  Future<Either<Failure, ChatConversation>> shareChat(String id);

  // ── Chat contexts ─────────────────────────────────────────────────────────
  Future<Either<Failure, List<ChatContext>>> getChatContexts(String id);
  Future<Either<Failure, void>> replaceChatContexts(String id, List<ChatContext> contexts);

  // ── Message actions (streaming) ───────────────────────────────────────────
  Stream<Either<Failure, String>> regenerateMessage(String chatId, String messageId);
  Stream<Either<Failure, String>> editMessage(String chatId, String messageId, String newContent);
  Stream<Either<Failure, String>> continueChat(String chatId);

  // ── Feedback ──────────────────────────────────────────────────────────────
  Future<Either<Failure, void>> submitFeedback(
    String chatId,
    String responseId,
    bool isPositive, {
    String? comment,
  });

  // ── Shared chat ───────────────────────────────────────────────────────────
  Future<Either<Failure, SharedChat>> getSharedChat(String shareId);

  // ── User Contexts ─────────────────────────────────────────────────────────
  Future<Either<Failure, List<UserContext>>> getSidebarContexts();
  Future<Either<Failure, List<UserContext>>> listContexts();
  Future<Either<Failure, UserContext>> createContext(String name, String content, String role);
  Future<Either<Failure, UserContext>> getContextById(String id);
  Future<Either<Failure, UserContext>> updateContext(String id, String name, String content, String role);
  Future<Either<Failure, void>> deleteContext(String id);
}
