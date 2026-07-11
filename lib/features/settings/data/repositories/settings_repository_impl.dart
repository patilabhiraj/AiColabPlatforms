import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/usage_log_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  SettingsRepositoryImpl(this.remoteDataSource);

  Either<Failure, T> _handleError<T>(Object e) {
    if (e is DioException) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error.';
      return Left(ServerFailure(message.toString()));
    }
    return Left(ServerFailure('Unexpected error: $e'));
  }

  @override
  Future<Either<Failure, DashboardSummaryEntity>> getDashboardSummary() async {
    try {
      return Right(await remoteDataSource.getDashboardSummary());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWallet() async {
    try {
      return Right(await remoteDataSource.getWallet());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<WalletTransactionEntity>>>
      getWalletTransactions({
    required int page,
    required int pageSize,
    String? sort,
  }) async {
    try {
      return Right(await remoteDataSource.getWalletTransactions(
        page: page,
        pageSize: pageSize,
        sort: sort,
      ));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<UsageLogGroupEntity>>> getUsageLogs({
    required int page,
    required int pageSize,
    required String userId,
    String? sort,
  }) async {
    try {
      return Right(await remoteDataSource.getUsageLogs(
        page: page,
        pageSize: pageSize,
        userId: userId,
        sort: sort,
      ));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, SubscriptionSummaryEntity>>
      getCurrentSubscription() async {
    try {
      return Right(await remoteDataSource.getCurrentSubscription());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, List<PlanEntity>>> getPlans() async {
    try {
      return Right(await remoteDataSource.getPlans());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription() async {
    try {
      await remoteDataSource.cancelSubscription();
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getProfile() async {
    try {
      return Right(await remoteDataSource.getProfile());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? profileImagePath,
  }) async {
    try {
      return Right(await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImagePath: profileImagePath,
      ));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async {
    try {
      await remoteDataSource.deleteAccount(userId);
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> getPreferences() async {
    try {
      return Right(await remoteDataSource.getPreferences());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> updatePreferences({
    required bool enableFollowUpQuestions,
  }) async {
    try {
      return Right(await remoteDataSource.updatePreferences(
        enableFollowUpQuestions: enableFollowUpQuestions,
      ));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<ArchivedChatEntity>>>
      getArchivedChats() async {
    try {
      return Right(await remoteDataSource.getArchivedChats());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> unarchiveChat(String chatId) async {
    try {
      await remoteDataSource.unarchiveChat(chatId);
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }
}
