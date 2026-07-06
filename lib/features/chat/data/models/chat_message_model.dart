import 'dart:convert';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/model_response.dart';

/// Data-layer mapping for a single chat message as returned by the backend
/// inside the chat-detail response (`GET /api/chats/{id}` → `data.messages[]`).
///
/// Shape mirrors the web frontend (`app/(chat)/c/[id]/page.tsx`):
///   { id, role: "USER" | "ASSISTANT", content, createdAt,
///     modelResponses: [ { id, model: {id, name, externalId},
///                         content, status, isLiked, isStarred } ] }
///
/// Important: for ASSISTANT messages the answer text lives in
/// `modelResponses[].content`, NOT in the top-level `content`. The web reads the
/// first model response for single-model messages, so we do the same.
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
    super.modelName,
    super.suggestedQuestions,
    super.isStarred,
    super.isLiked,
    super.modelResponses,
    super.activeModelId,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['_id'] ?? json['id'];
    final String id = idValue != null ? idValue.toString() : '';

    // Backend roles are uppercase ("USER" / "ASSISTANT"); compare loosely so
    // history messages don't all collapse into one side.
    final role = (json['role'] ?? json['sender'] ?? '').toString().toUpperCase();
    final isUser = role == 'USER' || role == 'HUMAN';

    final timestamp =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();

    // Parse per-model responses (present on assistant messages).
    final rawResponses = json['modelResponses'];
    final responses = <ModelResponse>[];
    if (rawResponses is List) {
      for (final r in rawResponses) {
        if (r is Map<String, dynamic>) {
          responses.add(_modelResponseFromJson(r));
        }
      }
    }

    if (isUser) {
      return ChatMessageModel(
        id: id,
        content: json['content']?.toString() ?? '',
        isUser: true,
        timestamp: timestamp,
      );
    }

    // ── Assistant message ────────────────────────────────────────────────────
    // Single-model: flatten the one response into [content] so it renders like a
    // normal bubble. Multi-model: keep the [modelResponses] tabs.
    if (responses.length <= 1) {
      final only = responses.isNotEmpty ? responses.first : null;
      final rawText = only?.content.isNotEmpty == true
          ? only!.content
          : (json['content']?.toString() ?? '');

      // History messages carry the follow-up questions as a trailing JSON array
      // inside the content (same as live streaming). Extract them into
      // [suggestedQuestions] and strip them from the displayed text — mirrors
      // the web's parseFollowUpQuestions at render time.
      final parsed = _parseFollowUpQuestions(rawText);
      final explicitQuestions = _parseQuestions(json['suggestedQuestions']);

      return ChatMessageModel(
        id: id,
        content: parsed.cleanText,
        isUser: false,
        timestamp: timestamp,
        modelName: only?.modelName ??
            (json['model'] as String?) ??
            (json['modelName'] as String?),
        isLiked: only != null ? _likedForResponse(rawResponses, 0) : null,
        isStarred: only != null && _starredForResponse(rawResponses, 0),
        suggestedQuestions:
            explicitQuestions ?? (parsed.questions.isNotEmpty ? parsed.questions : null),
      );
    }

    // Multi-model: strip follow-up arrays from each response's content too.
    final cleaned = responses
        .map((r) => r.copyWith(content: _parseFollowUpQuestions(r.content).cleanText))
        .toList();
    return ChatMessageModel(
      id: id,
      content: '',
      isUser: false,
      timestamp: timestamp,
      modelResponses: cleaned,
      activeModelId: cleaned.first.modelId,
    );
  }

  /// Extracts a trailing JSON array of follow-up questions from [text] and
  /// returns the cleaned text alongside the questions. Ported from the web
  /// frontend's `parseFollowUpQuestions` (message-bubble.tsx).
  static ({String cleanText, List<String> questions}) _parseFollowUpQuestions(
    String text,
  ) {
    if (text.isEmpty) return (cleanText: '', questions: const []);

    final arrayPattern = RegExp(
      r'(?:```(?:json)?\s*)?(\[\s*"(?:[^"\\]|\\.)*"(?:\s*,\s*"(?:[^"\\]|\\.)*")*\s*\])(?:\s*```)?',
      caseSensitive: false,
    );

    final matches = arrayPattern.allMatches(text).toList();
    if (matches.isNotEmpty) {
      final last = matches.last;
      final jsonContent = last.group(1)!;

      // Only treat it as follow-ups if nothing meaningful follows the array.
      final trailing = text.substring(last.end);
      final atEnd = RegExp(r'^(\s|\[\d+\]|,|\.|-|`)*$').hasMatch(trailing);

      if (atEnd) {
        try {
          final decoded = jsonDecode(jsonContent);
          if (decoded is List) {
            final questions = decoded
                .whereType<String>()
                .take(4)
                .toList();
            if (questions.isNotEmpty) {
              final clean = (text.substring(0, last.start) +
                      text.substring(last.end))
                  .replaceAll(RegExp(r'[\s`\-]+$'), '');
              return (cleanText: clean, questions: questions);
            }
          }
        } catch (_) {
          // Malformed JSON — fall through to returning the text untouched.
        }
      }
    }

    return (
      cleanText: text.replaceAll(RegExp(r'[\s`\-]+$'), ''),
      questions: const [],
    );
  }

  static ModelResponse _modelResponseFromJson(Map<String, dynamic> json) {
    final model = json['model'];
    int modelId = 0;
    String modelName = 'AI';
    String externalId = '';
    if (model is Map<String, dynamic>) {
      modelId = (model['id'] as num?)?.toInt() ?? 0;
      modelName = model['name']?.toString() ?? 'AI';
      externalId = model['externalId']?.toString() ?? '';
    }
    return ModelResponse(
      modelId: modelId,
      modelName: modelName,
      externalId: externalId,
      content: json['content']?.toString() ?? '',
      status: _statusFromString(json['status']?.toString()),
    );
  }

  static ModelResponseStatus _statusFromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'FAILED':
        return ModelResponseStatus.failed;
      case 'STREAMING':
        return ModelResponseStatus.streaming;
      case 'COMPLETED':
      default:
        return ModelResponseStatus.completed;
    }
  }

  static List<String>? _parseQuestions(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  /// isLiked for the i-th response: null = no feedback, true/false = like/dislike.
  static bool? _likedForResponse(dynamic responses, int index) {
    if (responses is List && index < responses.length) {
      final r = responses[index];
      if (r is Map<String, dynamic> && r['isLiked'] is bool) {
        return r['isLiked'] as bool;
      }
    }
    return null;
  }

  static bool _starredForResponse(dynamic responses, int index) {
    if (responses is List && index < responses.length) {
      final r = responses[index];
      if (r is Map<String, dynamic>) {
        return r['isStarred'] == true;
      }
    }
    return false;
  }
}
