import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_context.dart';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';
import '../entities/shared_chat.dart';

abstract class ChatRepository {
  // Legacy methods (keeping for backward compatibility)
  Future<Either<Failure, List<ChatConversation>>> getConversations();
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content);
  Future<Either<Failure, ChatConversation>> createConversation(String firstMessage);
  
  // Streaming method for real-time responses
  Stream<Either<Failure, String>> sendMessageStream(String conversationId, String content);
  
  // New API methods
  /// GET /api/chats - List all chats
  Future<Either<Failure, List<ChatConversation>>> listChats();
  
  /// POST /api/chats - Create new chat
  Future<Either<Failure, ChatConversation>> createChat(String title);
  
  /// GET /api/chats/{id} - Get chat by ID
  Future<Either<Failure, ChatConversation>> getChatById(String id);
  
  /// PUT /api/chats/{id} - Update chat
  Future<Either<Failure, ChatConversation>> updateChat(String id, String title);
  
  /// DELETE /api/chats/{id} - Delete chat
  Future<Either<Failure, void>> deleteChat(String id);
  
  /// GET /api/chats/{id}/contexts - Get chat contexts
  Future<Either<Failure, List<ChatContext>>> getChatContexts(String id);
  
  /// PUT /api/chats/{id}/contexts - Replace chat contexts
  Future<Either<Failure, void>> replaceChatContexts(String id, List<ChatContext> contexts);
  
  /// GET /api/chats/shared/{shareId} - Get shared chat
  Future<Either<Failure, SharedChat>> getSharedChat(String shareId);
}
