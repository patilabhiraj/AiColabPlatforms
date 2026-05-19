import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      print('DEBUG: remoteDataSource.login returned token: "${userModel.token}"');
      if (userModel.token.isNotEmpty) {
        await localDataSource.saveToken(userModel.token);
      } else {
        print('DEBUG WARNING: Token is empty in login response!');
      }
      return Right(userModel);
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
      final userModel = await remoteDataSource.register(firstName, lastName, email, password);
      print('DEBUG: remoteDataSource.register returned token: "${userModel.token}"');
      if (userModel.token.isNotEmpty) {
        await localDataSource.saveToken(userModel.token);
      } else {
        print('DEBUG WARNING: Token is empty in register response!');
      }
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to register.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleLogin(String token) async {
    try {
      final userModel = await remoteDataSource.googleLogin(token);
      print('DEBUG: remoteDataSource.googleLogin returned token: "${userModel.token}"');
      if (userModel.token.isNotEmpty) {
        await localDataSource.saveToken(userModel.token);
      } else {
        print('DEBUG WARNING: Token is empty in googleLogin response!');
      }
      return Right(userModel);
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

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    try {
      print('DEBUG: AuthRepositoryImpl.getCachedUser checking local storage...');
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) {
        print('DEBUG: AuthRepositoryImpl.getCachedUser got empty token.');
        return const Right(null);
      }
      print('DEBUG: AuthRepositoryImpl.getCachedUser got token successfully. Parsing JWT...');
      final parts = token.split('.');
      if (parts.length != 3) {
        print('DEBUG WARNING: Token length split was not 3. Deleting invalid token.');
        await localDataSource.deleteToken();
        return const Right(null);
      }
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = json.decode(payload) as Map<String, dynamic>;
      final user = UserModel(
        id: (map['id'] ?? map['sub'] ?? '').toString(),
        email: map['email'] ?? '',
        firstName: map['firstName'] ?? map['given_name'] ?? 'User',
        lastName: map['lastName'] ?? map['family_name'] ?? '',
        token: token,
      );
      print('DEBUG: AuthRepositoryImpl.getCachedUser session parsed successfully for ${user.email}!');
      return Right(user);
    } catch (e) {
      print('DEBUG ERROR: AuthRepositoryImpl.getCachedUser failed: $e');
      return const Left(ServerFailure('Failed to load local session.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.deleteToken();
      print('DEBUG: AuthRepositoryImpl logged out and deleted token.');
      return const Right(null);
    } catch (e) {
      print('DEBUG ERROR: AuthRepositoryImpl logout failed: $e');
      return const Left(ServerFailure('Failed to logout.'));
    }
  }

  String _dioMessage(DioException e, String fallback) =>
      e.response?.data?['message'] ?? fallback;
}
