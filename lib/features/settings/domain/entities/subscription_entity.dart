import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final int id;
  final String name;
  final num monthlyPrice;
  final int tokenLimit;
  final Map<String, dynamic>? features;
  final bool isActive;

  const PlanEntity({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.tokenLimit,
    required this.isActive,
    this.features,
  });

  @override
  List<Object?> get props =>
      [id, name, monthlyPrice, tokenLimit, features, isActive];
}

class SubscriptionEntity extends Equatable {
  final int id;
  final int planId;
  final String status;
  final String billingCycle;
  final bool autoRenew;
  final DateTime? expiresAt;
  final PlanEntity? plan;

  const SubscriptionEntity({
    required this.id,
    required this.planId,
    required this.status,
    required this.billingCycle,
    required this.autoRenew,
    this.expiresAt,
    this.plan,
  });

  @override
  List<Object?> get props =>
      [id, planId, status, billingCycle, autoRenew, expiresAt, plan];
}

class SubscriptionSummaryEntity extends Equatable {
  final SubscriptionEntity? subscription;
  final bool freePlanTaken;

  const SubscriptionSummaryEntity({
    required this.subscription,
    required this.freePlanTaken,
  });

  @override
  List<Object?> get props => [subscription, freePlanTaken];
}
