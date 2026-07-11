import '../../domain/entities/subscription_entity.dart';
import 'json_parsing.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.name,
    required super.monthlyPrice,
    required super.tokenLimit,
    required super.isActive,
    super.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      monthlyPrice: parseNum(json['monthlyPrice']),
      tokenLimit: parseInt(json['tokenLimit']),
      isActive: json['isActive'] != false,
      features: json['features'] is Map<String, dynamic>
          ? json['features'] as Map<String, dynamic>
          : null,
    );
  }
}

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.planId,
    required super.status,
    required super.billingCycle,
    required super.autoRenew,
    super.expiresAt,
    super.plan,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: parseInt(json['id']),
      planId: parseInt(json['planId']),
      status: json['status']?.toString() ?? '',
      billingCycle: json['billingCycle']?.toString() ?? 'MONTHLY',
      autoRenew: json['autoRenew'] == true,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      plan: json['plan'] is Map<String, dynamic>
          ? PlanModel.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SubscriptionSummaryModel extends SubscriptionSummaryEntity {
  const SubscriptionSummaryModel({
    required super.subscription,
    required super.freePlanTaken,
  });

  factory SubscriptionSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawSub = json['subscription'];
    return SubscriptionSummaryModel(
      subscription: rawSub is Map<String, dynamic>
          ? SubscriptionModel.fromJson(rawSub)
          : null,
      freePlanTaken: json['freePlanTaken'] == true,
    );
  }
}
