import 'package:equatable/equatable.dart';

/// Status of a single model's response within a multi-model assistant message.
enum ModelResponseStatus { streaming, completed, failed }

/// One model's answer inside an assistant message.
///
/// In multi-model mode a single assistant message holds several of these — one
/// per selected model — and the UI shows them as switchable tabs (mirrors the
/// web frontend's `modelResponses`).
class ModelResponse extends Equatable {
  /// The model's id (matches [AiModel.id]).
  final int modelId;

  /// Display name, e.g. "GPT-5.4".
  final String modelName;

  /// External id used for icon/colour lookup (e.g. "gpt-5.4").
  final String externalId;

  /// Streamed content so far.
  final String content;

  final ModelResponseStatus status;

  /// Follow-up questions for this specific model's answer, parsed out of the
  /// trailing JSON array the model emits. Empty when there are none.
  final List<String> suggestedQuestions;

  const ModelResponse({
    required this.modelId,
    required this.modelName,
    this.externalId = '',
    this.content = '',
    this.status = ModelResponseStatus.streaming,
    this.suggestedQuestions = const [],
  });

  ModelResponse copyWith({
    int? modelId,
    String? modelName,
    String? externalId,
    String? content,
    ModelResponseStatus? status,
    List<String>? suggestedQuestions,
  }) {
    return ModelResponse(
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      externalId: externalId ?? this.externalId,
      content: content ?? this.content,
      status: status ?? this.status,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
    );
  }

  @override
  List<Object?> get props => [
    modelId,
    modelName,
    externalId,
    content,
    status,
    suggestedQuestions,
  ];
}
