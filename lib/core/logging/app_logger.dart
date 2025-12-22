import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class AppLogger {
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static bool _enabled = true;

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled || level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';
    
    final buffer = StringBuffer();
    buffer.write('$timestamp $levelStr $tagStr$message');
    
    if (error != null) {
      buffer.write('\nError: $error');
    }
    
    if (stackTrace != null) {
      buffer.write('\nStackTrace:\n$stackTrace');
    }

    if (kDebugMode) {
      debugPrint(buffer.toString());
    }
  }
}

class ScopedLogger {
  final String tag;

  const ScopedLogger(this.tag);

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.debug(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.info(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.warning(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(message, tag: tag, error: error, stackTrace: stackTrace);
  }
}
