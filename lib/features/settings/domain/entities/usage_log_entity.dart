import 'package:equatable/equatable.dart';

export 'paginated_result.dart';

class UsageModelRef extends Equatable {
  final int id;
  final String name;

  const UsageModelRef({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class UsageLogGroupEntity extends Equatable {
  final String id;
  final String capability;
  final DateTime createdAt;
  final List<UsageModelRef> models;
  final int billablePromptTokens;
  final int billableCompletionTokens;
  final int billableTotalTokens;
  final List<UsageSubLogEntity> subLogs;

  const UsageLogGroupEntity({
    required this.id,
    required this.capability,
    required this.createdAt,
    required this.models,
    required this.billablePromptTokens,
    required this.billableCompletionTokens,
    required this.billableTotalTokens,
    required this.subLogs,
  });

  @override
  List<Object?> get props => [
        id,
        capability,
        createdAt,
        models,
        billablePromptTokens,
        billableCompletionTokens,
        billableTotalTokens,
        subLogs,
      ];
}

class UsageSubLogEntity extends Equatable {
  final UsageModelRef? model;
  final int billablePromptTokens;
  final int billableCompletionTokens;
  final int billableTotalTokens;

  const UsageSubLogEntity({
    required this.billablePromptTokens,
    required this.billableCompletionTokens,
    required this.billableTotalTokens,
    this.model,
  });

  @override
  List<Object?> get props => [
        model,
        billablePromptTokens,
        billableCompletionTokens,
        billableTotalTokens,
      ];
}

class DailyModelUsageEntity extends Equatable {
  final String day;
  final String modelName;
  final int tokens;

  const DailyModelUsageEntity({
    required this.day,
    required this.modelName,
    required this.tokens,
  });

  @override
  List<Object?> get props => [day, modelName, tokens];
}
