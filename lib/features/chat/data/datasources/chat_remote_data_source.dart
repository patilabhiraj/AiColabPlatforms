import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/chat_context_model.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';
import '../models/shared_chat_model.dart';

abstract class ChatRemoteDataSource {
  // Legacy methods
  Future<List<ChatConversationModel>> getConversations();
  Future<List<ChatMessageModel>> getMessages(String conversationId);
  Future<ChatMessageModel> sendMessage(String conversationId, String content);
  Future<ChatConversationModel> createConversation(String firstMessage);
  
  // Streaming method for real-time responses
  Stream<String> sendMessageStream(String conversationId, String content);
  
  // New API methods
  Future<List<ChatConversationModel>> listChats();
  Future<ChatConversationModel> createChat(String title);
  Future<ChatConversationModel> getChatById(String id);
  Future<ChatConversationModel> updateChat(String id, String title);
  Future<void> deleteChat(String id);
  Future<List<ChatContextModel>> getChatContexts(String id);
  Future<void> replaceChatContexts(String id, List<ChatContextModel> contexts);
  Future<SharedChatModel> getSharedChat(String shareId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final response = await dio.get(ApiConstants.chats);

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        final List<dynamic> data;
        
        if (responseData is Map<String, dynamic>) {
          // Check if data is nested (pagination response)
          final dataField = responseData['data'];
          
          if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
            // Paginated response: {data: {data: [...]}}
            data = dataField['data'] as List<dynamic>? ?? [];
          } else if (dataField is List) {
            // Simple wrapped response: {data: [...]}
            data = dataField;
          } else {
            data = [];
          }
        } else if (responseData is List) {
          // Direct list response
          data = responseData;
        } else {
          throw ServerException(message: 'Invalid response format');
        }
        
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
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    try {
      final response = await dio.get(
        ApiConstants.chatMessages(conversationId),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        final List<dynamic> data;
        
        if (responseData is Map<String, dynamic>) {
          // Check if data is nested (pagination response)
          final dataField = responseData['data'];
          
          if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
            // Paginated response: {data: {data: [...]}}
            data = dataField['data'] as List<dynamic>? ?? [];
          } else if (dataField is List) {
            // Simple wrapped response: {data: [...]}
            data = dataField;
          } else {
            data = [];
          }
        } else if (responseData is List) {
          // Direct list response
          data = responseData;
        } else {
          throw ServerException(message: 'Invalid response format');
        }
        
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
      
      // ✅ Fixed: cast to List<int> first, then transform with utf8.decoder
      final textStream = stream.cast<List<int>>().transform(utf8.decoder);
      
      await for (final chunk in textStream) {
        final lines = chunk.split('\n');
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6);
            
            if (dataStr == '[DONE]') {
              logger.info('Stream complete');
              return; // ✅ use return instead of break to exit async* generator
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
      }
      
      // Final cleanup and yield
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
  @override
  Future<ChatConversationModel> createConversation(String firstMessage) async {
    try {
      final title = firstMessage.length > 40
          ? '${firstMessage.substring(0, 40)}...'
          : firstMessage;
      
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
        final dynamic responseData = response.data;
        final List<dynamic> data;
        
        if (responseData is Map<String, dynamic>) {
          // Check if data is nested (pagination response)
          final dataField = responseData['data'];
          
          if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
            // Paginated response: {data: {data: [...]}}
            data = dataField['data'] as List<dynamic>? ?? [];
          } else if (dataField is List) {
            // Simple wrapped response: {data: [...]}
            data = dataField;
          } else {
            data = [];
          }
        } else if (responseData is List) {
          // Direct list response
          data = responseData;
        } else {
          throw ServerException(message: 'Invalid response format');
        }
        
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
        final dynamic responseData = response.data;
        final List<dynamic> data;
        
        if (responseData is Map<String, dynamic>) {
          // Check if data is nested (pagination response)
          final dataField = responseData['data'];
          
          if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
            // Paginated response: {data: {data: [...]}}
            data = dataField['data'] as List<dynamic>? ?? [];
          } else if (dataField is List) {
            // Simple wrapped response: {data: [...]}
            data = dataField;
          } else {
            data = [];
          }
        } else if (responseData is List) {
          // Direct list response
          data = responseData;
        } else {
          throw ServerException(message: 'Invalid response format');
        }
        
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
}
