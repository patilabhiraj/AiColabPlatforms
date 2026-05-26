import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_context.dart';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';
import '../entities/shared_chat.dart';
import '../entities/user_context.dart';

abstract class ChatRepository {
  // ── Legacy (kept for backward compatibility) ──────────────────────────────
  Future<Either<Failure, List<ChatConversation>>> getConversations();
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content);
  Future<Either<Failure, ChatConversation>> createConversation(String firstMessage);

  // ── Streaming ─────────────────────────────────────────────────────────────
  Stream<Either<Failure, String>> sendMessageStream(String conversationId, String content);

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
