# Like/Dislike/Regenerate Feature

## Overview
Added interactive feedback buttons to AI chat responses with visual state changes.

## Features Implemented

### 1. **Like Button (Thumbs Up)**
- Click to like the response
- **Turns GREEN** when liked
- Click again to remove like
- Sends feedback to backend

### 2. **Dislike Button (Thumbs Down)**
- Click to dislike the response
- **Turns RED** when disliked
- Click again to remove dislike
- Sends feedback to backend

### 3. **Regenerate Button (Refresh)**
- Click to regenerate the AI response
- Removes current response
- Sends same question again
- Gets new response from AI

## Implementation Details

### Files Modified:

#### 1. Chat Message Entity (`lib/features/chat/domain/entities/chat_message.dart`)
- Added `isLiked` field (bool?)
  - `null` = no feedback
  - `true` = liked (green)
  - `false` = disliked (red)
- Updated `copyWith` method
- Updated `props` for Equatable

#### 2. Chat Event (`lib/features/chat/bloc/chat_event.dart`)
- Added `ChatToggleLikeMessage` event
  - Takes message and new like state
  - Handles toggle logic

#### 3. Chat BLoC (`lib/features/chat/bloc/chat_bloc.dart`)
- Added `_onToggleLike` handler
  - Updates message with new like state
  - Emits updated state
  - UI automatically updates

#### 4. Chat Bubble (`lib/features/chat/presentation/widgets/chat_bubble.dart`)
- Updated `_ActionBar` widget
- **Like Button:**
  - Shows green when `isLiked == true`
  - Toggle logic: if liked, remove; else set to liked
  - Sends feedback to backend
- **Dislike Button:**
  - Shows red when `isLiked == false`
  - Toggle logic: if disliked, remove; else set to disliked
  - Sends feedback to backend
- **Regenerate Button:**
  - Triggers `ChatRegenerateMessage` event
  - Already implemented

## How It Works

### Like Flow:
1. User clicks thumbs up button
2. Check current state:
   - If already liked → Remove like (set to null)
   - If not liked → Set to liked (set to true)
3. Dispatch `ChatToggleLikeMessage` event
4. BLoC updates message state
5. **Button turns GREEN**
6. Send feedback to backend

### Dislike Flow:
1. User clicks thumbs down button
2. Check current state:
   - If already disliked → Remove dislike (set to null)
   - If not disliked → Set to disliked (set to false)
3. Dispatch `ChatToggleLikeMessage` event
4. BLoC updates message state
5. **Button turns RED**
6. Send feedback to backend

### Regenerate Flow:
1. User clicks refresh button
2. Dispatch `ChatRegenerateMessage` event
3. BLoC removes current message
4. Sends same question again
5. Gets new AI response
6. Displays new response

## Visual States

### Like Button:
- **Default:** Gray outline
- **Liked:** Green background + green icon
- **Disliked:** Gray outline (not active)

### Dislike Button:
- **Default:** Gray outline
- **Liked:** Gray outline (not active)
- **Disliked:** Red background + red icon

### Regenerate Button:
- **Always:** Gray outline
- **On Click:** Triggers regeneration

## User Experience

### Mutual Exclusivity:
- Like and Dislike are mutually exclusive
- Clicking Like removes Dislike
- Clicking Dislike removes Like
- Clicking same button again removes feedback

### Visual Feedback:
- Instant color change on click
- Clear active/inactive states
- Smooth transitions

### Backend Integration:
- Feedback sent to backend API
- Regenerate triggers new API call
- All actions logged

## Code Quality

✅ Clean state management with BLoC  
✅ Immutable state updates  
✅ Type-safe with null safety  
✅ Reusable action button component  
✅ Proper event handling  
✅ No side effects  

## Testing Checklist

- [ ] Click like button → turns green
- [ ] Click like again → removes green
- [ ] Click dislike button → turns red
- [ ] Click dislike again → removes red
- [ ] Click like then dislike → like removed, dislike active
- [ ] Click dislike then like → dislike removed, like active
- [ ] Click regenerate → new response generated
- [ ] All actions send to backend
- [ ] State persists during scroll
- [ ] Works with multiple messages

## Summary

Added complete feedback system to AI responses:
- ✅ Like button with green color
- ✅ Dislike button with red color
- ✅ Regenerate button for new responses
- ✅ Toggle functionality
- ✅ Backend integration
- ✅ Clean state management

**Status:** ✅ Complete and Ready to Use
