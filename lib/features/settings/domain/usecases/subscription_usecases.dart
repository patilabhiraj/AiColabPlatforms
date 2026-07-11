import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/subscription_entity.dart';
import '../repositories/settings_repository.dart';

class GetCurrentSubscriptionUseCase {
  final SettingsRepository repository;
  GetCurrentSubscriptionUseCase(this.repository);

  Future<Either<Failure, SubscriptionSummaryEntity>> call() {
    return repository.getCurrentSubscription();
  }
}

class GetPlansUseCase {
  final SettingsRepository repository;
  GetPlansUseCase(this.repository);

  Future<Either<Failure, List<PlanEntity>>> call() {
    return repository.getPlans();
  }
}

class CancelSubscriptionUseCase {
  final SettingsRepository repository;
  CancelSubscriptionUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.cancelSubscription();
  }
}
