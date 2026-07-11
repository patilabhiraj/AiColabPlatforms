part of 'usage_bloc.dart';

abstract class UsageState {}

class UsageInitial extends UsageState {}

class UsageLoading extends UsageState {}

class UsageError extends UsageState {
  final String message;
  UsageError(this.message);
}

class UsageLoaded extends UsageState {
  final List<UsageLogGroupEntity> logs;
  final bool loading;
  final int page;
  final int totalPages;
  final int totalRecords;

  UsageLoaded({
    required this.logs,
    required this.page,
    required this.totalPages,
    required this.totalRecords,
    this.loading = false,
  });

  UsageLoaded copyWith({
    List<UsageLogGroupEntity>? logs,
    bool? loading,
    int? page,
    int? totalPages,
    int? totalRecords,
  }) {
    return UsageLoaded(
      logs: logs ?? this.logs,
      loading: loading ?? this.loading,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
    );
  }
}
