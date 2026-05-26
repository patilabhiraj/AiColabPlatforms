# Email Verification Flow Implementation

## Overview
Implemented complete email verification flow that automatically sends OTP and navigates user to verification page when email is not verified.

## Problem Solved
Previously, when user tried to login without verifying email:
- Backend returned `requiresEmailVerification: true` with no token
- App showed generic error and stayed on login page
- User had to manually verify email somehow

## New Flow

### 1. Login/Register with Unverified Email
1. User enters credentials and submits
2. Backend responds with `requiresEmailVerification: true`
3. App throws `EmailVerificationRequiredException` with email
4. Repository catches exception and **automatically sends OTP** to email
5. Repository returns `EmailVerificationFailure` with email
6. AuthBloc emits `AuthEmailVerificationRequired` state with email
7. Login/Register page navigates to Email Verification page
8. Shows info snackbar: "Please verify your email. OTP sent to {email}"

### 2. Email Verification Page
- Shows 6-digit OTP input fields
- Auto-focuses next field on input
- Auto-verifies when all 6 digits entered
- Has "Verify Email" button
- Has "Resend OTP" button
- Shows loading states

### 3. After Verification
1. User enters OTP
2. App calls `/api/auth/verify-email-otp`
3. Backend verifies OTP
4. Shows success message
5. Navigates back to login page
6. User can now login successfully

## Files Created

### 1. Email Verification Page (`lib/features/auth/presentation/email_verification_page.dart`)
- Beautiful UI with 6 OTP input fields
- Auto-focus and auto-verify functionality
- Verify and Resend OTP buttons
- Loading states
- Error handling

### 2. Use Cases
- `lib/features/auth/domain/usecases/verify_email_otp_usecase.dart`
- `lib/features/auth/domain/usecases/resend_email_otp_usecase.dart`

### 3. Custom Exception (`lib/core/errors/exceptions.dart`)
- Added `EmailVerificationRequiredException` with email field

### 4. Custom Failure (`lib/core/errors/failures.dart`)
- Added `EmailVerificationFailure` with email field

## Files Modified

### 1. Auth State (`lib/features/auth/bloc/auth_state.dart`)
- Added `AuthEmailVerificationRequired` state with email

### 2. Auth Remote Data Source (`lib/features/auth/data/datasources/auth_remote_data_source.dart`)
- Login: Checks for `requiresEmailVerification` and throws exception
- Register: Checks for `requiresEmailVerification` and throws exception

### 3. Auth Repository (`lib/features/auth/data/repositories/auth_repository_impl.dart`)
- Login: Catches `EmailVerificationRequiredException` and **auto-sends OTP**
- Register: Catches `EmailVerificationRequiredException` (OTP already sent)
- Returns `EmailVerificationFailure` instead of generic error

### 4. Auth BLoC (`lib/features/auth/bloc/auth_bloc.dart`)
- Login handler: Checks for `EmailVerificationFailure` and emits verification state
- Register handler: Checks for `EmailVerificationFailure` and emits verification state

### 5. Router (`lib/app/routes/router.dart`)
- Added `/email-verification` route with email query parameter

### 6. Login Page (`lib/features/auth/presentation/login_page.dart`)
- Listens for `AuthEmailVerificationRequired` state
- Navigates to verification page with email

### 7. Register Page (`lib/features/auth/presentation/register_page.dart`)
- Listens for `AuthEmailVerificationRequired` state
- Navigates to verification page with email

### 8. Custom SnackBar (`lib/core/widgets/custom_snackbar.dart`)
- Added `showInfo()` method with blue color

### 9. Dependency Injection (`lib/app/injection.dart`)
- Registered `VerifyEmailOtpUseCase`
- Registered `ResendEmailOtpUseCase`

## User Experience

### Before:
```
1. User tries to login
2. Shows error: "Email verification required"
3. User confused - how to verify?
4. User has to manually find verification email
```

### After:
```
1. User tries to login
2. Shows: "Please verify your email. OTP sent to test@gmail.com"
3. Automatically navigates to OTP verification page
4. User enters 6-digit OTP
5. Clicks "Verify Email" or auto-verifies
6. Success! Redirects to login
7. User logs in successfully
```

## API Endpoints Used

### 1. Resend OTP (Auto-called on login)
```
POST /api/auth/resend-email-otp
Body: { "email": "test@gmail.com" }
```

### 2. Verify OTP
```
POST /api/auth/verify-email-otp
Body: { "email": "test@gmail.com", "otp": "123456" }
```

## Features

✅ **Automatic OTP Sending**
- OTP automatically sent when login fails due to unverified email
- No manual action needed from user

✅ **Beautiful Verification UI**
- 6 separate input fields for OTP
- Auto-focus next field
- Auto-verify when complete
- Loading states
- Error handling

✅ **Resend OTP**
- User can request new OTP
- Shows loading state
- Shows success/error messages

✅ **Seamless Navigation**
- Auto-navigates to verification page
- Passes email via query parameter
- Returns to login after verification

✅ **User-Friendly Messages**
- Clear info messages
- Shows which email OTP was sent to
- Success/error feedback

## Testing

To test the flow:
1. Register a new account (don't verify email)
2. Try to login with that account
3. Should see: "Please verify your email. OTP sent to..."
4. Should navigate to OTP verification page
5. Check email for OTP code
6. Enter 6-digit OTP
7. Should verify successfully
8. Should navigate back to login
9. Login again - should work now

## Notes
- OTP is automatically sent on login failure (no manual resend needed)
- OTP is already sent during registration (no auto-resend on register)
- Email is passed via URL query parameter
- Verification page is standalone (no BLoC needed)
- Uses dependency injection for use cases
- Clean error handling throughout
