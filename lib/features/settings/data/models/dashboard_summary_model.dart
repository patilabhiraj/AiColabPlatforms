import '../../domain/entities/dashboard_summary_entity.dart';
import 'json_parsing.dart';
import 'subscription_model.dart';
import 'usage_log_model.dart';
import 'wallet_model.dart';

class DashboardSummaryModel extends DashboardSummaryEntity {
  const DashboardSummaryModel({
    required super.wallet,
    required super.subscription,
    required super.dailyByModel,
    required super.chartDays,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawWallet = json['wallet'];
    final rawSubscription = json['subscription'];
    final rawDaily = (json['dailyByModel'] as List?) ?? const [];

    // subscription block here is the nested summary shape:
    // { subscription: {...}, pendingSubscription, freePlanTaken, ... }
    final innerSub = rawSubscription is Map<String, dynamic>
        ? rawSubscription['subscription']
        : null;

    return DashboardSummaryModel(
      wallet: rawWallet is Map<String, dynamic>
          ? WalletModel.fromJson(rawWallet)
          : null,
      subscription: innerSub is Map<String, dynamic>
          ? SubscriptionModel.fromJson(innerSub)
          : null,
      dailyByModel: rawDaily
          .whereType<Map<String, dynamic>>()
          .map(DailyModelUsageModel.fromJson)
          .toList(),
      chartDays: parseInt(json['chartDays'], 30),
    );
  }
}
