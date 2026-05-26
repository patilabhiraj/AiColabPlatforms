import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

class CreateConversationUseCase {
  final ChatRepository repository;
  CreateConversationUseCase(this.repository);

  Future<Either<Failure, ChatConversation>> call(String firstMessage) =>
      repository.createConversation(firstMessage);
}
