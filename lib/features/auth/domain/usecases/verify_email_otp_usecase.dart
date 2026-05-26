import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  final AuthRepository repository;

  VerifyEmailOtpUseCase(this.repository);

  Future<Either<Failure, void>> call(String email, String otp) async {
    return await repository.verifyEmailOtp(email, otp);
  }
}
