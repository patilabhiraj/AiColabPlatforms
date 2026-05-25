# ✅ Streaming Response - Testing Checklist

## Pre-Testing Setup

- [ ] Backend is running and accessible
- [ ] Backend supports SSE streaming on `/api/chats/{id}/send`
- [ ] Authentication token is valid
- [ ] Internet connection is stable

---

## Test 1: New Conversation Streaming

### Steps:
1. [ ] Open the app
2. [ ] Ensure no conversation is selected (empty state)
3. [ ] Type "Hello" in the input field
4. [ ] Press send button

### Expected Results:
- [ ] User message appears immediately
- [ ] New conversation is created in sidebar
- [ ] AI response starts streaming word-by-word
- [ ] Blinking cursor appears next to streaming text
- [ ] Cursor blinks smoothly (pink/purple color)
- [ ] Response accumulates as tokens arrive
- [ ] Cursor disappears when streaming completes
- [ ] Final message appears in chat
- [ ] Copy and Regenerate buttons are visible

### Actual Results:
```
Write your observations here...
```

---

## Test 2: Existing Conversation Streaming

### Steps:
1. [ ] Select an existing conversation from sidebar
2. [ ] Type "Tell me a joke" in the input field
3. [ ] Press send button

### Expected Results:
- [ ] User message appears immediately
- [ ] AI response starts streaming immediately (no conversation creation delay)
- [ ] Blinking cursor appears
- [ ] Response streams word-by-word
- [ ] Cursor disappears when complete
- [ ] Final message appears

### Actual Results:
```
Write your observations here...
```

---

## Test 3: Long Response Streaming

### Steps:
1. [ ] Send message: "Write a long paragraph about AI"
2. [ ] Observe streaming behavior

### Expected Results:
- [ ] Response streams smoothly even for long content
- [ ] Cursor stays visible throughout streaming
- [ ] No lag or freezing
- [ ] Scroll automatically follows streaming content
- [ ] Final message appears correctly

### Actual Results:
```
Write your observations here...
```

---

## Test 4: Content Cleanup

### Steps:
1. [ ] Send a message that triggers suggested questions
2. [ ] Observe the response

