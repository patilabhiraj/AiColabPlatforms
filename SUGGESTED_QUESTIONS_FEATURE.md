# ✨ Suggested Questions Feature - COMPLETE!

## 🎯 Feature Overview

Backend sends **suggested follow-up questions** in JSON array format. Now these questions are:
1. ✅ **Extracted** from the response
2. ✅ **Displayed** as clickable chips below AI message
3. ✅ **Clickable** - Sends question as new message when clicked

---

## 🎬 How It Works

### Backend Response Format:
```
Hello bro! Welcome to AI Colab Chat.

***json
[ "who are you?",
  "How can you help me?",
  "Can you help with Flutter?",
  "What can I ask you?"
]
***
```

### What Happens:

1. **Backend sends** response with JSON array
2. **App extracts** questions from JSON array
3. **App cleans** response (removes JSON blocks)
4. **App displays** clean response + clickable question chips
5. **User clicks** a question chip
6. **App sends** that question as new message

---

## 📝 Changes Made

### 1. Updated Entity (`chat_message.dart`):

**Added `suggestedQuestions` field:**
```dart
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestedQuestions;  // ✅ NEW

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestedQuestions,  // ✅ NEW
  });
  
  // ✅ Added copyWith method
  ChatMessage copyWith({...}) {...}
}
```

---

### 2. Updated Data Source (`chat_remote_data_source.dart`):

**Enhanced cleanup function:**
```dart
/// Clean response content and extract suggested questions
Map<String, dynamic> _cleanResponseContentAndExtractQuestions(String content) {
  List<String> suggestedQuestions = [];

  // Step 1: Extract JSON arrays BEFORE removing them
  final jsonArrayPattern = RegExp(r'\[\s*"([^"]*)"(?:\s*,\s*"([^"]*)")*\s*\]');
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
      // Ignore parse errors
    }
  }

  // Step 2-12: Clean content (remove JSON blocks, markers, etc.)
  // ...

  return {
    'content': cleanedContent,
    'questions': suggestedQuestions,
  };
}
```

---

### 3. Updated BLoC (`chat_bloc.dart`):

**Extract questions from final streaming content:**
```dart
// Stream complete - add final message with suggested questions
if (finalState.streamingContent != null) {
  // Extract suggested questions from the content
  final suggestedQuestions = _extractSuggestedQuestions(finalState.streamingContent!);
  
  final finalMessage = ChatMessage(
    id: streamingMessageId,
    content: finalState.streamingContent!,
    isUser: false,
    timestamp: DateTime.now(),
    suggestedQuestions: suggestedQuestions.isNotEmpty ? suggestedQuestions : null,  // ✅
  );
  
  emit(finalState.copyWith(
    messages: [...finalState.messages, finalMessage],
    isSending: false,
    clearStreaming: true,
  ));
}

/// Extract suggested questions from response content
List<String> _extractSuggestedQuestions(String content) {
  final questions = <String>[];
  
  // Try to find JSON array pattern
  final jsonArrayPattern = RegExp(r'\[\s*"([^"]+)"(?:\s*,\s*"([^"]+)")*\s*\]');
  final matches = jsonArrayPattern.allMatches(content);
  
  for (final match in matches) {
    try {
      final jsonStr = match.group(0);
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          questions.addAll(decoded.map((e) => e.toString()));
        }
      }
    } catch (e) {
      // Ignore parse errors
    }
  }
  
  return questions;
}
```

---

### 4. Updated UI (`chat_bubble.dart`):

