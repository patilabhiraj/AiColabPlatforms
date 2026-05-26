# Logout Feature Implementation

## Overview
Implemented complete logout functionality that clears user session and navigates back to splash screen.

## Changes Made

### 1. Created Logout UseCase (`lib/features/auth/domain/usecases/logout_usecase.dart`)
- New file created
- Calls repository logout method
- Returns Either<Failure, void>

### 2. Updated Auth Event (`lib/features/auth/bloc/auth_event.dart`)
- Added `AuthLogoutRequested` event

### 3. Updated Auth BLoC (`lib/features/auth/bloc/auth_bloc.dart`)
- Added `LogoutUseCase` dependency
- Added `_onLogoutRequested` handler
- Emits `AuthInitial` state after logout
- Added proper logging for logout flow

### 4. Updated Dependency Injection (`lib/app/injection.dart`)
- LogoutUseCase already registered
- Updated AuthBloc factory to include 4th parameter (LogoutUseCase)

### 5. Updated Drawer Profile Footer (`lib/features/chat/presentation/widgets/drawer_sections/drawer_profile_footer.dart`)
- Implemented logout button functionality
- Triggers `AuthLogoutRequested` event when clicked
- Added debug logging

### 6. Updated App Widget (`lib/app/app.dart`)
- Added `BlocListener<AuthBloc, AuthState>` wrapper
- Listens for `AuthInitial` state (logout state)
- Automatically navigates to splash screen on logout
- Added logging for navigation

## How It Works

### Logout Flow:
1. User clicks "Logout" button in drawer profile footer
2. `AuthLogoutRequested` event is dispatched to AuthBloc
3. AuthBloc calls `LogoutUseCase`
4. LogoutUseCase calls repository's `logout()` method
5. Repository deletes token from:
   - FlutterSecureStorage
   - SharedPreferences (fallback)
6. AuthBloc emits `AuthInitial` state
7. App's BlocListener detects `AuthInitial` state
8. App navigates to splash screen using `context.go(AppRouter.splash)`

### Token Cleanup:
- Token is deleted from both secure storage and shared preferences
- Even if logout fails, state is cleared to ensure user is logged out
- Graceful error handling ensures app doesn't crash

## Features

✅ **Complete Session Cleanup**
- Removes auth token from secure storage
- Removes auth token from shared preferences fallback
- Clears AuthBloc state

✅ **Automatic Navigation**
- Listens to auth state changes globally
- Navigates to splash screen when logged out
- No manual navigation needed from logout button

✅ **Error Handling**
- Graceful fallback if logout fails
- User is still logged out even if token deletion fails
- Proper logging for debugging

✅ **User Experience**
- Smooth transition to splash screen
- Bottom sheet closes automatically
- Clear visual feedback

## Testing

To test logout:
1. Login to the app
2. Open drawer
3. Click profile footer (3 dots)
4. Click "Logout" button
5. App should navigate to splash screen
6. Token should be deleted from storage
7. Check logs for logout flow

## Logs to Watch

```
🚪 Logout button clicked
🚪 Logout requested
✅ Logout successful
🚪 User logged out - navigating to splash
```

## Notes
- Logout is always successful (even if token deletion fails)
- User cannot stay logged in after clicking logout
- Navigation happens automatically via BlocListener
- No need to manually navigate from logout button
