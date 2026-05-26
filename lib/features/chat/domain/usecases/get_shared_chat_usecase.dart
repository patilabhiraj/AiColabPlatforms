import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/shared_chat.dart';
import '../repositories/chat_repository.dart';

/// UseCase for fetching a shared chat by its share ID
/// 
/// This follows the clean architecture pattern where each use case
/// represents a single business operation.
class GetSharedChatUseCase {
  final ChatRepository repository;

  GetSharedChatUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [shareId] - The public share identifier for the chat
  /// 
  /// Returns Either:
  /// - Left: Failure if the operation fails
  /// - Right: SharedChat entity if successful
  Future<Either<Failure, SharedChat>> call(String shareId) async {
    return await repository.getSharedChat(shareId);
  }
}
