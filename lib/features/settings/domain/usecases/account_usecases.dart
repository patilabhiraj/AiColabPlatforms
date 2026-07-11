import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../repositories/settings_repository.dart';

class GetProfileUseCase {
  final SettingsRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<Failure, AccountEntity>> call() {
    return repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final SettingsRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, AccountEntity>> call({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? profileImagePath,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImagePath: profileImagePath,
    );
  }
}

class DeleteAccountUseCase {
  final SettingsRepository repository;
  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) {
    return repository.deleteAccount(userId);
  }
}
