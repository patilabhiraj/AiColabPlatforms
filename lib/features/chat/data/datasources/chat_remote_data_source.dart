import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/ai_model_model.dart';
import '../models/assistant_model.dart';
import '../models/chat_context_model.dart';
import '../models/chat_conversation_model.dart';
import '../../domain/entities/multi_model.dart';
import '../models/chat_message_model.dart';
import '../models/paginated_conversations_model.dart';
import '../models/shared_chat_model.dart';
import '../models/user_context_model.dart';

abstract class ChatRemoteDataSource {
  // ── Core chat ─────────────────────────────────────────────────────────────
  Future<List<ChatConversationModel>> getConversations();

  /// Fetches one page of conversations. Returns the items plus whether a next
  /// page exists (backend `{ data: [...], hasNextPage }`).
  Future<PaginatedConversationsModel> getConversationsPage({
    required int page,
    int pageSize,
  });
  Future<List<ChatMessageModel>> getMessages(String conversationId);
  Future<ChatMessageModel> sendMessage(String conversationId, String content);
  Future<ChatConversationModel> createConversation(
    String firstMessage, {
    List<int>? modelIds,
    String? capability,
    int? assistantId,
  });
  Stream<String> sendMessageStream(String conversationId, String content);

  // ── Multi-model send ──────────────────────────────────────────────────────
  /// Persists the user message + a shared assistant message, returning their
  /// ids. Call before fanning out one [sendMessageStreamForModel] per model.
  Future<PrepareMultiResult> prepareMulti(String conversationId, String content);

  /// Streams a single model's answer for [modelId]. When [userMessageId] /
  /// [assistantMessageId] are non-zero the backend appends to those shared
  /// messages (multi-model); pass 0 for a plain single-model send.
  Stream<ModelStreamChunk> sendMessageStreamForModel(
    String conversationId,
    String content,
    int modelId, {
    int userMessageId = 0,
    int assistantMessageId = 0,
  });

  // ── Catalog (models & assistants) ─────────────────────────────────────────
  Future<List<AiModelModel>> getModels();
  Future<List<AssistantModel>> getAssistants();

  // ── Chat CRUD ─────────────────────────────────────────────────────────────
  Future<List<ChatConversationModel>> listChats();
  Future<ChatConversationModel> createChat(String title);
  Future<ChatConversationModel> getChatById(String id);
  Future<ChatConversationModel> updateChat(String id, String title);
  Future<void> deleteChat(String id);

  // ── Chat state toggles ────────────────────────────────────────────────────
  Future<ChatConversationModel> archiveChat(String id);
  Future<ChatConversationModel> pinChat(String id);
  Future<ChatConversationModel> shareChat(String id);

  // ── Chat contexts ─────────────────────────────────────────────────────────
  Future<List<ChatContextModel>> getChatContexts(String id);
  Future<void> replaceChatContexts(String id, List<ChatContextModel> contexts);

  // ── Message actions ───────────────────────────────────────────────────────
  /// Rewrites [prompt] into a clearer, more detailed version via
  /// `POST /api/messages/enhance`. Returns the enhanced prompt text.
  Future<String> enhancePrompt(String prompt);

  // ── Message actions (streaming) ───────────────────────────────────────────
  Stream<String> regenerateMessage(String chatId, String messageId);
  Stream<String> editMessage(String chatId, String messageId, String newContent);
  Stream<String> continueChat(String chatId);

  // ── Feedback ──────────────────────────────────────────────────────────────
  Future<void> submitFeedback(String chatId, String responseId, bool isPositive, {String? comment});

  // ── Shared chat ───────────────────────────────────────────────────────────
  Future<SharedChatModel> getSharedChat(String shareId);

  // ── User Contexts ─────────────────────────────────────────────────────────
  Future<List<UserContextModel>> getSidebarContexts();
  Future<List<UserContextModel>> listContexts();
  Future<UserContextModel> createContext(String name, String content, String role);
  Future<UserContextModel> getContextById(String id);
  Future<UserContextModel> updateContext(String id, String name, String content, String role);
  Future<void> deleteContext(String id);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final response = await dio.get(ApiConstants.chats);

