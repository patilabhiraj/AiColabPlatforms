/// Result of `POST /chats/{id}/prepare-multi` — the persisted user + assistant
/// message ids that all per-model streams then share.
class PrepareMultiResult {
  final int userMessageId;
  final int assistantMessageId;

  const PrepareMultiResult({
    required this.userMessageId,
    required this.assistantMessageId,
  });
}

/// A streamed chunk tagged with the model it belongs to, so the bloc can route
/// tokens to the right per-model response in multi-model mode.
class ModelStreamChunk {
  final int modelId;
  final String content;

  const ModelStreamChunk({required this.modelId, required this.content});
}
