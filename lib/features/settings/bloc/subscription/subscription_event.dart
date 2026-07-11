part of 'subscription_bloc.dart';

abstract class SubscriptionEvent {}

class SubscriptionLoadRequested extends SubscriptionEvent {}

class SubscriptionCancelRequested extends SubscriptionEvent {}
