import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../entities/paginated_result.dart';
import '../repositories/settings_repository.dart';

class GetArchivedChatsUseCase {
  final SettingsRepository repository;
  GetArchivedChatsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<ArchivedChatEntity>>> call() {
    return repository.getArchivedChats();
  }
}

class UnarchiveChatUseCase {
  final SettingsRepository repository;
  UnarchiveChatUseCase(this.repository);

  Future<Either<Failure, void>> call(String chatId) {
    return repository.unarchiveChat(chatId);
  }
}