      if (response.statusCode == 200) {
        final data = _parseListResponse(response.data);
        return data
            .map((json) => ChatConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch conversations',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<PaginatedConversationsModel> getConversationsPage({
    required int page,
    int pageSize = 5,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.chats,
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
          'isArchived': 'false',
        },
      );

      if (response.statusCode == 200) {
        return PaginatedConversationsModel.fromJson(
          response.data as Map<String, dynamic>,
          requestedPage: page,
        );
      }
      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch conversations',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data is Map
            ? (e.response?.data['message'] ?? 'Server error occurred')
            : (e.message ?? 'Network error occurred'),
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    try {
      // The backend has no dedicated /messages route (returns 404); messages
      // are embedded in the chat-detail response at GET /api/chats/{id}.
      final response = await dio.get(
        ApiConstants.chatById(conversationId),
      );

      if (response.statusCode == 200) {
        final data = _parseMessagesFromChat(response.data);
        return data
            .map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch messages',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(String conversationId, String content) async {
    try {
      // Send message with SSE response type
      final response = await dio.post(
        ApiConstants.chatSend(conversationId),
        data: {'content': content},
        options: Options(
          responseType: ResponseType.plain, // Get plain text for SSE parsing
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse SSE response
        final String responseText = response.data as String;
        logger.debug('SSE Response: $responseText');
        
        // Extract message IDs and content from SSE stream
        String? assistantMessageId;
        final StringBuffer contentBuffer = StringBuffer();
        
        // Parse SSE events
        final lines = responseText.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6); // Remove 'data: ' prefix
            
            if (dataStr == '[DONE]') {
              break;
            }
            
            try {
              final data = jsonDecode(dataStr) as Map<String, dynamic>;
              final type = data['type'] as String?;
              
              if (type == 'message_id') {
                assistantMessageId = data['assistantMessageId']?.toString();
              } else if (type == 'token') {
                final tokenContent = data['content'] as String?;
                if (tokenContent != null) {
                  contentBuffer.write(tokenContent);
                }
              }
            } catch (e) {
              logger.debug('Failed to parse SSE line: $dataStr');
            }
          }
        }
        
        String fullContent = contentBuffer.toString();
        logger.info('Received AI response: $fullContent');
        
        // Clean up the content - remove ***json blocks and *** markers
        fullContent = _cleanResponseContent(fullContent);
        
        // Create message model from parsed data
        return ChatMessageModel(
          id: assistantMessageId ?? 'ai_${DateTime.now().millisecondsSinceEpoch}',
          content: fullContent,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw ServerException(
          message: 'Failed to send message',
        );
      }
    } on DioException catch (e) {
      logger.error('DioException in sendMessage', e);
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      logger.error('Unexpected error in sendMessage', e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

@override
Stream<String> sendMessageStream(String conversationId, String content) async* {
  try {
    logger.info('Starting streaming message to conversation: $conversationId');

    final response = await dio.post(
      ApiConstants.chatSend(conversationId),
      data: {'content': content},
      options: Options(
        responseType: ResponseType.stream,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final stream = (response.data as ResponseBody).stream;
      final StringBuffer contentBuffer = StringBuffer();
      String? messageId;
      // Buffer for incomplete SSE lines split across network chunks
      String partialLine = '';

      final textStream = stream.cast<List<int>>().transform(utf8.decoder);

      await for (final chunk in textStream) {
        final combined = partialLine + chunk;
        final lines = combined.split('\n');
        partialLine = lines.removeLast(); // last entry may be incomplete

        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final dataStr = line.substring(6).trim();

          if (dataStr == '[DONE]') {
            logger.info('Stream complete');
            return;
          }

          try {
            final data = jsonDecode(dataStr) as Map<String, dynamic>;
            final type = data['type'] as String?;

            if (type == 'message_id') {
              messageId = data['assistantMessageId']?.toString();
              logger.debug('Received message ID: $messageId');
            } else if (type == 'token') {
              final token = data['content'] as String?;
              if (token != null) {
                contentBuffer.write(token);
                yield contentBuffer.toString();
              }
            }
          } catch (e) {
            logger.debug('Failed to parse SSE line: $dataStr');
          }
        }
      }

      // Process any remaining buffered line after stream ends
      if (partialLine.startsWith('data: ')) {
        final dataStr = partialLine.substring(6).trim();
        if (dataStr != '[DONE]') {
          try {
            final data = jsonDecode(dataStr) as Map<String, dynamic>;
            if (data['type'] == 'token') {
              final token = data['content'] as String?;
              if (token != null) contentBuffer.write(token);
            }
          } catch (_) {}
        }
      }

      // Final cleanup yield if content was modified
      final finalContent = _cleanResponseContent(contentBuffer.toString());
      if (finalContent != contentBuffer.toString()) {
        yield finalContent;
      }

    } else {
      throw ServerException(message: 'Failed to send message');
    }
  } on DioException catch (e) {
    logger.error('DioException in sendMessageStream', e);
    throw ServerException(
      message: e.response?.data['message'] ?? 'Server error occurred',
    );
  } catch (e) {
    logger.error('Unexpected error in sendMessageStream', e);
    throw ServerException(message: 'Unexpected error: $e');
  }
}

  // ── Multi-model send ──────────────────────────────────────────────────────

  @override
  Future<PrepareMultiResult> prepareMulti(
    String conversationId,
    String content,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.chatPrepareMulti(conversationId),
        data: {'content': content},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        final data = (body['data'] ?? body) as Map<String, dynamic>;
        return PrepareMultiResult(
          userMessageId: (data['userMessageId'] as num?)?.toInt() ?? 0,
          assistantMessageId: (data['assistantMessageId'] as num?)?.toInt() ?? 0,
        );
      }
      throw ServerException(message: 'Failed to prepare messages');
    } on DioException catch (e) {
      logger.error('DioException in prepareMulti', e);
      throw ServerException(
        message: e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      logger.error('Unexpected error in prepareMulti', e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Stream<ModelStreamChunk> sendMessageStreamForModel(
    String conversationId,
    String content,
    int modelId, {
    int userMessageId = 0,
    int assistantMessageId = 0,
  }) async* {
    try {
      final response = await dio.post(
        ApiConstants.chatSend(conversationId),
        data: {
          'content': content,
          'modelId': modelId,
          if (userMessageId != 0) 'userMessageId': userMessageId,
          if (assistantMessageId != 0) 'assistantMessageId': assistantMessageId,
        },
        options: Options(responseType: ResponseType.stream),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(message: 'Failed to send message');
      }

      final stream = (response.data as ResponseBody).stream;
      final StringBuffer contentBuffer = StringBuffer();
      String partialLine = '';

      final textStream = stream.cast<List<int>>().transform(utf8.decoder);

      await for (final chunk in textStream) {
        final combined = partialLine + chunk;
        final lines = combined.split('\n');
        partialLine = lines.removeLast();

        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final dataStr = line.substring(6).trim();
          if (dataStr == '[DONE]') return;

          try {
            final data = jsonDecode(dataStr) as Map<String, dynamic>;
            final type = data['type'] as String?;
            if (type == 'token') {
              final token = data['content'] as String?;
              if (token != null) {
                contentBuffer.write(token);
                yield ModelStreamChunk(
                  modelId: modelId,
                  content: contentBuffer.toString(),
                );
              }
            } else if (type == 'error') {
              throw ServerException(
                message: data['message']?.toString() ?? 'Generation failed',
              );
            }
            // 'message_id' / 'done' carry no display content here.
          } catch (e) {
            if (e is ServerException) rethrow;
            logger.debug('Failed to parse SSE line: $dataStr');
          }
        }
      }
    } on DioException catch (e) {
      // With responseType: stream the error body is a ResponseBody, not a
      // decoded Map — reading e.response?.data['message'] fails and the real
      // server error is lost (logs show "Instance of 'ResponseBody'"). Drain
      // the stream and decode it so the actual 4xx message surfaces.
      final serverMessage = await _readStreamErrorMessage(e.response);
      logger.error(
        'DioException in sendMessageStreamForModel: $serverMessage',
        e,
      );
      throw ServerException(message: serverMessage ?? 'Server error occurred');
    } catch (e) {
      if (e is ServerException) rethrow;
      logger.error('Unexpected error in sendMessageStreamForModel', e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  /// Reads an error response whose body may be a streamed [ResponseBody]
  /// (because the request used [ResponseType.stream]) and extracts a human
  /// message from it. Returns null if nothing useful can be read.
  Future<String?> _readStreamErrorMessage(Response<dynamic>? response) async {
    if (response == null) return null;
    final data = response.data;

    String raw;
    if (data is ResponseBody) {
      try {
        final bytes = <int>[];
        await for (final chunk in data.stream) {
          bytes.addAll(chunk);
        }
        raw = utf8.decode(bytes, allowMalformed: true).trim();
      } catch (_) {
        return null;
      }
    } else if (data is String) {
      raw = data.trim();
    } else if (data is Map) {
      return (data['message'] ?? data['error'])?.toString();
    } else {
      return null;
    }

    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return (decoded['message'] ?? decoded['error'])?.toString() ?? raw;
      }
    } catch (_) {
      // Not JSON — fall back to the raw text.
    }
    return raw;
  }

  @override
  Future<ChatConversationModel> createConversation(
    String firstMessage, {
    List<int>? modelIds,
    String? capability,
    int? assistantId,
  }) async {
    try {
      final title = firstMessage.length > 40
          ? '${firstMessage.substring(0, 40)}...'
          : firstMessage;

      final response = await dio.post(
        ApiConstants.chats,
        data: {
          'title': title,
          if (modelIds != null && modelIds.isNotEmpty) 'modelIds': modelIds,
          'capability': ?capability,
          'assistantId': ?assistantId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatConversationModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create conversation',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  // ── Catalog (models & assistants) ─────────────────────────────────────────

  @override
  Future<List<AiModelModel>> getModels() async {
    try {
      final response = await dio.get(
        ApiConstants.models,
        queryParameters: {'pageSize': '100'},
      );
      if (response.statusCode == 200) {
        final data = _parseListResponse(response.data);
        return data
            .map((json) => AiModelModel.fromJson(json as Map<String, dynamic>))
            .where((m) => m.isActive)
            .toList();
      }
      throw ServerException(message: 'Failed to fetch models');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Network error')
          : (e.message ?? 'Network error'));
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<AssistantModel>> getAssistants() async {
    try {
      final response = await dio.get(
        ApiConstants.assistants,
        queryParameters: {'pageSize': '100'},
      );
      if (response.statusCode == 200) {
        final data = _parseListResponse(response.data);
        return data
            .map((json) => AssistantModel.fromJson(json as Map<String, dynamic>))
            .where((a) => a.isActive)
            .toList();
      }
      throw ServerException(message: 'Failed to fetch assistants');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Network error')
          : (e.message ?? 'Network error'));
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<SharedChatModel> getSharedChat(String shareId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.sharedChat}/$shareId',
      );

      if (response.statusCode == 200) {
        return SharedChatModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch shared chat',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<ChatConversationModel>> listChats() async {
    try {
      final response = await dio.get(ApiConstants.chats);

      if (response.statusCode == 200) {
        final data = _parseListResponse(response.data);
        return data
            .map((json) => ChatConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch chats',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ChatConversationModel> createChat(String title) async {
    try {
      final response = await dio.post(
        ApiConstants.chats,
        data: {'title': title},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatConversationModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create chat',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ChatConversationModel> getChatById(String id) async {
    try {
      final response = await dio.get(ApiConstants.chatById(id));

      if (response.statusCode == 200) {
        return ChatConversationModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch chat',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ChatConversationModel> updateChat(String id, String title) async {
    try {
      final response = await dio.put(
        ApiConstants.chatById(id),
        data: {'title': title},
      );

      if (response.statusCode == 200) {
        return ChatConversationModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update chat',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteChat(String id) async {
    try {
      final response = await dio.delete(ApiConstants.chatById(id));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete chat',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<ChatContextModel>> getChatContexts(String id) async {
    try {
      final response = await dio.get(ApiConstants.chatContexts(id));

      if (response.statusCode == 200) {
        final data = _parseListResponse(response.data);
        return data
            .map((json) => ChatContextModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch contexts',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> replaceChatContexts(String id, List<ChatContextModel> contexts) async {
    try {
      final response = await dio.put(
        ApiConstants.chatContexts(id),
        data: {
          'contexts': contexts.map((c) => c.toJson()).toList(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to replace contexts',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  /// Extracts the message list from a chat-detail response.
  ///
  /// The backend has no `/messages` route (returns 404); messages are embedded
  /// in `GET /api/chats/{id}`. The web frontend reads them from
  /// `res.data.data.messages` (see `app/(chat)/c/[id]/page.tsx`), so we unwrap
  /// the `{status, data, message}` envelope and read `data.messages`.
  List<dynamic> _parseMessagesFromChat(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid response format');
    }

    // Unwrap {status, data, message} — the chat object lives in `data`.
    final chat = responseData['data'];
    if (chat is! Map<String, dynamic>) return [];

    final messages = chat['messages'];
    return messages is List ? messages : [];
  }

  /// Parses API list responses that may be wrapped in pagination envelopes.
  /// Handles: direct list, {data:[...]}, {data:{data:[...]}}
  List<dynamic> _parseListResponse(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      final dataField = responseData['data'];
      if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
        return dataField['data'] as List<dynamic>? ?? [];
      }
      if (dataField is List) return dataField;
      return [];
    }
    throw ServerException(message: 'Invalid response format');
  }

  /// Clean response content by removing ***json blocks and *** markers
  /// Clean response content and extract suggested questions
  /// Returns a map with 'content' and 'questions' keys
Map<String, dynamic> _cleanResponseContentAndExtractQuestions(String content) {
  logger.debug('Original content length: ${content.length}');
  
  final originalContent = content;
  List<String> suggestedQuestions = [];

  // Step 1: Extract JSON arrays with questions before removing them
  final jsonArrayPattern = RegExp(r'\[\s*"([^"]*)"(?:\s*,\s*"([^"]*)")*\s*\]', multiLine: true);
  final matches = jsonArrayPattern.allMatches(content);
  
  for (final match in matches) {
    try {
      final jsonStr = match.group(0);
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          suggestedQuestions.addAll(decoded.map((e) => e.toString()));
        }
      }
    } catch (e) {
      logger.debug('Failed to parse JSON array: ${match.group(0)}');
    }
  }

  // Step 2: Remove ```json ... ``` blocks
  content = content.replaceAll(
    RegExp(r'```json[\s\S]*?```', multiLine: true),
    '',
  );
  
  // Step 3: Remove ***json ... *** blocks
  content = content.replaceAll(
    RegExp(r'\*\*\*json[\s\S]*?\*\*\*', multiLine: true),
    '',
  );
  
  // Step 4: Remove any remaining ``` code blocks
  content = content.replaceAll(
    RegExp(r'```[\s\S]*?```', multiLine: true),
    '',
  );
  
  // Step 5: Remove standalone JSON arrays
  content = content.replaceAll(
    RegExp(r'\[\s*"[^"]*"(?:\s*,\s*"[^"]*")*\s*\]', multiLine: true),
    '',
  );
  
  // Step 6: Remove lines that start with "***json" or end with "***"
  content = content.replaceAll(
    RegExp(r'^.*\*\*\*json.*$', multiLine: true),
    '',
  );
  content = content.replaceAll(
    RegExp(r'^.*\*\*\*\s*$', multiLine: true),
    '',
  );
  
  // Step 7: Remove SUGGESTIONS: lines and horizontal rules
  content = content.replaceAll(
    RegExp(r'SUGGESTIONS:.*', caseSensitive: false),
    '',
  );
  content = content.replaceAll(
    RegExp(r'Suggested follow-up questions:.*', caseSensitive: false),
    '',
  );
  content = content.replaceAll(
    RegExp(r'^Suggested.*questions.*$', caseSensitive: false, multiLine: true),
    '',
  );
  
  // Remove horizontal rules (---, ___, ***)
  content = content.replaceAll(RegExp(r'^[\-_\*]{3,}\s*$', multiLine: true), '');
  content = content.replaceAll(RegExp(r'^\s*[\-_]{3,}\s*$', multiLine: true), '');
  
  // Step 8: Remove emoji and special markers
  content = content.replaceAll(RegExp(r'│\s*💡\s*'), '');
  content = content.replaceAll(RegExp(r'💡\s*'), '');
  content = content.replaceAll(RegExp(r'│\s*'), '');
  content = content.replaceAll(RegExp(r'┃\s*'), '');
  content = content.replaceAll(RegExp(r'─+'), '');  // Remove horizontal lines
  
  // Step 9: Remove any remaining backticks and triple asterisks
  content = content.replaceAll('```json', '');
  content = content.replaceAll('```', '');
  content = content.replaceAll('***json', '');
  content = content.replaceAll('***', '');
  
  // Step 10: DON'T remove double asterisks ** (markdown bold)
  // Keep ** for bold formatting - it's valid markdown
  
  // Step 11: Remove lines with only special characters
  content = content.replaceAll(
    RegExp(r'^\s*[\[\]{}",\s]*\s*$', multiLine: true),
    '',
  );
  
  // Step 12: Clean up extra blank lines and whitespace
  content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  content = content.replaceAll(RegExp(r'^\s+', multiLine: true), '');
  content = content.trim();

  logger.debug('Cleaned content length: ${content.length}');
  logger.debug('Extracted ${suggestedQuestions.length} suggested questions');

  // Safety: if cleanup removed too much, return original with basic cleanup
  if (content.isEmpty || content.length < 10) {
    logger.warning('Cleanup removed too much content! Returning original.');
    content = originalContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .replaceAll('***json', '')
        .replaceAll('***', '')
        .trim();
  }

  return {
    'content': content,
    'questions': suggestedQuestions,
  };
}

  /// Clean response content (legacy method for backward compatibility)
  String _cleanResponseContent(String content) {
    final result = _cleanResponseContentAndExtractQuestions(content);
    return result['content'] as String;
  }

  // ── Chat state toggles ────────────────────────────────────────────────────

  @override
  Future<ChatConversationModel> archiveChat(String id) async {
    try {
      final response = await dio.patch(ApiConstants.chatArchive(id));
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data['data'] ?? response.data : response.data;
        return ChatConversationModel.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to archive chat');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ChatConversationModel> pinChat(String id) async {
    try {
      final response = await dio.patch(ApiConstants.chatPin(id));
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data['data'] ?? response.data : response.data;
        return ChatConversationModel.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to pin chat');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ChatConversationModel> shareChat(String id) async {
    try {
      final response = await dio.patch(ApiConstants.chatShare(id));
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data['data'] ?? response.data : response.data;
        return ChatConversationModel.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to share chat');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  // ── Message actions ──────────────────────────────────────────────────────

  @override
  Future<String> enhancePrompt(String prompt) async {
    try {
      final response = await dio.post(
        ApiConstants.messageEnhance,
        data: {'prompt': prompt},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend shape: { data: { enhancedPrompt } }. Be lenient about the
        // envelope so a bare { enhancedPrompt } body also works.
        final body = response.data;
        final data = (body is Map && body['data'] is Map)
            ? body['data'] as Map
            : (body is Map ? body : const {});
        final enhanced = data['enhancedPrompt']?.toString();

        if (enhanced == null || enhanced.trim().isEmpty) {
          throw ServerException(message: 'Empty enhanced prompt');
        }
        return enhanced.trim();
      }
      throw ServerException(message: 'Failed to enhance prompt');
    } on DioException catch (e) {
      logger.error('DioException in enhancePrompt', e);
      throw ServerException(
        message: e.response?.data is Map
            ? (e.response?.data['message'] ?? 'Server error occurred')
            : (e.message ?? 'Network error occurred'),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      logger.error('Unexpected error in enhancePrompt', e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  // ── Message streaming actions ────────────────────────────────────────────

  @override
  Stream<String> regenerateMessage(String chatId, String messageId) async* {
    yield* _streamRequest(ApiConstants.messageRegenerate(chatId, messageId), {});
  }

  @override
  Stream<String> editMessage(String chatId, String messageId, String newContent) async* {
    yield* _streamRequest(ApiConstants.messageEdit(chatId, messageId), {'content': newContent});
  }

  @override
  Stream<String> continueChat(String chatId) async* {
    yield* _streamRequest(ApiConstants.chatContinue(chatId), {});
  }

  /// Shared SSE streaming logic for regenerate / edit / continue endpoints.
  Stream<String> _streamRequest(String url, Map<String, dynamic> body) async* {
    try {
      final response = await dio.post(
        url,
        data: body.isNotEmpty ? body : null,
        options: Options(responseType: ResponseType.stream),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final textStream = (response.data as ResponseBody).stream.cast<List<int>>().transform(utf8.decoder);
        final StringBuffer contentBuffer = StringBuffer();
        String partialLine = '';

        await for (final chunk in textStream) {
          final combined = partialLine + chunk;
          final lines = combined.split('\n');
          partialLine = lines.removeLast();

          for (final line in lines) {
            if (!line.startsWith('data: ')) continue;
            final dataStr = line.substring(6).trim();
            if (dataStr == '[DONE]') return;
            try {
              final data = jsonDecode(dataStr) as Map<String, dynamic>;
              if (data['type'] == 'token') {
                final token = data['content'] as String?;
                if (token != null) {
                  contentBuffer.write(token);
                  yield contentBuffer.toString();
                }
              }
            } catch (_) {}
          }
        }

        final finalContent = _cleanResponseContent(contentBuffer.toString());
        if (finalContent != contentBuffer.toString()) yield finalContent;
      } else {
        throw ServerException(message: 'Request failed');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  // ── Feedback ─────────────────────────────────────────────────────────────

  @override
  Future<void> submitFeedback(
    String chatId,
    String responseId,
    bool isPositive, {
    String? comment,
  }) async {
    try {
      await dio.post(
        ApiConstants.responseFeedback(chatId, responseId),
        data: {
          'isPositive': isPositive,
          if (comment != null) 'comment': comment,
        },
      );
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  // ── User Contexts ─────────────────────────────────────────────────────────

  @override
  Future<List<UserContextModel>> getSidebarContexts() async {
    try {
      final response = await dio.get(ApiConstants.contextsSidebar);
      if (response.statusCode == 200) {
        final data = _parseListResponse(response.data);
        return data.map((j) => UserContextModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      throw ServerException(message: 'Failed to fetch sidebar contexts');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<UserContextModel>> listContexts() async {
    try {
      final response = await dio.get(ApiConstants.contexts);
      if (response.statusCode == 200) {
        final data = _parseListResponse(response.data);
        return data.map((j) => UserContextModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      throw ServerException(message: 'Failed to fetch contexts');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<UserContextModel> createContext(String name, String content, String role) async {
    try {
      final response = await dio.post(
        ApiConstants.contexts,
        data: {'name': name, 'content': content, 'role': role},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return UserContextModel.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Failed to create context');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<UserContextModel> getContextById(String id) async {
    try {
      final response = await dio.get(ApiConstants.contextById(id));
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return UserContextModel.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Failed to fetch context');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<UserContextModel> updateContext(String id, String name, String content, String role) async {
    try {
      final response = await dio.put(
        ApiConstants.contextById(id),
        data: {'name': name, 'content': content, 'role': role},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return UserContextModel.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Failed to update context');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteContext(String id) async {
    try {
      final response = await dio.delete(ApiConstants.contextById(id));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete context');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}
