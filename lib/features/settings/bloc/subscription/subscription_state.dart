part of 'subscription_bloc.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionSummaryEntity summary;
  final List<PlanEntity> plans;
  final bool cancelling;
  final String? cancelError;
  // Payment flow साठी नवीन fields
  final bool paymentInitiating; // Order create होतोय
  final int? purchasingPlanId;  // कोणत्या plan साठी payment चालू आहे

  SubscriptionLoaded({
    required this.summary,
    required this.plans,
    this.cancelling = false,
    this.cancelError,
    this.paymentInitiating = false,
    this.purchasingPlanId,
  });

  SubscriptionLoaded copyWith({
    SubscriptionSummaryEntity? summary,
    List<PlanEntity>? plans,
    bool? cancelling,
    String? cancelError,
    bool? paymentInitiating,
    int? purchasingPlanId,
  }) {
    return SubscriptionLoaded(
      summary: summary ?? this.summary,
      plans: plans ?? this.plans,
      cancelling: cancelling ?? this.cancelling,
      cancelError: cancelError,
      paymentInitiating: paymentInitiating ?? this.paymentInitiating,
      purchasingPlanId: purchasingPlanId ?? this.purchasingPlanId,
    );
  }
}

/// Payment SDK launch होतोय — backend कडून session ID मिळाला,
/// आता Cashfree payment sheet उघडणार
class PaymentInitiating extends SubscriptionState {}

/// ✅ Payment successful! Subscription activate झाली
class PaymentSuccess extends SubscriptionState {
  final String orderId;
  PaymentSuccess(this.orderId);
}

/// ❌ Payment failed किंवा user ने cancel केली
class PaymentFailure extends SubscriptionState {
  final String message;
  PaymentFailure(this.message);
}
