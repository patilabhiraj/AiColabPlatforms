import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({required String email, required String password});
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> googleLogin(String idToken);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  /// Verifies the email OTP. Resolves to `true` when the backend also returned
  /// a session token (user is now logged in), `false` when it only confirmed
  /// the OTP and the user must still log in manually.
  Future<Either<Failure, bool>> verifyEmailOtp(String email, String otp);
  Future<Either<Failure, void>> resendEmailOtp(String email);
  Future<Either<Failure, UserEntity?>> getCachedUser();
  Future<Either<Failure, void>> logout();
}
