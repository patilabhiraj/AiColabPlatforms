import '../../domain/entities/usage_log_entity.dart';
import 'json_parsing.dart';

UsageModelRef? _parseModelRef(dynamic json) {
  if (json is! Map<String, dynamic>) return null;
  return UsageModelRef(
    id: parseInt(json['id']),
    name: json['name']?.toString() ?? 'Unknown',
  );
}

class UsageLogGroupModel extends UsageLogGroupEntity {
  const UsageLogGroupModel({
    required super.id,
    required super.capability,
    required super.createdAt,
    required super.models,
    required super.billablePromptTokens,
    required super.billableCompletionTokens,
    required super.billableTotalTokens,
    required super.subLogs,
  });

  factory UsageLogGroupModel.fromJson(Map<String, dynamic> json) {
    final rawModels = (json['models'] as List?) ?? const [];
    final rawSubLogs = (json['subLogs'] as List?) ?? const [];

    return UsageLogGroupModel(
      id: json['id']?.toString() ?? '',
      capability: json['capability']?.toString() ?? 'STANDARD',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      models: rawModels
          .whereType<Map<String, dynamic>>()
          .map((m) => _parseModelRef(m))
          .whereType<UsageModelRef>()
          .toList(),
      billablePromptTokens: parseInt(json['billablePromptTokens']),
      billableCompletionTokens: parseInt(json['billableCompletionTokens']),
      billableTotalTokens: parseInt(json['billableTotalTokens']),
      subLogs: rawSubLogs
          .whereType<Map<String, dynamic>>()
          .map(UsageSubLogModel.fromJson)
          .toList(),
    );
  }
}

class UsageSubLogModel extends UsageSubLogEntity {
  const UsageSubLogModel({
    required super.billablePromptTokens,
    required super.billableCompletionTokens,
    required super.billableTotalTokens,
    super.model,
  });

  factory UsageSubLogModel.fromJson(Map<String, dynamic> json) {
    return UsageSubLogModel(
      model: _parseModelRef(json['model']),
      billablePromptTokens: parseInt(json['billablePromptTokens']),
      billableCompletionTokens: parseInt(json['billableCompletionTokens']),
      billableTotalTokens: parseInt(json['billableTotalTokens']),
    );
  }
}

class DailyModelUsageModel extends DailyModelUsageEntity {
  const DailyModelUsageModel({
    required super.day,
    required super.modelName,
    required super.tokens,
  });

  factory DailyModelUsageModel.fromJson(Map<String, dynamic> json) {
    return DailyModelUsageModel(
      day: json['day']?.toString() ?? '',
      modelName: json['modelName']?.toString() ?? 'Unknown',
      tokens: parseInt(json['tokens']),
    );
  }
}
