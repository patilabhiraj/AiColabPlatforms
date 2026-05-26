# User Profile Display Feature

## Overview
Updated the drawer profile footer to display the current logged-in user's details from the backend, including support for Google profile images.

## Changes Made

### 1. Updated User Entity (`lib/features/auth/domain/entities/user_entity.dart`)
- Added optional `profileImageUrl` field to store user's profile picture URL
- Updated `props` list to include the new field

### 2. Updated User Model (`lib/features/auth/data/models/user_model.dart`)
- Added `profileImageUrl` parameter to constructor
- Enhanced `fromJson()` to extract profile image from multiple possible field names:
  - `profileImageUrl`
  - `profileImage`
  - `photoUrl`
  - `photo`
  - `picture`
  - `avatar`
  - `image`
- Updated `toJson()` to include profile image URL when available

### 3. Updated Drawer Profile Footer (`lib/features/chat/presentation/widgets/drawer_sections/drawer_profile_footer.dart`)
- Extracts `profileImageUrl` from `AuthAuthenticated` state
- Displays real user profile image when available (e.g., from Google sign-in)
- Shows loading indicator while image is loading
- Falls back to icon if:
  - No profile image URL is provided
  - Image URL is empty
  - Image fails to load
- Logs warning when image loading fails

## Features

### User Information Display
- **First Name + Last Name**: Combined and displayed as full name
- **Email**: User's email address
- **Profile Image**: 
  - Shows Google profile picture if user signed in with Google
  - Shows profile picture from backend if available
  - Falls back to person icon with gradient background

### Image Loading States
1. **Loading**: Shows circular progress indicator
2. **Success**: Displays profile image
3. **Error**: Shows person icon with gradient

### Fallback Behavior
- If name is empty, displays "User"
- If no profile image, shows person icon
- If not authenticated, shows "Super Admin" placeholder

## Backend Integration

The feature automatically extracts profile image URLs from various field names commonly used by:
- Google OAuth (`picture`, `photoUrl`)
- Custom backends (`profileImageUrl`, `profileImage`)
- Other providers (`avatar`, `image`, `photo`)

## Testing

To test this feature:
1. Login with Google account - should show Google profile picture
2. Login with regular account - should show profile picture if backend provides it
3. If no image available - should show person icon with gradient
4. Check that firstName, lastName, and email are displayed correctly

## Notes
- Profile image is optional - app works fine without it
- Image loading is handled gracefully with loading states
- Error handling ensures app doesn't crash if image fails to load
- Supports multiple backend field name conventions
