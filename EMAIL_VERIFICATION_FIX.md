# Email Verification Error Fix

## Problem
When user tries to login without verifying their email:
1. Backend returns `requiresEmailVerification: true` with no token
2. App tries to parse empty token and creates invalid user
3. App navigates to chat page anyway
4. Chat page tries to load chats without token
5. Gets 401 Unauthorized error: "Token missing"

## Root Cause
The app was not checking if email verification is required before proceeding with login/register flow.

## Solution
Updated auth remote data source to check for `requiresEmailVerification` flag in the response and throw an appropriate exception.

## Changes Made

### Updated Auth Remote Data Source (`lib/features/auth/data/datasources/auth_remote_data_source.dart`)

#### Login Method:
- Added check for `requiresEmailVerification` flag
- Throws exception with message: "Email verification required. Please verify your email first."
- Prevents creating invalid user with empty token

#### Register Method:
- Added check for `requiresEmailVerification` flag
- Throws exception with message: "Email verification required. Please check your email and verify your account."
- Prevents navigation to chat without verification

## How It Works Now

### Login Flow:
1. User enters email and password
2. Backend responds with `requiresEmailVerification: true`
3. App throws exception before creating user
4. Repository catches exception and converts to `ServerFailure`
5. AuthBloc emits `AuthError` state
6. Login page shows error message in snackbar
7. User stays on login page

### Expected Behavior:
- ❌ **Before**: App navigates to chat page with no token → 401 error
- ✅ **After**: App shows error message and stays on login page

## Error Messages

### Login:
```
Email verification required. Please verify your email first.
```

### Register:
```
Email verification required. Please check your email and verify your account.
```

## Testing

To test:
1. Register a new account (don't verify email)
2. Try to login with that account
3. Should see error message
4. Should stay on login page
5. Should NOT navigate to chat page

## Backend Response Format

When email verification is required:
```json
{
  "status": true,
  "data": {
    "requiresEmailVerification": true,
    "email": "test@gmail.com"
  },
  "message": "Email verification required"
}
```

When login is successful:
```json
{
  "status": true,
  "data": {
    "user": { ... },
    "token": "eyJhbGc..."
  },
  "message": "Login successful"
}
```

## Notes
- Exception is thrown BEFORE creating UserModel
- No invalid user is created
- No navigation happens
- Token is never saved
- User gets clear error message
- User can verify email and try again
