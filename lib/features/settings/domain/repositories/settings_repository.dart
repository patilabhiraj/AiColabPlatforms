import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../entities/dashboard_summary_entity.dart';
import '../entities/subscription_entity.dart';
import '../entities/usage_log_entity.dart';
import '../entities/wallet_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, DashboardSummaryEntity>> getDashboardSummary();

  Future<Either<Failure, WalletEntity>> getWallet();
  Future<Either<Failure, PaginatedResult<WalletTransactionEntity>>>
      getWalletTransactions({
    required int page,
    required int pageSize,
    String? sort,
  });

  Future<Either<Failure, PaginatedResult<UsageLogGroupEntity>>> getUsageLogs({
    required int page,
    required int pageSize,
    required String userId,
    String? sort,
  });

  Future<Either<Failure, SubscriptionSummaryEntity>> getCurrentSubscription();
  Future<Either<Failure, List<PlanEntity>>> getPlans();
  Future<Either<Failure, void>> cancelSubscription();

  Future<Either<Failure, AccountEntity>> getProfile();
  Future<Either<Failure, AccountEntity>> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? profileImagePath,
  });
  Future<Either<Failure, void>> deleteAccount(String userId);

  Future<Either<Failure, UserPreferencesEntity>> getPreferences();
  Future<Either<Failure, UserPreferencesEntity>> updatePreferences({
    required bool enableFollowUpQuestions,
  });

  Future<Either<Failure, PaginatedResult<ArchivedChatEntity>>>
      getArchivedChats();
  Future<Either<Failure, void>> unarchiveChat(String chatId);
}
