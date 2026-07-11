part of 'usage_bloc.dart';

abstract class UsageEvent {}

class UsageLoadRequested extends UsageEvent {
  final String userId;
  UsageLoadRequested({required this.userId});
}

class UsagePageRequested extends UsageEvent {
  final int page;
  UsagePageRequested({required this.page});
}
