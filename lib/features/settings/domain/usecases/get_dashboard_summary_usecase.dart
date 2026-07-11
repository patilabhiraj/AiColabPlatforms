import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary_entity.dart';
import '../repositories/settings_repository.dart';

class GetDashboardSummaryUseCase {
  final SettingsRepository repository;
  GetDashboardSummaryUseCase(this.repository);

  Future<Either<Failure, DashboardSummaryEntity>> call() {
    return repository.getDashboardSummary();
  }
}
