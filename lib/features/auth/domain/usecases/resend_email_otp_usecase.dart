import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResendEmailOtpUseCase {
  final AuthRepository repository;

  ResendEmailOtpUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.resendEmailOtp(email);
  }
}
