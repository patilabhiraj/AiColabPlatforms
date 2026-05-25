# Real-Time Streaming Implementation Plan

## 🎯 Goal

Display AI response in real-time as tokens arrive (like ChatGPT typing effect).

## 📊 Current vs Desired

### Current (Batch) ❌
```
User sends message
↓
Wait for complete response
↓
Display all at once
```

### Desired (Streaming) ✅
```
User sends message
↓
Token 1 arrives → Display "Hello"
↓
Token 2 arrives → Display "Hello test"
↓
Token 3 arrives → Display "Hello test patil!"
↓
...
```

## 🔧 Implementation Steps

### Step 1: Update Data Source (Stream-based)

**Current**:
```dart
Future<ChatMessageModel> sendMessage(String conversationId, String content)
```

**New**:
```dart
Stream<String> sendMessageStream(String conversationId, String content)
```

### Step 2: Update Repository

**Add**:
```dart
Stream<String> sendMessageStream(String conversationId, String content);
```

### Step 3: Update BLoC

**Add new events**:
```dart
class ChatSendMessageStreaming extends ChatEvent
class ChatStreamToken extends ChatEvent
class ChatStreamComplete extends ChatEvent
```

**Add new states**:
```dart
class ChatStreaming extends ChatState {
  final String currentContent;
  final String messageId;
}
```

### Step 4: Update UI

**Display streaming content**:
```dart
BlocBuilder<ChatBloc, ChatState>(
  builder: (context, state) {
    if (state is ChatStreaming) {
      // Show partial message with typing cursor
      return ChatBubble(
        message: ChatMessage(
          id: state.messageId,
          content: state.currentContent,
          isUser: false,
          isStreaming: true, // Show typing indicator
        ),
      );
    }
  },
)
```

## 📝 Detailed Implementation

### 1. Data Source - Stream Method

```dart
Stream<String> sendMessageStream(String conversationId, String content) async* {
  final response = await dio.post(
    ApiConstants.chatSend(conversationId),
    data: {'content': content},
    options: Options(
      responseType: ResponseType.stream, // ✅ Stream mode
    ),
  );

  final stream = response.data.stream;
  final StringBuffer contentBuffer = StringBuffer();
  String? messageId;

  await for (final chunk in stream.transform(utf8.decoder)) {
    final lines = chunk.split('\n');
    
    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final dataStr = line.substring(6);
        
        if (dataStr == '[DONE]') break;
        
        try {
          final data = jsonDecode(dataStr);
          final type = data['type'];
          
          if (type == 'message_id') {
            messageId = data['assistantMessageId']?.toString();
          } else if (type == 'token') {
            final token = data['content'] as String?;
            if (token != null) {
              contentBuffer.write(token);
              yield contentBuffer.toString(); // ✅ Yield each token
            }
          }
        } catch (e) {
          logger.debug('Failed to parse SSE line: $dataStr');
        }
      }
    }
  }
}
```

### 2. BLoC - Handle Streaming

```dart
on<ChatSendMessageStreaming>((event, emit) async {
  // Add user message
  final userMsg = ChatMessage(...);
  emit(current.copyWith(messages: [...current.messages, userMsg]));

  // Create conversation if needed
  final conversationId = await _getOrCreateConversation(event.content);

  // Start streaming
  final messageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
  
  await emit.forEach(
    _repository.sendMessageStream(conversationId, event.content),
    onData: (String content) {
      // Emit state with partial content
      return ChatStreaming(
        conversations: current.conversations,
        selectedConversation: current.selectedConversation,
        messages: current.messages,
        currentStreamingContent: content,
        streamingMessageId: messageId,
      );
    },
    onError: (error, stackTrace) {
      return ChatError(error.toString());
    },
  );

  // Stream complete - add final message
  final finalMessage = ChatMessage(
    id: messageId,
    content: lastStreamedContent,
    isUser: false,
    timestamp: DateTime.now(),
  );
  
  emit(current.copyWith(
    messages: [...current.messages, finalMessage],
  ));
});
```

### 3. UI - Display Streaming

```dart
BlocBuilder<ChatBloc, ChatState>(
  builder: (context, state) {
    if (state is ChatStreaming) {
      // Show messages + streaming message
      return ListView(
        children: [
          ...state.messages.map((m) => ChatBubble(message: m)),
          
          // Streaming message with cursor
          ChatBubble(
            message: ChatMessage(
              id: state.streamingMessageId,
              content: state.currentStreamingContent,
              isUser: false,
              timestamp: DateTime.now(),
            ),
            isStreaming: true, // Show typing cursor
          ),
        ],
      );
    }
    
    // ... other states
  },
)
```

### 4. Chat Bubble - Streaming Indicator

```dart
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SelectableText(message.content),
          
          if (isStreaming)
            // Blinking cursor
            AnimatedOpacity(
              opacity: _cursorVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Text('▊', style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }
}
```

## 🎯 Benefits

### Real-Time Streaming ✅
- Tokens display as they arrive
- Better user experience
- Feels more interactive
- Like ChatGPT

### Current (Batch) ❌
- Wait for complete response
- Feels slow
- No feedback during generation

## ⚠️ Complexity

This is a **significant change** requiring:
1. Stream-based data source
2. New BLoC events/states
3. UI updates for streaming
4. Cursor animation
5. Error handling for streams

## 🚀 Alternative: Quick Fix

If you want a simpler solution for now, we can just show a better loading indicator while waiting for the complete response.

Would you like me to:
1. **Implement full streaming** (complex, better UX)
2. **Improve loading indicator** (simple, quick fix)

Let me know! 👍
