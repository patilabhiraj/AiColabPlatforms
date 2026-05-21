import 'package:logger/logger.dart';

/// Centralized logging service for the entire app
/// 
/// Benefits:
/// - on Production in logs can disable 
/// - Different log levels (debug, info, warning, error)
/// - Crash reports  logs save 
/// - Performance impact is minimal 
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;

  /// Initialize logger with custom configuration
  void init({bool isProduction = false}) {
    _logger = Logger(
      filter: isProduction ? ProductionFilter() : DevelopmentFilter(),
      printer: PrettyPrinter(
        methodCount: 2, // Stack trace lines
        errorMethodCount: 8, // Error stack trace lines
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: isProduction ? ProductionOutput() : ConsoleOutput(),
    );
  }

  /// Debug level - Development in detailed info
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Info level - Important events (user login, navigation, etc.)
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Warning level - Potential issues
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error level - Errors that need attention
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// only level - Critical errors (app crash)
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

/// Production in only errors print 
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= Level.warning.index;
  }
}

class ProductionOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // on Production  logs file  save 
    //  crash reporting service  send the  (Firebase Crashlytics, Sentry)
    // For now, we'll just suppress console output in production
  }
}

/// Global logger instance - Anywhere use 
final logger = AppLogger();
