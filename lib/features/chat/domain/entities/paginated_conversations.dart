import 'package:equatable/equatable.dart';

import 'chat_conversation.dart';

/// One page of conversations plus whether more pages exist.
///
/// Mirrors the backend list response `{ data: [...], hasNextPage }` used by the
/// web frontend for its "Load More Chats" pagination.
class PaginatedConversations extends Equatable {
  final List<ChatConversation> conversations;
  final bool hasNextPage;
  final int page;

  const PaginatedConversations({
    required this.conversations,
    required this.hasNextPage,
    required this.page,
  });

  @override
  List<Object?> get props => [conversations, hasNextPage, page];
}