### Expected Results:
- [ ] JSON blocks are removed from response
- [ ] No ` ```json` or `***json` visible
- [ ] No emoji artifacts (💡)
- [ ] Clean, readable response
- [ ] Suggested questions formatted properly (if mentioned)

### Actual Results:
```
Write your observations here...
```

---

## Test 5: Error Handling - Network Error

### Steps:
1. [ ] Turn off internet connection
2. [ ] Try to send a message
3. [ ] Observe behavior

### Expected Results:
- [ ] Error message is displayed
- [ ] Streaming state is cleared
- [ ] Previous messages remain visible
- [ ] Can retry after reconnecting

### Actual Results:
```
Write your observations here...
```

---

## Test 6: Error Handling - Backend Error

### Steps:
1. [ ] Stop backend server
2. [ ] Try to send a message
3. [ ] Observe behavior

### Expected Results:
- [ ] Error message is displayed
- [ ] App doesn't crash
- [ ] Can retry after backend is back

### Actual Results:
```
Write your observations here...
```

---

## Test 7: Multiple Messages in Sequence

### Steps:
1. [ ] Send message: "Hello"
2. [ ] Wait for response to complete
3. [ ] Send message: "How are you?"
4. [ ] Wait for response to complete
5. [ ] Send message: "Tell me about AI"

### Expected Results:
- [ ] Each message streams correctly
- [ ] No interference between messages
- [ ] Cursor appears/disappears correctly for each
- [ ] All messages appear in correct order

### Actual Results:
```
Write your observations here...
```

---

## Test 8: UI Responsiveness During Streaming

### Steps:
1. [ ] Send a message that generates long response
2. [ ] While streaming, try to:
   - [ ] Scroll up/down
   - [ ] Open sidebar
   - [ ] Switch conversations (if possible)

### Expected Results:
- [ ] UI remains responsive
- [ ] Scrolling works smoothly
- [ ] No lag or freezing
- [ ] Streaming continues in background

### Actual Results:
```
Write your observations here...
```

---

## Test 9: Cursor Animation Quality

### Steps:
1. [ ] Send any message
2. [ ] Observe cursor animation closely

### Expected Results:
- [ ] Cursor blinks smoothly (no jitter)
- [ ] Fade in/out is smooth (not abrupt)
- [ ] Color matches theme (pink/purple)
- [ ] Size is appropriate (2px × 18px)
- [ ] Position is correct (next to text)
- [ ] Animation cycle is ~530ms

### Actual Results:
```
Write your observations here...
```

---

## Test 10: Message Bubble Appearance

### Steps:
1. [ ] Send a message and wait for response
2. [ ] Observe the AI message bubble

### Expected Results:
- [ ] Border is visible and subtle
- [ ] Corners are rounded correctly
- [ ] Padding is appropriate
- [ ] Text is selectable
- [ ] Copy button works
- [ ] Regenerate button is visible (even if not functional yet)

### Actual Results:
```
Write your observations here...
```

---

## Performance Tests

### Test 11: Memory Usage
- [ ] Send 10 messages in a row
- [ ] Check memory usage in DevTools
- [ ] Expected: No memory leaks, stable memory usage

### Test 12: Network Usage
- [ ] Monitor network traffic during streaming
- [ ] Expected: Efficient SSE connection, no excessive requests

### Test 13: Battery Usage (Mobile)
- [ ] Use app for 10 minutes with streaming
- [ ] Check battery drain
- [ ] Expected: Reasonable battery usage

---

## Edge Cases

### Test 14: Empty Response
- [ ] Send message that might return empty response
- [ ] Expected: Graceful handling, no crash

### Test 15: Very Fast Streaming
- [ ] If backend sends tokens very fast
- [ ] Expected: UI keeps up, no lag

### Test 16: Very Slow Streaming
- [ ] If backend sends tokens very slowly
- [ ] Expected: Cursor keeps blinking, no timeout

### Test 17: Special Characters
- [ ] Send message with emojis, special chars
- [ ] Expected: Streams correctly, no encoding issues

---

## Regression Tests

### Test 18: Old Features Still Work
- [ ] Create new conversation (non-streaming)
- [ ] Delete conversation
- [ ] Update conversation title
- [ ] Share conversation
- [ ] Archive conversation

### Test 19: Authentication
- [ ] Login/logout still works
- [ ] Token refresh works
- [ ] Unauthorized handling works

---

## Browser/Platform Tests

### Test 20: Android
- [ ] Test on Android device/emulator
- [ ] All features work correctly

### Test 21: iOS (if applicable)
- [ ] Test on iOS device/simulator
- [ ] All features work correctly

### Test 22: Web (if applicable)
- [ ] Test on Chrome
- [ ] Test on Firefox
- [ ] Test on Safari

---

## Final Checks

### Code Quality
- [ ] No compilation errors
- [ ] No runtime errors in console
- [ ] No memory leaks
- [ ] Code follows project conventions

### User Experience
- [ ] Streaming feels natural and smooth
- [ ] Cursor animation is pleasant
- [ ] No jarring transitions
- [ ] Error messages are user-friendly

### Documentation
- [ ] Implementation docs are clear
- [ ] Code comments are adequate
- [ ] README is updated (if needed)

---

## Issues Found

### Issue 1:
**Description**: 
**Severity**: (Critical/High/Medium/Low)
**Steps to Reproduce**:
**Expected**:
**Actual**:

### Issue 2:
**Description**: 
**Severity**: 
**Steps to Reproduce**:
**Expected**:
**Actual**:

---

## Sign-Off

### Tested By:
**Name**: _______________  
**Date**: _______________  
**Environment**: _______________

### Test Results:
- [ ] All tests passed
- [ ] Some tests failed (see Issues Found section)
- [ ] Ready for production
- [ ] Needs fixes before production

### Notes:
```
Additional observations, comments, or recommendations...
```

---

## Quick Test Commands

```bash
# Run app in debug mode
flutter run

# Run app in release mode (for performance testing)
flutter run --release

# Check for errors
flutter analyze

# Run tests (if any)
flutter test

# Check app size
flutter build apk --analyze-size
```

---

**Testing Status**: ⏳ **PENDING**  
**Last Updated**: May 25, 2026
