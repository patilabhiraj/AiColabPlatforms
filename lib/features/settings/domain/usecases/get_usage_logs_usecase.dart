import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usage_log_entity.dart';
import '../repositories/settings_repository.dart';

class GetUsageLogsUseCase {
  final SettingsRepository repository;
  GetUsageLogsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<UsageLogGroupEntity>>> call({
    required int page,
    required int pageSize,
    required String userId,
    String? sort,
  }) {
    return repository.getUsageLogs(
      page: page,
      pageSize: pageSize,
      userId: userId,
      sort: sort,
    );
  }
}
