import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ai_model.dart';
import '../../domain/entities/assistant.dart';
import '../../domain/entities/chat_context.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/shared_chat.dart';
import '../../domain/entities/user_context.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_context_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl(this.remoteDataSource);

  // ── Helpers ───────────────────────────────────────────────────────────────

  Either<Failure, T> _handleError<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    return Left(ServerFailure('Unexpected error: $e'));
  }

  // ── Legacy ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ChatConversation>>> getConversations() async {
    try {
      return Right(await remoteDataSource.getConversations());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId) async {
    try {
      return Right(await remoteDataSource.getMessages(conversationId));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content) async {
    try {
      return Right(await remoteDataSource.sendMessage(conversationId, content));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> createConversation(
    String firstMessage, {
    List<int>? modelIds,
    String? capability,
    int? assistantId,
  }) async {
    try {
      return Right(await remoteDataSource.createConversation(
        firstMessage,
        modelIds: modelIds,
        capability: capability,
        assistantId: assistantId,
      ));
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Catalog (models & assistants) ─────────────────────────────────────────

  @override
  Future<Either<Failure, List<AiModel>>> getModels() async {
    try {
      return Right(await remoteDataSource.getModels());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, List<Assistant>>> getAssistants() async {
    try {
      return Right(await remoteDataSource.getAssistants());
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Streaming ─────────────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, String>> sendMessageStream(
    String conversationId,
    String content,
  ) async* {
    try {
      await for (final token in remoteDataSource.sendMessageStream(conversationId, content)) {
        yield Right(token);
      }
    } catch (e) {
      yield _handleError(e);
    }
  }

  @override
  Stream<Either<Failure, String>> regenerateMessage(
    String chatId,
    String messageId,
  ) async* {
    try {
      await for (final token in remoteDataSource.regenerateMessage(chatId, messageId)) {
        yield Right(token);
      }
    } catch (e) {
      yield _handleError(e);
    }
  }

  @override
  Stream<Either<Failure, String>> editMessage(
    String chatId,
    String messageId,
    String newContent,
  ) async* {
    try {
      await for (final token in remoteDataSource.editMessage(chatId, messageId, newContent)) {
        yield Right(token);
      }
    } catch (e) {
      yield _handleError(e);
    }
  }

  @override
  Stream<Either<Failure, String>> continueChat(String chatId) async* {
    try {
      await for (final token in remoteDataSource.continueChat(chatId)) {
        yield Right(token);
      }
    } catch (e) {
      yield _handleError(e);
    }
  }

  // ── Chat CRUD ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ChatConversation>>> listChats() async {
    try {
      return Right(await remoteDataSource.listChats());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> createChat(String title) async {
    try {
      return Right(await remoteDataSource.createChat(title));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> getChatById(String id) async {
    try {
      return Right(await remoteDataSource.getChatById(id));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> updateChat(String id, String title) async {
    try {
      return Right(await remoteDataSource.updateChat(id, title));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String id) async {
    try {
      await remoteDataSource.deleteChat(id);
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Chat state toggles ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ChatConversation>> archiveChat(String id) async {
    try {
      return Right(await remoteDataSource.archiveChat(id));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> pinChat(String id) async {
    try {
      return Right(await remoteDataSource.pinChat(id));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> shareChat(String id) async {
    try {
      return Right(await remoteDataSource.shareChat(id));
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Chat contexts ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ChatContext>>> getChatContexts(String id) async {
    try {
      return Right(await remoteDataSource.getChatContexts(id));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> replaceChatContexts(
    String id,
    List<ChatContext> contexts,
  ) async {
    try {
      final models = contexts
          .map((c) => ChatContextModel(
                role: c.role,
                content: c.content,
                timestamp: c.timestamp,
              ))
          .toList();
      await remoteDataSource.replaceChatContexts(id, models);
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Feedback ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> submitFeedback(
    String chatId,
    String responseId,
    bool isPositive, {
    String? comment,
  }) async {
    try {
      await remoteDataSource.submitFeedback(chatId, responseId, isPositive, comment: comment);
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Shared chat ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, SharedChat>> getSharedChat(String shareId) async {
    try {
      return Right(await remoteDataSource.getSharedChat(shareId));
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── User Contexts ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<UserContext>>> getSidebarContexts() async {
    try {
      return Right(await remoteDataSource.getSidebarContexts());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, List<UserContext>>> listContexts() async {
    try {
      return Right(await remoteDataSource.listContexts());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, UserContext>> createContext(
    String name,
    String content,
    String role,
  ) async {
    try {
      return Right(await remoteDataSource.createContext(name, content, role));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, UserContext>> getContextById(String id) async {
    try {
      return Right(await remoteDataSource.getContextById(id));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, UserContext>> updateContext(
    String id,
    String name,
    String content,
    String role,
  ) async {
    try {
      return Right(await remoteDataSource.updateContext(id, name, content, role));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteContext(String id) async {
    try {
      await remoteDataSource.deleteContext(id);
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }
}
