import '../../domain/entities/paginated_conversations.dart';
import 'chat_conversation_model.dart';

/// Data-layer mapping for a page of conversations.
///
/// Backend list response shape (same as the web frontend consumes):
///   { status, message, data: { data: [ ...chats ], hasNextPage, page } }
class PaginatedConversationsModel extends PaginatedConversations {
  const PaginatedConversationsModel({
    required super.conversations,
    required super.hasNextPage,
    required super.page,
  });

  factory PaginatedConversationsModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedPage,
  }) {
    // Unwrap the `{status, data, message}` envelope; the paged payload lives in
    // `data` and holds `data` (the list) + `hasNextPage`.
    final envelope = json['data'];
    final payload = envelope is Map<String, dynamic> ? envelope : json;

    final rawList = payload['data'];
    final list = rawList is List
        ? rawList
            .whereType<Map<String, dynamic>>()
            .map(ChatConversationModel.fromJson)
            .toList()
        : <ChatConversationModel>[];

    return PaginatedConversationsModel(
      conversations: list,
      hasNextPage: payload['hasNextPage'] == true,
      page: (payload['page'] as num?)?.toInt() ?? requestedPage,
    );
  }
}
