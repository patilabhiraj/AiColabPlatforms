# Message Send Endpoint Fix

## Issue
The app was using the wrong endpoint for sending messages:
- **Wrong**: `/api/chats/{id}/messages` (404 error)
- **Correct**: `/api/chats/{id}/send`

## Changes Made

### 1. Added Missing Endpoint Method
**File**: `lib/core/constants/api_constants.dart`

Added the missing `chatMessages()` method for getting messages:
```dart
static String chatMessages(String id) => '/api/chats/$id/messages'; // GET - Get messages
static String chatSend(String id)    => '/api/chats/$id/send'; // POST - Send message
```

### 2. Data Source Already Fixed
**File**: `lib/features/chat/data/datasources/chat_remote_data_source.dart`

The `sendMessage()` method was already updated to use the correct endpoint:
```dart
final response = await dio.post(
  ApiConstants.chatSend(conversationId),  // ✅ Correct endpoint
  data: {'content': content},
);
```

## API Endpoints Summary

### Chat Management
- `GET /api/chats` - List all chats (paginated)
- `POST /api/chats` - Create new chat
- `GET /api/chats/{id}` - Get chat by ID
- `PUT /api/chats/{id}` - Update chat
- `DELETE /api/chats/{id}` - Delete chat

### Messages
- `GET /api/chats/{id}/messages` - Get all messages in a chat
- `POST /api/chats/{id}/send` - Send a message (returns AI response)

### Contexts
- `GET /api/chats/{id}/contexts` - Get chat contexts
- `PUT /api/chats/{id}/contexts` - Replace chat contexts

### Sharing
- `GET /api/chats/shared/{shareId}` - Get shared chat

## Expected Response Format

### Send Message Response
```json
{
  "status": true,
  "data": {
    "id": 123,
    "content": "AI response here",
    "role": "assistant",
    "createdAt": "2026-05-23T11:15:44.097Z"
  },
  "message": "Message sent successfully"
}
```

## Message Flow

1. User types message and clicks send
2. If no conversation exists:
   - Create new conversation with `POST /api/chats` (title = first message)
   - Get conversation ID from response
3. Send message with `POST /api/chats/{id}/send`
4. Receive AI response from the same endpoint
5. Display both user message and AI response

## Testing Steps

1. **Hot Restart** the app (not just hot reload)
2. Start a new conversation
3. Type a message and send
4. Verify:
   - Message is sent successfully
   - AI response is received
   - Both messages appear in chat

## Status
✅ **FIXED** - The endpoint is now correct. App needs to be restarted for changes to take effect.
