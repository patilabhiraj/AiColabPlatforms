import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_context.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/shared_chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_context_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ChatConversation>>> getConversations() async {
    try {
      return Right(await remoteDataSource.getConversations());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId) async {
    try {
      return Right(await remoteDataSource.getMessages(conversationId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content) async {
    try {
      return Right(await remoteDataSource.sendMessage(conversationId, content));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> createConversation(String firstMessage) async {
    try {
      return Right(await remoteDataSource.createConversation(firstMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, String>> sendMessageStream(String conversationId, String content) async* {
    try {
      await for (final token in remoteDataSource.sendMessageStream(conversationId, content)) {
        yield Right(token);
      }
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SharedChat>> getSharedChat(String shareId) async {
    try {
      final sharedChat = await remoteDataSource.getSharedChat(shareId);
      return Right(sharedChat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatConversation>>> listChats() async {
    try {
      final chats = await remoteDataSource.listChats();
      return Right(chats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> createChat(String title) async {
    try {
      final chat = await remoteDataSource.createChat(title);
      return Right(chat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> getChatById(String id) async {
    try {
      final chat = await remoteDataSource.getChatById(id);
      return Right(chat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> updateChat(String id, String title) async {
    try {
      final chat = await remoteDataSource.updateChat(id, title);
      return Right(chat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String id) async {
    try {
      await remoteDataSource.deleteChat(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatContext>>> getChatContexts(String id) async {
    try {
      final contexts = await remoteDataSource.getChatContexts(id);
      return Right(contexts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> replaceChatContexts(
    String id,
    List<ChatContext> contexts,
  ) async {
    try {
      final contextModels = contexts
          .map((c) => ChatContextModel(
                role: c.role,
                content: c.content,
                timestamp: c.timestamp,
              ))
          .toList();
      await remoteDataSource.replaceChatContexts(id, contextModels);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}