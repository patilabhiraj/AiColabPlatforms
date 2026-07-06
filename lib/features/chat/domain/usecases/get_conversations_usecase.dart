import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_conversation.dart';
import '../entities/paginated_conversations.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;
  GetConversationsUseCase(this.repository);

  Future<Either<Failure, List<ChatConversation>>> call() =>
      repository.getConversations();

  /// Fetches a single page for the sidebar's "Load More Chats" pagination.
  Future<Either<Failure, PaginatedConversations>> page({
    required int page,
    int pageSize = 5,
  }) =>
      repository.getConversationsPage(page: page, pageSize: pageSize);
}
