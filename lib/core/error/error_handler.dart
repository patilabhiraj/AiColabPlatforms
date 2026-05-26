import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

/// Centralized error handling service

/// Benefits:
/// - Consistent error messages across app
/// - Easy to add crash reporting (Firebase Crashlytics)
/// - User-friendly error messages
/// - Detailed logs for debugging
class ErrorHandler {
  /// Handle any error and return user-friendly message
  static String handleError(dynamic error, [StackTrace? stackTrace]) {
    String userMessage = 'Something went wrong. Please try again.';

    if (error is DioException) {
      userMessage = _handleDioError(error);
      logger.error('API Error: ${error.message}', error, stackTrace);
    } else if (error is FormatException) {
      userMessage = 'Invalid data format';
      logger.error('Format Error: ${error.message}', error, stackTrace);
    } else if (error is TypeError) {
      userMessage = 'Data processing error';
      logger.error('Type Error: ${error.toString()}', error, stackTrace);
    } else {
      logger.error('Unknown Error: ${error.toString()}', error, stackTrace);
    }

    return userMessage;
  }

  /// Handle Dio (API) specific errors
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);

      case DioExceptionType.cancel:
      return 'Request cancelled';

      case DioExceptionType.connectionError:
      return 'No internet connection';

      default:
      return 'Server error. Please try again.';
    }
  }

  /// Handle HTTP status codes
  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
    case 400:
      return 'Bad request';
    case 401:
      return 'Unauthorized. Please login again.';
    case 403:
      return 'Access denied';
    case 404:
      return 'Data not found';
    case 500:
    case 502:
    case 503:
      return 'Server error. Please try later.';
    default:
      return 'Something went wrong (Code: $statusCode)';
  }
  }

  /// Log error without returning message (for background tasks)
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    logger.error('[$context] Error occurred', error, stackTrace);
    
    // Future madhe crash reporting add karu shakto:
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// Log warning
  static void logWarning(String message, [dynamic data]) {
    logger.warning(message, data);
  }

  /// Log info
  static void logInfo(String message, [dynamic data]) {
    logger.info(message, data);
  }
}