**Added suggested question chips:**
```dart
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onQuestionTap,  // ✅ NEW callback
  });
  
  final ChatMessage message;
  final bool isStreaming;
  final void Function(String question)? onQuestionTap;  // ✅ NEW
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: message.isUser 
          ? _UserBubble(message) 
          : _AiBubble(message, isStreaming, onQuestionTap),  // ✅ Pass callback
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble(this.message, this.isStreaming, this.onQuestionTap);
  final ChatMessage message;
  final bool isStreaming;
  final void Function(String question)? onQuestionTap;  // ✅ NEW

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(...),
        child: Row(
          children: [
            Flexible(
              child: Container(
                child: Column(
                  children: [
                    // Message content with markdown
                    MarkdownBody(...),
                    
                    // Copy and Regenerate buttons
                    Row(...),
                    
                    // ✅ Suggested questions chips
                    if (message.suggestedQuestions != null && 
                        message.suggestedQuestions!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.suggestedQuestions!.map((question) {
                          return _SuggestedQuestionChip(
                            question: question,
                            onTap: () {
                              if (onQuestionTap != null) {
                                onQuestionTap!(question);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ NEW: Suggested Question Chip Widget
class _SuggestedQuestionChip extends StatelessWidget {
  const _SuggestedQuestionChip({
    required this.question,
    required this.onTap,
  });

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.landingPrimary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 14,
              color: AppColors.landingPrimary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                question,
                style: TextStyle(
                  color: AppColors.darkForeground.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 5. Updated Chat Page (`chat_page.dart`):

**Pass onQuestionTap callback:**
```dart
return ChatBubble(
  message: messages[index],
  onQuestionTap: (question) {
    context.read<ChatBloc>().add(ChatSendMessageStreaming(question));
  },
);
```

---

## 🎨 UI Design

### Suggested Question Chip:
```
┌─────────────────────────────────────────┐
│ 💡 How can you help me?                 │  ← Clickable chip
└─────────────────────────────────────────┘
```

**Features:**
- ✅ Lightbulb icon (💡)
- ✅ Pink/purple border (theme color)
- ✅ Dark background with transparency
- ✅ Rounded corners (16px)
- ✅ Wraps to multiple lines if needed
- ✅ Ellipsis if too long (max 2 lines)

---

## 📊 Flow Diagram

```
Backend Response
    ↓
Contains JSON array: [ "question 1", "question 2", ... ]
    ↓
BLoC extracts questions using regex
    ↓
Cleanup function removes JSON blocks
    ↓
ChatMessage created with:
  - content: Clean text
  - suggestedQuestions: ["question 1", "question 2", ...]
    ↓
UI displays:
  - Clean message text (markdown rendered)
  - Suggested question chips below
    ↓
User clicks a chip
    ↓
ChatSendMessageStreaming event dispatched
    ↓
Question sent as new message
    ↓
New response with new suggested questions
```

---

## 🚀 How To Test

### Step 1: Hot Restart
```bash
R  (capital R in terminal)
```

### Step 2: Send Message
```
Send: "Hello"
```

### Step 3: Check Response
Expected:
- ✅ Clean response text (no JSON blocks)
- ✅ Suggested question chips below message
- ✅ Each chip has lightbulb icon
- ✅ Chips are clickable

### Step 4: Click a Chip
Expected:
- ✅ Question sent as new message
- ✅ New response received
- ✅ New suggested questions appear

---

## ✅ Features

| Feature | Status |
|---------|--------|
| Extract questions from JSON | ✅ Done |
| Clean response (remove JSON) | ✅ Done |
| Display question chips | ✅ Done |
| Clickable chips | ✅ Done |
| Send question on click | ✅ Done |
| Lightbulb icon | ✅ Done |
| Theme colors | ✅ Done |
| Wrap layout | ✅ Done |
| Ellipsis for long text | ✅ Done |

---

## 📝 Files Modified

1. ✅ `lib/features/chat/domain/entities/chat_message.dart`
   - Added `suggestedQuestions` field
   - Added `copyWith` method

2. ✅ `lib/features/chat/data/datasources/chat_remote_data_source.dart`
   - Enhanced cleanup function to extract questions
   - Added `_cleanResponseContentAndExtractQuestions` method

3. ✅ `lib/features/chat/bloc/chat_bloc.dart`
   - Added `dart:convert` import
   - Added `_extractSuggestedQuestions` method
   - Updated streaming handler to extract questions

4. ✅ `lib/features/chat/presentation/widgets/chat_bubble.dart`
   - Added `onQuestionTap` callback parameter
   - Added `_SuggestedQuestionChip` widget
   - Display chips below AI messages

5. ✅ `lib/features/chat/presentation/chat_page.dart`
   - Pass `onQuestionTap` callback to ChatBubble
   - Dispatch `ChatSendMessageStreaming` on chip tap

---

## 🎯 Summary

| Item | Status |
|------|--------|
| Question extraction | ✅ Done |
| JSON cleanup | ✅ Done |
| UI chips | ✅ Done |
| Click handling | ✅ Done |
| Compilation | ✅ No errors |
| **Action needed** | **🔄 Hot Restart** |

---

## 🚀 Next Steps

1. **Hot Restart** the app (R in terminal)
2. **Send a message** to get response
3. **See suggested questions** as chips
4. **Click a chip** to send that question
5. **Enjoy** the feature! 🎉

---

**Status**: ✅ **COMPLETE**  
**Action**: **Hot Restart Required**  
**Result**: **Clickable suggested question chips!**

🎉 **Aata suggested questions clickable chips sarkhe disel!**
