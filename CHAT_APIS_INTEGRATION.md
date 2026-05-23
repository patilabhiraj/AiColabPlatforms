# Complete Chat APIs Integration

## Overview
All chat-related APIs have been integrated following Clean Architecture principles.

## Integrated APIs

### 1. GET `/api/chats` - List Chats
**Purpose:** Fetch all chats for the authenticated user

**Repository Method:**
```dart
Future<Either<Failure, List<ChatConversation>>> listChats();
```

**Usage:**
```dart
final result = await chatRepository.listChats();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (chats) => print('Found ${chats.length} chats'),
);
```

---

### 2. POST `/api/chats` - Create Chat
**Purpose:** Create a new chat conversation

**Request Body:**
```json
{
  "title": "Chat title"
}
```

**Repository Method:**
```dart
Future<Either<Failure, ChatConversation>> createChat(String title);
```

**Usage:**
```dart
final result = await chatRepository.createChat('My New Chat');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (chat) => print('Created chat: ${chat.title}'),
);
```

---

### 3. GET `/api/chats/{id}` - Get Chat by ID
**Purpose:** Fetch a specific chat by its ID

**Repository Method:**
```dart
Future<Either<Failure, ChatConversation>> getChatById(String id);
```

**Usage:**
```dart
final result = await chatRepository.getChatById('chat-id-123');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (chat) => print('Chat: ${chat.title}'),
);
```

---

### 4. PUT `/api/chats/{id}` - Update Chat
**Purpose:** Update chat title

**Request Body:**
```json
{
  "title": "Updated title"
}
```

**Repository Method:**
```dart
Future<Either<Failure, ChatConversation>> updateChat(String id, String title);
```

**Usage:**
```dart
final result = await chatRepository.updateChat('chat-id-123', 'New Title');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (chat) => print('Updated: ${chat.title}'),
);
```

---

### 5. DELETE `/api/chats/{id}` - Delete Chat
**Purpose:** Delete a chat conversation

**Repository Method:**
```dart
Future<Either<Failure, void>> deleteChat(String id);
```

**Usage:**
```dart
final result = await chatRepository.deleteChat('chat-id-123');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (_) => print('Chat deleted successfully'),
);
```

---

### 6. GET `/api/chats/{id}/contexts` - Get Chat Contexts
**Purpose:** Fetch conversation context/history for a chat

**Repository Method:**
```dart
Future<Either<Failure, List<ChatContext>>> getChatContexts(String id);
```

**Usage:**
```dart
final result = await chatRepository.getChatContexts('chat-id-123');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (contexts) {
    for (var context in contexts) {
      print('${context.role}: ${context.content}');
    }
  },
);
```

---

### 7. PUT `/api/chats/{id}/contexts` - Replace Chat Contexts
**Purpose:** Replace entire conversation context

**Request Body:**
```json
{
  "contexts": [
    {
      "role": "user",
      "content": "Hello"
    },
    {
      "role": "assistant",
      "content": "Hi there!"
    }
  ]
}
```

**Repository Method:**
```dart
Future<Either<Failure, void>> replaceChatContexts(
  String id,
  List<ChatContext> contexts,
);
```

**Usage:**
```dart
final contexts = [
  ChatContext(role: 'user', content: 'Hello'),
  ChatContext(role: 'assistant', content: 'Hi!'),
];

final result = await chatRepository.replaceChatContexts('chat-id-123', contexts);
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (_) => print('Contexts replaced successfully'),
);
```

---

### 8. GET `/api/chats/shared/{shareId}` - Get Shared Chat
**Purpose:** Access a publicly shared chat

**Repository Method:**
```dart
Future<Either<Failure, SharedChat>> getSharedChat(String shareId);
```

**Usage:**
```dart
final result = await chatRepository.getSharedChat('share-id-xyz');
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (sharedChat) => print('Status: ${sharedChat.status}'),
);
```

---

## Architecture Structure

### Domain Layer
```
lib/features/chat/domain/
├── entities/
│   ├── chat_conversation.dart
│   ├── chat_message.dart
│   ├── chat_context.dart
│   └── shared_chat.dart
├── repositories/
│   └── chat_repository.dart
└── usecases/
    ├── get_conversations_usecase.dart
    ├── get_messages_usecase.dart
    ├── send_message_usecase.dart
    └── get_shared_chat_usecase.dart
```

### Data Layer
```
lib/features/chat/data/
├── models/
│   ├── chat_conversation_model.dart
│   ├── chat_message_model.dart
│   ├── chat_context_model.dart
│   └── shared_chat_model.dart
├── datasources/
│   └── chat_remote_data_source.dart
└── repositories/
    └── chat_repository_impl.dart
```

## API Constants

