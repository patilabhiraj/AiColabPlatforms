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
      final userModel = await remoteDataSource.login(email, password);
      return Right(userModel); // Success returns the Right side of Either
    } on DioException catch (e) {
      // Return custom Failure on error (Left side of Either)
      final errorMessage =
          e.response?.data['message'] ?? 'Failed to login. Please try again.';
      return Left(ServerFailure(errorMessage));
    } catch (e) {
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
      final userModel = await remoteDataSource.register(
        firstName,
        lastName,
        email,
        password,
      );
      return Right(userModel);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ??
          'Failed to register. Please try again.';
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleLogin(String token) async {
    try {
      final userModel = await remoteDataSource.googleLogin(token);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
