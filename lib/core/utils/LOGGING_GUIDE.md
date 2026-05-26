# 📝 Logging & Error Handling Guide

## Kasa Vaapraycha (How to Use)

### 1️⃣ Basic Logging

```dart
import '../../core/utils/app_logger.dart';

// Debug info (development madhe)
logger.debug('User tapped on button');

// Important events
logger.info('User logged in successfully');

// Warnings
logger.warning('API response slow: ${duration}ms');

// Errors
logger.error('Failed to load data', error, stackTrace);

// Critical errors
logger.fatal('App crashed!', error, stackTrace);
```

---

### 2️⃣ Error Handling in BLoC

**Before (Juna tarika):**
```dart
try {
  final result = await loginUseCase(params);
  // ...
} catch (e) {
  print('Error: $e'); // ❌ Bad
  emit(AuthError('Something went wrong')); // ❌ Generic message
}
```

**After (Nava tarika):**
```dart
import '../../core/error/error_handler.dart';

try {
  final result = await loginUseCase(params);
  // ...
} catch (e, stackTrace) {
  final userMessage = ErrorHandler.handleError(e, stackTrace);
  emit(AuthError(userMessage)); // ✅ User-friendly message
}
```


### 3️⃣ API Calls madhe Error Handling

```dart
import '../../core/error/error_handler.dart';

Future<Either<Failure, User>> login(LoginParams params) async {
  try {
    final response = await apiClient.post('/auth/login', data: params.toJson());
    logger.info('✅ Login successful for ${params.email}');
    return Right(User.fromJson(response.data));
  } on DioException catch (e, stackTrace) {
    final message = ErrorHandler.handleError(e, stackTrace);
    return Left(ServerFailure(message));
  } catch (e, stackTrace) {
    ErrorHandler.logError('Login', e, stackTrace);
    return Left(ServerFailure('Something went wrong'));
  }
}
```

---

### 4️⃣ Background Tasks madhe Logging

```dart
void _loadUserData() async {
  try {
    final user = await getUserUseCase();
    logger.info('User data loaded: ${user.name}');
  } catch (e, stackTrace) {
    // User la message nahi dakhavaycha, fakt log kara
    ErrorHandler.logError('Load User Data', e, stackTrace);
  }
}
```

---

## 🎯 Benefits (Fayde)

### 1. **Production Safety**
- Development madhe: Sagla log print hoto (debug, info, warning, error)
- Production madhe: Fakt warnings ani errors print hotat
- App size var impact nahi (logger package chota ahe: ~50KB)

### 2. **Better Debugging**
```
┌──────────────────────────────────────────────────────────
│ 💡 INFO: User logged in successfully
├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
│ Email: user@example.com
│ Time: 14:23:45.123
└──────────────────────────────────────────────────────────
```

### 3. **User-Friendly Error Messages**
```dart
// API timeout
"कनेक्शन टाइमआउट. इंटरनेट चेक करा."

// 401 Unauthorized
"अनधिकृत. पुन्हा लॉगिन करा."

// 500 Server Error
"सर्व्हर एरर. नंतर प्रयत्न करा."
```

### 4. **Future-Ready**
Firebase Crashlytics ya Sentry add karaycha asel tar easily karu shakto:

```dart
// error_handler.dart madhe
static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
  logger.error('[$context] Error occurred', error, stackTrace);
  
  // Add crash reporting
  FirebaseCrashlytics.instance.recordError(error, stackTrace);
}
```

---

## 📊 App Size Impact

| Package | Size | Impact |
|---------|------|--------|
| logger | ~50KB | Minimal |
| Total | ~50KB | 0.05MB |

**Conclusion:** App size var almost kahi impact nahi!

---

## 🚀 Quick Reference

| Situation | Use This |
|-----------|----------|
| Debug info | `logger.debug()` |
| Important events | `logger.info()` |
| Potential issues | `logger.warning()` |
| Errors with user message | `ErrorHandler.handleError()` |
| Background errors | `ErrorHandler.logError()` |
| API errors | `ErrorHandler.handleError()` |

---

## ✅ Best Practices

1. **Always catch errors with stackTrace:**
   ```dart
   } catch (e, stackTrace) { // ✅ Good
   ```

2. **Use appropriate log levels:**
   - Debug: Detailed info (button clicks, state changes)
   - Info: Important events (login, logout, navigation)
   - Warning: Potential issues (slow API, deprecated features)
   - Error: Actual errors (API failures, exceptions)

3. **Don't log sensitive data:**
   ```dart
   logger.info('User logged in: ${user.email}'); // ✅ OK
   logger.info('Password: ${password}'); // ❌ NEVER!
   ```

4. **Production madhe print() vaapru naka:**
   ```dart
   print('Debug info'); // ❌ Bad
   logger.debug('Debug info'); // ✅ Good
   ```
