part of 'subscription_bloc.dart';

abstract class SubscriptionEvent {}

class SubscriptionLoadRequested extends SubscriptionEvent {}

class SubscriptionCancelRequested extends SubscriptionEvent {}

/// User ने plan card वर tap केल्यावर हा event fire होतो
/// [planId] - कोणता plan निवडला
class SubscriptionPurchaseRequested extends SubscriptionEvent {
  final int planId;
  SubscriptionPurchaseRequested(this.planId);
}

/// Cashfree SDK ने success callback दिल्यावर
/// [orderData] - Cashfree कडून आलेला order info
class SubscriptionPaymentSuccess extends SubscriptionEvent {
  final Map<dynamic, dynamic> orderData;
  SubscriptionPaymentSuccess(this.orderData);
}

/// Cashfree SDK ने failure callback दिल्यावर
/// [orderData] - error info
class SubscriptionPaymentFailure extends SubscriptionEvent {
  final Map<dynamic, dynamic> orderData;
  SubscriptionPaymentFailure(this.orderData);
}
