# Error Handling Documentation

## Overview

This document describes the comprehensive error handling implementation in the Engliya app. The error handling system provides user-friendly feedback, retry logic, and graceful degradation when errors occur.

## Error Types

### 1. LessonLoadException
- **Cause**: Asset loading failures, missing JSON files, malformed JSON
- **User Message**: "Unable to load lesson. Please restart the app."
- **Handling**: Display error screen with retry button

### 2. ProgressLoadException
- **Cause**: Failed to load progress data from local storage
- **User Message**: "Unable to load your progress. Please try again."
- **Handling**: Retry with exponential backoff, show error if all retries fail

### 3. ProgressSaveException
- **Cause**: Failed to save progress data to local storage
- **User Message**: "Progress not saved. Please try again."
- **Handling**: Automatic retry (2 attempts), non-blocking (app continues)

### 4. StorageException
- **Cause**: SharedPreferences initialization or operation failures
- **User Message**: "Storage error occurred. Please try again."
- **Handling**: Retry logic in repositories

### 5. TtsException
- **Cause**: Text-to-speech initialization or playback failures
- **User Message**: "Audio playback is currently unavailable."
- **Handling**: Graceful degradation - app continues without audio

## Error Handler Utility

Location: `lib/core/utils/error_handler.dart`

### Methods

#### getUserMessage(dynamic error)
Converts technical exceptions into user-friendly messages.

```dart
final message = ErrorHandler.getUserMessage(error);
// Returns: "Unable to load lesson. Please restart the app."
```

#### showErrorSnackbar(BuildContext context, dynamic error)
Displays error message in a red snackbar with "OK" action.

```dart
ErrorHandler.showErrorSnackbar(context, error);
```

#### showSuccessSnackbar(BuildContext context, String message)
Displays success message in a green snackbar.

```dart
ErrorHandler.showSuccessSnackbar(context, 'Progress saved!');
```

#### showInfoSnackbar(BuildContext context, String message)
Displays informational message in a blue snackbar.

```dart
ErrorHandler.showInfoSnackbar(context, 'Audio unavailable');
```

#### logError(String context, dynamic error, [StackTrace? stackTrace])
Logs errors for debugging purposes.

```dart
ErrorHandler.logError('LessonProvider.loadLesson', error, stackTrace);
```

## Retry Logic

### Progress Save Retry
- **Attempts**: 2 retries
- **Delay**: 100ms * retry count (exponential backoff)
- **Location**: `LessonProvider._saveProgressWithRetry()`

```dart
Future<void> _saveProgressWithRetry(UserLessonStatus status) async {
  int retryCount = 0;
  const maxRetries = 2;

  while (retryCount < maxRetries) {
    try {
      await _progressRepo.saveLessonProgress(status);
      return; // Success
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        rethrow; // Give up after max retries
      }
      await Future.delayed(Duration(milliseconds: 100 * retryCount));
    }
  }
}
```

### Progress Load Retry
- **Attempts**: 2 retries
- **Delay**: 100ms * retry count
- **Location**: `ProgressProvider._loadProgressWithRetry()`

## UI Error Handling

### Lesson Screen
- Shows loading indicator while loading
- Shows error screen with retry button on failure
- Displays user-friendly error message

### Home Screen
- Shows loading indicator while loading
- Shows error screen with retry button on failure
- Supports pull-to-refresh for retry

### Phase1 Unit Screen
- Shows loading indicator while loading
- Shows error screen with retry button on failure
- Displays user-friendly error message

### Audio Tabs (Examples, Listen)
- Initializes TTS on tab load
- Shows snackbar if TTS initialization fails
- Disables audio buttons if TTS unavailable
- Shows info message when user tries to play audio with TTS unavailable

## Error Scenarios and Testing

### 1. Missing JSON File
**Scenario**: Lesson JSON file doesn't exist
**Expected**: 
- LessonLoadException thrown
- Error screen shown with "Unable to load lesson" message
- Retry button available

**Test**: Delete a lesson JSON file and try to load it

### 2. Malformed JSON
**Scenario**: Lesson JSON has invalid syntax
**Expected**:
- LessonLoadException thrown
- Error screen shown with "Unable to load lesson" message
- Retry button available

**Test**: Corrupt a lesson JSON file and try to load it

### 3. Storage Failure
**Scenario**: SharedPreferences fails to save
**Expected**:
- ProgressSaveException thrown
- Automatic retry (2 attempts)
- Snackbar shown if all retries fail
- App continues to function

**Test**: Mock SharedPreferences to throw exception

### 4. TTS Unavailable
**Scenario**: Text-to-speech engine fails to initialize
**Expected**:
- TtsException thrown
- Snackbar shown: "Audio playback is currently unavailable"
- Audio buttons disabled
- App continues without audio

**Test**: Mock FlutterTts to throw exception

### 5. Network Unavailable (Future)
**Scenario**: No internet connection (for future backend integration)
**Expected**:
- Offline mode continues to work
- Sync errors shown when attempting to sync

## Best Practices

### 1. Always Use ErrorHandler
```dart
// Good
try {
  await someOperation();
} catch (e) {
  ErrorHandler.logError('Context', e);
  ErrorHandler.showErrorSnackbar(context, e);
}

// Bad
try {
  await someOperation();
} catch (e) {
  print('Error: $e'); // Don't use print directly
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')), // Don't show technical errors
  );
}
```

### 2. Retry for Transient Errors
```dart
// Good - retry for storage operations
await _saveProgressWithRetry(status);

// Bad - no retry for transient failures
await _progressRepo.saveLessonProgress(status);
```

### 3. Graceful Degradation
```dart
// Good - continue without audio
if (_ttsUnavailable) {
  ErrorHandler.showInfoSnackbar(context, 'Audio unavailable');
  return;
}

// Bad - block user from continuing
if (_ttsUnavailable) {
  throw Exception('Cannot continue without audio');
}
```

### 4. User-Friendly Messages
```dart
// Good
ErrorHandler.getUserMessage(error);
// Returns: "Unable to load lesson. Please restart the app."

// Bad
error.toString();
// Returns: "LessonLoadException: Asset not found for lesson: phase1_lesson1..."
```

## Future Enhancements

1. **Error Analytics**: Track error frequency and types
2. **Offline Queue**: Queue failed operations for retry when conditions improve
3. **Error Recovery**: Automatic recovery strategies for common errors
4. **User Feedback**: Allow users to report errors with context
5. **Crash Reporting**: Integration with crash reporting service (e.g., Sentry, Firebase Crashlytics)