**File:** `lib/core/constants/api_constants.dart`

```dart
static const String chats = '/api/chats';
static String chatById(String id) => '/api/chats/$id';
static String chatContexts(String id) => '/api/chats/$id/contexts';
static const String sharedChat = '/api/chats/shared';
```

## Error Handling

All methods return `Either<Failure, T>`:
- **Left (Failure):** Error occurred
- **Right (T):** Success with data

### Exception Types:
- `ServerException` - API/Server errors
- `NetworkException` - Network connectivity issues
- `CacheException` - Local cache errors

### Failure Types:
- `ServerFailure` - Mapped from exceptions
- Contains user-friendly error messages

## Complete Example: Chat CRUD Operations

```dart
class ChatService {
  final ChatRepository repository;

  ChatService(this.repository);

  // Create a new chat
  Future<void> createNewChat(String title) async {
    final result = await repository.createChat(title);
    result.fold(
      (failure) => print('Failed to create: ${failure.message}'),
      (chat) => print('Created chat: ${chat.id}'),
    );
  }

  // List all chats
  Future<void> loadAllChats() async {
    final result = await repository.listChats();
    result.fold(
      (failure) => print('Failed to load: ${failure.message}'),
      (chats) {
        print('Loaded ${chats.length} chats');
        for (var chat in chats) {
          print('- ${chat.title}');
        }
      },
    );
  }

  // Update chat title
  Future<void> renameChat(String id, String newTitle) async {
    final result = await repository.updateChat(id, newTitle);
    result.fold(
      (failure) => print('Failed to update: ${failure.message}'),
      (chat) => print('Updated to: ${chat.title}'),
    );
  }

  // Delete chat
  Future<void> removeChat(String id) async {
    final result = await repository.deleteChat(id);
    result.fold(
      (failure) => print('Failed to delete: ${failure.message}'),
      (_) => print('Chat deleted'),
    );
  }

  // Get chat contexts
  Future<void> loadChatHistory(String id) async {
    final result = await repository.getChatContexts(id);
    result.fold(
      (failure) => print('Failed to load history: ${failure.message}'),
      (contexts) {
        print('Chat history:');
        for (var context in contexts) {
          print('[${context.role}]: ${context.content}');
        }
      },
    );
  }

  // Replace contexts
  Future<void> updateChatHistory(String id, List<ChatContext> newContexts) async {
    final result = await repository.replaceChatContexts(id, newContexts);
    result.fold(
      (failure) => print('Failed to update history: ${failure.message}'),
      (_) => print('History updated'),
    );
  }
}
```

## Testing Example

```dart
void main() {
  group('ChatRepository', () {
    late ChatRepository repository;
    late MockChatRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockChatRemoteDataSource();
      repository = ChatRepositoryImpl(mockDataSource);
    });

    test('should return list of chats when listChats is called', () async {
      // Arrange
      final mockChats = [
        ChatConversationModel(
          id: '1',
          title: 'Test Chat',
          lastMessage: 'Hello',
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockDataSource.listChats()).thenAnswer((_) async => mockChats);

      // Act
      final result = await repository.listChats();

      // Assert
      expect(result, Right(mockChats));
      verify(mockDataSource.listChats());
    });

    test('should return failure when deleteChat fails', () async {
      // Arrange
      when(mockDataSource.deleteChat('1'))
          .thenThrow(ServerException(message: 'Not found'));

      // Act
      final result = await repository.deleteChat('1');

      // Assert
      expect(result, Left(ServerFailure('Not found')));
    });
  });
}
```

## Files Created/Modified

### Created:
1. `lib/features/chat/domain/entities/chat_context.dart`
2. `lib/features/chat/data/models/chat_context_model.dart`

### Modified:
1. `lib/core/constants/api_constants.dart` - Added new endpoints
2. `lib/features/chat/domain/repositories/chat_repository.dart` - Added 7 new methods
3. `lib/features/chat/data/datasources/chat_remote_data_source.dart` - Implemented all APIs
4. `lib/features/chat/data/repositories/chat_repository_impl.dart` - Added implementations

## Next Steps

1. ✅ All APIs integrated
2. ⏳ Create UseCases for new methods (optional, can use repository directly)
3. ⏳ Update BLoC to use new APIs
4. ⏳ Update UI to support CRUD operations
5. ⏳ Add comprehensive unit tests
6. ⏳ Add integration tests

## Benefits

✅ **Complete CRUD** - Full chat management capabilities
✅ **Context Management** - Conversation history control
✅ **Clean Architecture** - Maintainable and testable
✅ **Error Handling** - Robust error management
✅ **Type Safety** - Strong typing with entities and models
✅ **Scalable** - Easy to extend with new features
