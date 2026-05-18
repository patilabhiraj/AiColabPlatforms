import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      return Right(await remoteDataSource.login(email, password));
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to login.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      return Right(await remoteDataSource.register(firstName, lastName, email, password));
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to register.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleLogin(String token) async {
    try {
      return Right(await remoteDataSource.googleLogin(token));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to send OTP.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(email, otp, newPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to reset password.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailOtp(String email, String otp) async {
    try {
      await remoteDataSource.verifyEmailOtp(email, otp);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to verify OTP.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> resendEmailOtp(String email) async {
    try {
      await remoteDataSource.resendEmailOtp(email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to resend OTP.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  String _dioMessage(DioException e, String fallback) =>
      e.response?.data?['message'] ?? fallback;
}
