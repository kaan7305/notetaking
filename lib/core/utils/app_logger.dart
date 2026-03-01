import 'package:flutter/foundation.dart';

/// Log severity levels.
enum LogLevel { debug, info, warning, error }

/// Lightweight structured logger for StudyNotebook.
///
/// Usage:
/// ```dart
/// AppLogger.info('Page loaded', tag: 'PageProvider');
/// AppLogger.error('DB write failed', error: e, stackTrace: st, tag: 'StrokeDao');
/// ```
///
/// In debug builds all levels are printed.
/// In release builds only [LogLevel.warning] and [LogLevel.error] are printed
/// so routine debug/info noise is suppressed in production.
class AppLogger {
  AppLogger._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  static void debug(String message, {String? tag, Object? data}) =>
      _log(LogLevel.debug, message, tag: tag, data: data);

  static void info(String message, {String? tag, Object? data}) =>
      _log(LogLevel.info, message, tag: tag, data: data);

  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(LogLevel.warning, message,
          tag: tag, error: error, stackTrace: stackTrace);

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(LogLevel.error, message,
          tag: tag, error: error, stackTrace: stackTrace);

  /// Called from [FlutterError.onError] to capture framework exceptions.
  static void onFlutterError(FlutterErrorDetails details) {
    error(
      'Flutter framework error: ${details.exceptionAsString()}',
      tag: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
    // Always forward to the default handler so the standard red error screen
    // and crash reports still work in debug builds.
    FlutterError.presentError(details);
  }

  /// Called from [PlatformDispatcher.instance.onError] to capture unhandled
  /// async exceptions that escape the zone.
  static bool onPlatformError(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Unhandled platform error: $error',
      tag: 'PlatformDispatcher',
      error: error,
      stackTrace: stackTrace,
    );
    // Return false to let the default handler also run.
    return false;
  }

  // -------------------------------------------------------------------------
  // Internal
  // -------------------------------------------------------------------------

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // In release mode skip debug/info output.
    if (!kDebugMode && level.index < LogLevel.warning.index) return;

    final prefix = _levelPrefix(level);
    final tagPart = tag != null ? ' [$tag]' : '';
    final dataPart = data != null ? '\n  data: $data' : '';
    final errorPart = error != null ? '\n  error: $error' : '';
    final stackPart =
        stackTrace != null ? '\n  stackTrace:\n${_truncateStack(stackTrace)}' : '';

    debugPrint('$prefix$tagPart $message$dataPart$errorPart$stackPart');
  }

  static String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 [DEBUG]';
      case LogLevel.info:
        return 'ℹ️  [INFO]';
      case LogLevel.warning:
        return '⚠️  [WARN]';
      case LogLevel.error:
        return '🔴 [ERROR]';
    }
  }

  /// Limits the stack trace to the first 10 frames to keep logs readable.
  static String _truncateStack(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    final truncated = lines.take(10).join('\n');
    if (lines.length > 10) {
      return '$truncated\n  ... (${lines.length - 10} more frames)';
    }
    return truncated;
  }
}
