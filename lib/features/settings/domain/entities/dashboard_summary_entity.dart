import 'package:equatable/equatable.dart';
import 'subscription_entity.dart';
import 'usage_log_entity.dart';
import 'wallet_entity.dart';

class DashboardSummaryEntity extends Equatable {
  final WalletEntity? wallet;
  final SubscriptionEntity? subscription;
  final List<DailyModelUsageEntity> dailyByModel;
  final int chartDays;

  const DashboardSummaryEntity({
    required this.wallet,
    required this.subscription,
    required this.dailyByModel,
    required this.chartDays,
  });

  @override
  List<Object?> get props => [wallet, subscription, dailyByModel, chartDays];
}
