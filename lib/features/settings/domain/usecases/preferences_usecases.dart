import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../repositories/settings_repository.dart';

class GetPreferencesUseCase {
  final SettingsRepository repository;
  GetPreferencesUseCase(this.repository);

  Future<Either<Failure, UserPreferencesEntity>> call() {
    return repository.getPreferences();
  }
}

class UpdatePreferencesUseCase {
  final SettingsRepository repository;
  UpdatePreferencesUseCase(this.repository);

  Future<Either<Failure, UserPreferencesEntity>> call({
    required bool enableFollowUpQuestions,
  }) {
    return repository.updatePreferences(
      enableFollowUpQuestions: enableFollowUpQuestions,
    );
  }
}
