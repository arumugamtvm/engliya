import 'package:flutter/material.dart';
import '../../features/learn/data/repositories/lesson_repository.dart';
import '../../features/learn/data/repositories/progress_repository.dart';
import '../../features/learn/services/test_exceptions.dart';
import '../../features/learn/services/debug_service.dart';
import '../../features/learn/services/gating_service.dart';
import '../../services/local_storage/storage_service.dart';
import '../logging/app_logger.dart';

/// Centralized error handling utility
/// Provides user-friendly error messages and feedback
/// 
/// Handles errors from:
/// - Lesson loading (LessonLoadException)
/// - Progress operations (ProgressLoadException, ProgressSaveException)
/// - Storage operations (StorageException)
/// - Audio/TTS (TtsException)
/// - Test generation (TestGenerationException, InsufficientQuestionsException)
/// - Test storage (TestStorageException)
/// - Debug mode operations (DebugServiceException)
/// - Gating/access control (GatingServiceException)
/// - Navigation errors
class ErrorHandler {
  /// Get user-friendly error message from exception
  /// 
  /// Maps specific exception types to user-friendly messages.
  /// Falls back to a generic message for unknown exceptions.
  static String getUserMessage(dynamic error) {
    // Lesson loading errors
    if (error is LessonLoadException) {
      return 'Unable to load lesson. Please restart the app.';
    }
    
    // Progress errors
    if (error is ProgressLoadException) {
      return 'Unable to load your progress. Please try again.';
    }
    if (error is ProgressSaveException) {
      return 'Progress not saved. Please try again.';
    }
    
    // Storage errors
    if (error is StorageException) {
      return 'Storage error occurred. Please try again.';
    }
    
    // Audio/TTS errors
    if (error is TtsException) {
      return 'Audio playback is currently unavailable.';
    }
    
    // Test generation errors
    if (error is TestGenerationException) {
      return 'Failed to load test content. Please try again.';
    }
    if (error is InsufficientQuestionsException) {
      return 'Not enough questions available. Please complete more lessons.';
    }
    
    // Test storage errors
    if (error is TestStorageException) {
      return 'Unable to save test results. Your progress may not be saved.';
    }
    
    // Debug mode errors
    if (error is DebugServiceException) {
      return 'Debug operation failed. Please try again.';
    }
    
    // Gating/access control errors
    if (error is GatingServiceException) {
      return 'Unable to check access permissions. Please try again.';
    }
    
    // Navigation errors - check for common navigation exception patterns
    if (error.toString().contains('Navigator') || 
        error.toString().contains('Route') ||
        error.toString().contains('navigation')) {
      return 'Navigation error occurred. Please go back and try again.';
    }
    
    // Generic fallback
    return 'An unexpected error occurred. Please try again.';
  }

  /// Show error snackbar to user
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final message = getUserMessage(error);
    showSnackbar(context, message, isError: true);
  }

  /// Show success snackbar to user
  static void showSuccessSnackbar(BuildContext context, String message) {
    showSnackbar(context, message, isError: false);
  }

  /// Show generic snackbar
  static void showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Log error for debugging
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('[$context]: $error', tag: 'ErrorHandler', error: error, stackTrace: stackTrace);
  }

  /// Show error snackbar with retry action
  /// 
  /// Displays an error message with a retry button that calls [onRetry] when pressed.
  /// Useful for recoverable errors like network failures or storage issues.
  static void showErrorSnackbarWithRetry(
    BuildContext context,
    dynamic error, {
    required VoidCallback onRetry,
    String retryLabel = 'Retry',
    Duration duration = const Duration(seconds: 5),
  }) {
    if (!context.mounted) return;

    final message = getUserMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: retryLabel,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onRetry();
          },
        ),
      ),
    );
  }

  /// Show error dialog with optional retry
  /// 
  /// Displays a modal dialog with error details and optional retry button.
  /// Use for critical errors that require user acknowledgment.
  static Future<bool> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool showRetry = true,
    String retryLabel = 'Retry',
    String dismissLabel = 'OK',
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dismissLabel),
          ),
          if (showRetry)
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(retryLabel),
            ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show warning snackbar (non-critical issues)
  /// 
  /// Use for warnings that don't prevent the user from continuing,
  /// such as partial save failures or degraded functionality.
  static void showWarningSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
              )
            : null,
      ),
    );
  }

  /// Check if an error is recoverable (can be retried)
  /// 
  /// Returns true for errors that might succeed on retry,
  /// such as network timeouts or temporary storage issues.
  static bool isRecoverableError(dynamic error) {
    // Storage errors are often recoverable
    if (error is StorageException) return true;
    if (error is TestStorageException) return true;
    if (error is ProgressSaveException) return true;
    
    // Test generation might succeed on retry
    if (error is TestGenerationException) return true;
    
    // Debug operations might succeed on retry
    if (error is DebugServiceException) return true;
    
    // Check for common recoverable error patterns
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('timeout') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('temporary')) {
      return true;
    }
    
    return false;
  }

  /// Wrap an async operation with error handling
  /// 
  /// Executes [operation] and handles any errors by logging and
  /// optionally showing a snackbar. Returns null on error.
  /// 
  /// Example:
  /// ```dart
  /// final result = await ErrorHandler.wrapAsync(
  ///   context,
  ///   'Loading data',
  ///   () => myService.loadData(),
  ///   showSnackbar: true,
  /// );
  /// ```
  static Future<T?> wrapAsync<T>(
    BuildContext context,
    String operationName,
    Future<T> Function() operation, {
    bool showSnackbar = true,
    VoidCallback? onRetry,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError(operationName, e, stackTrace);
      
      if (showSnackbar && context.mounted) {
        if (onRetry != null && isRecoverableError(e)) {
          showErrorSnackbarWithRetry(context, e, onRetry: onRetry);
        } else {
          showErrorSnackbar(context, e);
        }
      }
      
      return null;
    }
  }
}

/// Custom exception for TTS errors
class TtsException implements Exception {
  final String message;

  TtsException(this.message);

  @override
  String toString() => 'TtsException: $message';
}
