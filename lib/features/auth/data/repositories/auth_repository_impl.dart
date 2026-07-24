import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
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
    } on EmailVerificationRequiredException catch (e) {
      // Automatically resend OTP
      try {
        await remoteDataSource.resendEmailOtp(e.email);
        print('DEBUG: OTP resent to ${e.email}');
      } catch (otpError) {
        print('DEBUG WARNING: Failed to resend OTP: $otpError');
      }
      return Left(EmailVerificationFailure(e.email, e.message));
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
    } on EmailVerificationRequiredException catch (e) {
      // OTP already sent during registration, no need to resend
      print('DEBUG: Email verification required for ${e.email}');
      return Left(EmailVerificationFailure(e.email, e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Failed to register.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleLogin(String idToken) async {
    try {
      final userModel = await remoteDataSource.googleLogin(idToken);
      if (userModel.token.isNotEmpty) {
        await localDataSource.saveToken(userModel.token);
      }
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e, 'Google sign-in failed.')));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred.'));
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
  Future<Either<Failure, bool>> verifyEmailOtp(String email, String otp) async {
    try {
      final token = await remoteDataSource.verifyEmailOtp(email, otp);
      if (token.isNotEmpty) {
        // Backend auto-logged the user in on verification — persist the session
        // so the app can go straight to home instead of the login screen.
        await localDataSource.saveToken(token);
        return const Right(true);
      }
      return const Right(false);
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
      var user = UserModel(
        id: (map['id'] ?? map['sub'] ?? '').toString(),
        email: map['email'] ?? '',
        firstName: map['firstName'] ?? map['given_name'] ?? 'User',
        lastName: map['lastName'] ?? map['family_name'] ?? '',
        token: token,
      );

      // The JWT only carries id/role — fetch the real profile (name, email,
      // photo) so the drawer/header show the actual user, not "User".
      try {
        final profile = await remoteDataSource.getProfile();
        user = UserModel(
          id: user.id,
          email: profile.email.isNotEmpty ? profile.email : user.email,
          firstName: profile.firstName.isNotEmpty ? profile.firstName : user.firstName,
          lastName: profile.lastName.isNotEmpty ? profile.lastName : user.lastName,
          token: token,
          profileImageUrl: profile.profileImageUrl,
        );
      } catch (e) {
        print('DEBUG WARNING: getCachedUser could not refresh profile from API: $e');
      }

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
