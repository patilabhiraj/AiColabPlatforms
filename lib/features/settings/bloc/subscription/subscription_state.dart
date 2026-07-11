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

  SubscriptionLoaded({
    required this.summary,
    required this.plans,
    this.cancelling = false,
    this.cancelError,
  });

  SubscriptionLoaded copyWith({
    SubscriptionSummaryEntity? summary,
    List<PlanEntity>? plans,
    bool? cancelling,
    String? cancelError,
  }) {
    return SubscriptionLoaded(
      summary: summary ?? this.summary,
      plans: plans ?? this.plans,
      cancelling: cancelling ?? this.cancelling,
      cancelError: cancelError,
    );
  }
}
