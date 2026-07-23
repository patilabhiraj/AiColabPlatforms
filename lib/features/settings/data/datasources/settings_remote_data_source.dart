import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/usage_log_entity.dart';
import '../models/account_model.dart';
import '../models/dashboard_summary_model.dart';
import '../models/subscription_model.dart';
import '../models/usage_log_model.dart';
import '../models/wallet_model.dart';

abstract class SettingsRemoteDataSource {
  Future<DashboardSummaryModel> getDashboardSummary();

  Future<WalletModel> getWallet();
  Future<PaginatedResult<WalletTransactionModel>> getWalletTransactions({
    required int page,
    required int pageSize,
    String? sort,
  });

  Future<PaginatedResult<UsageLogGroupModel>> getUsageLogs({
    required int page,
    required int pageSize,
    required String userId,
    String? sort,
  });

  Future<SubscriptionSummaryModel> getCurrentSubscription();
  Future<List<PlanModel>> getPlans();
  Future<void> cancelSubscription();
  // Calls backend → backend calls Cashfree → returns orderId + paymentSessionId
  Future<Map<String, dynamic>> createSubscription(int planId);

  Future<AccountModel> getProfile();
  Future<AccountModel> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? profileImagePath,
  });
  Future<void> deleteAccount(String userId);

  Future<UserPreferencesModel> getPreferences();
  Future<UserPreferencesModel> updatePreferences({
    required bool enableFollowUpQuestions,
  });

  Future<PaginatedResult<ArchivedChatModel>> getArchivedChats();
  Future<void> unarchiveChat(String chatId);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;
  SettingsRemoteDataSourceImpl(this.dio);

  Map<String, dynamic> _unwrap(Response response) =>
      (response.data['data'] as Map<String, dynamic>?) ?? const {};

  PaginatedResult<T> _paginated<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawItems = (json['data'] as List?) ?? const [];
    return PaginatedResult<T>(
      items: rawItems.whereType<Map<String, dynamic>>().map(fromJson).toList(),
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
    );
  }

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response = await dio.get(ApiConstants.dashboardSummary);
    return DashboardSummaryModel.fromJson(_unwrap(response));
  }

  @override
  Future<WalletModel> getWallet() async {
    final response = await dio.get(ApiConstants.wallet);
    return WalletModel.fromJson(_unwrap(response));
  }

  @override
  Future<PaginatedResult<WalletTransactionModel>> getWalletTransactions({
    required int page,
    required int pageSize,
    String? sort,
  }) async {
    final response = await dio.get(
      ApiConstants.walletTransactions,
      queryParameters: {
        'page': '$page',
        'pageSize': '$pageSize',
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
    );
    return _paginated(_unwrap(response), WalletTransactionModel.fromJson);
  }

  @override
  Future<PaginatedResult<UsageLogGroupModel>> getUsageLogs({
    required int page,
    required int pageSize,
    required String userId,
    String? sort,
  }) async {
    final response = await dio.get(
      ApiConstants.usageLogs,
      queryParameters: {
        'page': '$page',
        'pageSize': '$pageSize',
        'userId': userId,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
    );
    return _paginated(_unwrap(response), UsageLogGroupModel.fromJson);
  }

  @override
  Future<SubscriptionSummaryModel> getCurrentSubscription() async {
    final response = await dio.get(ApiConstants.subscriptionCurrent);
    return SubscriptionSummaryModel.fromJson(_unwrap(response));
  }

  @override
  Future<List<PlanModel>> getPlans() async {
    final response = await dio.get(
      ApiConstants.plans,
      queryParameters: {'isActive': 'true'},
    );
    final data = _unwrap(response);
    final rawList = (data['data'] as List?) ?? const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(PlanModel.fromJson)
        .where((p) => p.isActive)
        .toList();
  }

  @override
  Future<void> cancelSubscription() async {
    await dio.post(ApiConstants.subscriptionCancel);
  }

  @override
  Future<Map<String, dynamic>> createSubscription(int planId) async {
    // Step 1: Backend ला POST request पाठवतो with planId
    // Step 2: Backend internally Cashfree API call करतो (Secret Key वापरून)
    // Step 3: Backend आपल्याला orderId + paymentSessionId परत देतो
    final response = await dio.post(
      ApiConstants.subscriptionCreate,
      data: {'planId': planId},
    );
    // Backend response: { success: true, data: { orderId, paymentSessionId } }
    return (response.data['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<AccountModel> getProfile() async {
    final response = await dio.get(ApiConstants.userProfile);
    return AccountModel.fromJson(_unwrap(response));
  }

  @override
  Future<AccountModel> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? profileImagePath,
  }) async {
    final formData = FormData.fromMap({
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': ?phoneNumber,
      if (profileImagePath != null)
        'profileImage': await MultipartFile.fromFile(profileImagePath),
    });
    final response = await dio.put(
      ApiConstants.userProfile,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return AccountModel.fromJson(_unwrap(response));
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await dio.delete(ApiConstants.userById(userId));
  }

  @override
  Future<UserPreferencesModel> getPreferences() async {
    final response = await dio.get(ApiConstants.preferences);
    return UserPreferencesModel.fromJson(_unwrap(response));
  }

  @override
  Future<UserPreferencesModel> updatePreferences({
    required bool enableFollowUpQuestions,
  }) async {
    final response = await dio.put(
      ApiConstants.preferences,
      data: {'enableFollowUpQuestions': enableFollowUpQuestions},
    );
    return UserPreferencesModel.fromJson(_unwrap(response));
  }

  @override
  Future<PaginatedResult<ArchivedChatModel>> getArchivedChats() async {
    final response = await dio.get(
      ApiConstants.chats,
      queryParameters: {'isArchived': 'true'},
    );
    return _paginated(_unwrap(response), ArchivedChatModel.fromJson);
  }

  @override
  Future<void> unarchiveChat(String chatId) async {
    await dio.patch(ApiConstants.chatArchive(chatId));
  }
}
