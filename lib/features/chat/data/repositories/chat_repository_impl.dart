import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

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
}
