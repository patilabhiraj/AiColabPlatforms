# 🔍 Follow-Up Questions Debugging Guide

## Issue
Follow-up questions are not showing up in the chat interface, even though the feature is fully implemented.

## What I Added
I've added comprehensive debug logging to track where the questions might be getting lost:

### 1. **BLoC Layer Debugging** (`chat_bloc.dart`)

#### In `_extractSuggestedQuestions` method:
```dart
print('🔍 DEBUG: Extracting questions from content (length: ${content.length})');
print('🔍 DEBUG: Content preview: ${content.substring(0, 200)}...');
print('🔍 DEBUG: Found ${matches.length} potential JSON arrays');
print('✅ DEBUG: Successfully extracted ${decoded.length} questions');
print('🔍 DEBUG: Total questions extracted: ${questions.length}');
```

#### In `_streamSingleModel` method:
```dart
print('📨 DEBUG: Final streaming content received');
print('✨ DEBUG: Creating message with ${suggestedQuestions.length} suggested questions');
print('📝 DEBUG: Suggested questions: $suggestedQuestions');
```

### 2. **UI Layer Debugging** (`chat_bubble.dart`)

```dart
print('🎨 UI DEBUG: Rendering AI message');
print('🎨 UI DEBUG: isStreaming: $isStreaming');
print('🎨 UI DEBUG: suggestedQuestions: ${message.suggestedQuestions}');
```

## How to Test

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Send a Message
Send any message like "Hello" to the AI.

### Step 3: Check Console Output
Look for these debug logs in your console:

#### Expected Logs Sequence:
```
🔍 DEBUG: Extracting questions from content (length: 543)
🔍 DEBUG: Content preview: Hello! Welcome to AI Colab Chat...
🔍 DEBUG: Found 1 potential JSON arrays
🔍 DEBUG: Trying to parse: ["question 1", "question 2", "question 3"]
✅ DEBUG: Successfully extracted 3 questions
🔍 DEBUG: Total questions extracted: 3
📝 DEBUG: Questions: [question 1, question 2, question 3]
📨 DEBUG: Final streaming content received (length: 543)
✨ DEBUG: Creating message with 3 suggested questions
📝 DEBUG: Suggested questions: [question 1, question 2, question 3]
🎨 UI DEBUG: Rendering AI message
🎨 UI DEBUG: isStreaming: false
🎨 UI DEBUG: suggestedQuestions: [question 1, question 2, question 3]
🎨 UI DEBUG: suggestedQuestions isEmpty: false
```

## Diagnostic Scenarios

### Scenario 1: No JSON Arrays Found
If you see:
```
🔍 DEBUG: Found 0 potential JSON arrays
🔍 DEBUG: Total questions extracted: 0
```
**Problem**: Backend is not sending questions in the expected format  
**Solution**: Check backend response format

### Scenario 2: JSON Parse Errors
If you see:
```
❌ DEBUG: Failed to parse JSON: FormatException: ...
```
**Problem**: JSON format is invalid  
**Solution**: Backend needs to send valid JSON array

### Scenario 3: Questions Extracted but Not Shown
If you see questions in BLoC but not in UI:
```
✅ DEBUG: Successfully extracted 3 questions
...
🎨 UI DEBUG: suggestedQuestions: null
```
**Problem**: Questions lost between BLoC and UI  
**Solution**: Check ChatMessage creation and state management

### Scenario 4: Questions Present but Condition Fails
If you see:
```
🎨 UI DEBUG: isStreaming: true
🎨 UI DEBUG: suggestedQuestions: [...]
```
**Problem**: UI is still in streaming state  
**Solution**: Questions only show after streaming completes

## Common Issues

### Issue 1: Backend Format
The backend should send questions like:
```json
Response text here...

["Question 1?", "Question 2?", "Question 3?"]
```

OR with markers:
```
Response text here...

***json
["Question 1?", "Question 2?", "Question 3?"]
***
```

### Issue 2: Regex Pattern
Current pattern matches:
```regex
\[\s*"([^"]+)"(?:\s*,\s*"([^"]+)")*\s*\]
```

This matches:
- ✅ `["question"]`
- ✅ `[ "question 1", "question 2" ]`
- ✅ `["q1","q2","q3"]`
- ❌ `['question']` (single quotes)
- ❌ `[question]` (no quotes)

### Issue 3: Cleaning Removes Questions
If questions are removed during content cleaning:
- Check `_cleanStreamedContent` method
- Ensure it's called AFTER `_extractSuggestedQuestions`

## Next Steps

1. **Run the app** and send a message
2. **Copy the console output** and share it
3. **Based on the logs**, we can identify exactly where the issue is

## Expected Backend Response Format

### Format 1: JSON Array at End
```
Hello! I'm your AI assistant. I can help you with various tasks.

["What can you do?", "How do I get started?", "Can you help with coding?"]
```

### Format 2: With Markers
```
Hello! I'm your AI assistant.

***json
["What can you do?", "How do I get started?", "Can you help with coding?"]
***
```

### Format 3: Code Block
```
Hello! I'm your AI assistant.

```json
["What can you do?", "How do I get started?", "Can you help with coding?"]
```
```

## Files Modified

1. ✅ `lib/features/chat/bloc/chat_bloc.dart`
   - Added debug logging in `_extractSuggestedQuestions`
   - Added debug logging in `_streamSingleModel`

2. ✅ `lib/features/chat/presentation/widgets/chat_bubble.dart`
   - Added debug logging in `build` method

## Remove Debug Logs Later

Once the issue is fixed, remove the debug logs:
```dart
// Remove all lines starting with:
print('🔍 DEBUG: ...');
print('📨 DEBUG: ...');
print('✨ DEBUG: ...');
print('📝 DEBUG: ...');
print('🎨 UI DEBUG: ...');
print('✅ DEBUG: ...');
print('❌ DEBUG: ...');
```

## Summary

The debugging logs will help us:
1. ✅ See if backend is sending questions
2. ✅ See if extraction regex is working
3. ✅ See if questions reach the UI
4. ✅ Identify exactly where the data is lost

**Action Required**: Run the app and check the console logs!

---

**Status**: 🔍 **Debugging Added**  
**Next**: 🚀 **Run App & Check Logs**  
**Goal**: 🎯 **Find Where Questions Are Lost**
