import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  final AuthRepository repository;

  VerifyEmailOtpUseCase(this.repository);

  /// Returns `true` when verification also established a session (auto-login),
  /// `false` when the user still needs to log in manually.
  Future<Either<Failure, bool>> call(String email, String otp) async {
    return await repository.verifyEmailOtp(email, otp);
  }
}
