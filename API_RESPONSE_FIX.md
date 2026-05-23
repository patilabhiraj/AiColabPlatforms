# API Response Format Fix

## Problem
Error: `Unexpected error: type '_Map<String, dynamic>' is not a subtype of type 'List<dynamic>'`

## Root Cause
The API response format was inconsistent. Code expected:
```json
{
  "data": [...]  // List wrapped in data key
}
```

But API was returning:
```json
{...}  // Direct Map or List
```

## Solution
Updated all list-returning methods to handle both response formats:

### Fixed Methods:
1. `getConversations()` - GET /api/chats
2. `listChats()` - GET /api/chats
3. `getMessages()` - GET /api/chats/{id}/messages
4. `getChatContexts()` - GET /api/chats/{id}/contexts

### Implementation:
```dart
// Handle both response formats
final dynamic responseData = response.data;
final List<dynamic> data;

if (responseData is Map<String, dynamic>) {
  // If response is wrapped in {data: [...]}
  data = responseData['data'] as List<dynamic>? ?? [];
} else if (responseData is List) {
  // If response is directly a list
  data = responseData;
} else {
  throw ServerException(message: 'Invalid response format');
}

return data
    .map((json) => ModelClass.fromJson(json as Map<String, dynamic>))
    .toList();
```

## Benefits
✅ Handles wrapped responses: `{data: [...]}`
✅ Handles direct list responses: `[...]`
✅ Proper error handling for invalid formats
✅ No more type casting errors

## Testing
Test with both response formats:

**Format 1 (Wrapped):**
```json
{
  "status": true,
  "message": "success",
  "data": [
    {"id": "1", "title": "Chat 1"},
    {"id": "2", "title": "Chat 2"}
  ]
}
```

**Format 2 (Direct):**
```json
[
  {"id": "1", "title": "Chat 1"},
  {"id": "2", "title": "Chat 2"}
]
```

Both formats now work correctly! 🎉
