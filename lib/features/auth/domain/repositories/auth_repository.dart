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
  Future<Either<Failure, UserEntity>> googleLogin(String token);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<Either<Failure, void>> verifyEmailOtp(String email, String otp);
  Future<Either<Failure, void>> resendEmailOtp(String email);
  Future<Either<Failure, UserEntity?>> getCachedUser();
  Future<Either<Failure, void>> logout();
}
