# Error Handling Quick Reference

## Import
```dart
import 'package:engliya/core/utils/error_handler.dart';
```

## Common Patterns

### 1. Show Error to User
```dart
try {
  await someOperation();
} catch (e) {
  ErrorHandler.logError('MyClass.myMethod', e);
  ErrorHandler.showErrorSnackbar(context, e);
}
```

### 2. Show Success Message
```dart
ErrorHandler.showSuccessSnackbar(context, 'Progress saved!');
```

### 3. Show Info Message
```dart
ErrorHandler.showInfoSnackbar(context, 'Feature coming soon');
```

### 4. Retry Logic
```dart
Future<void> _operationWithRetry() async {
  int retryCount = 0;
  const maxRetries = 2;

  while (retryCount < maxRetries) {
    try {
      await someOperation();
      return; // Success
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        rethrow;
      }
      await Future.delayed(Duration(milliseconds: 100 * retryCount));
    }
  }
}
```

### 5. Graceful Degradation (TTS)
```dart
bool _featureUnavailable = false;

Future<void> _initFeature() async {
  try {
    await feature.init();
  } catch (e) {
    ErrorHandler.logError('MyClass.initFeature', e);
    setState(() {
      _featureUnavailable = true;
    });
    if (mounted) {
      ErrorHandler.showErrorSnackbar(context, e);
    }
  }
}

void _useFeature() {
  if (_featureUnavailable) {
    ErrorHandler.showInfoSnackbar(context, 'Feature unavailable');
    return;
  }
  // Use feature
}
```

### 6. Error Screen with Retry
```dart
if (provider.error != null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(provider.error!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
```

## Custom Exceptions

### Throw Custom Exception
```dart
throw LessonLoadException('Failed to load lesson: $lessonId');
throw ProgressSaveException('Failed to save progress');
throw TtsException('TTS initialization failed');
```

### Catch Specific Exception
```dart
try {
  await lessonRepo.loadLesson(id);
} on LessonLoadException catch (e) {
  // Handle lesson load error specifically
  ErrorHandler.showErrorSnackbar(context, e);
} catch (e) {
  // Handle other errors
  ErrorHandler.showErrorSnackbar(context, e);
}
```

## User Messages

| Exception | User Message |
|-----------|-------------|
| LessonLoadException | "Unable to load lesson. Please restart the app." |
| ProgressLoadException | "Unable to load your progress. Please try again." |
| ProgressSaveException | "Progress not saved. Please try again." |
| StorageException | "Storage error occurred. Please try again." |
| TtsException | "Audio playback is currently unavailable." |
| Unknown | "An unexpected error occurred. Please try again." |

## Best Practices

✅ **DO**: Use ErrorHandler for all user-facing errors
✅ **DO**: Log errors with context using ErrorHandler.logError()
✅ **DO**: Implement retry logic for transient failures
✅ **DO**: Use graceful degradation for non-critical features
✅ **DO**: Show user-friendly messages

❌ **DON'T**: Use print() for error logging
❌ **DON'T**: Show technical error messages to users
❌ **DON'T**: Block the app for non-critical errors
❌ **DON'T**: Ignore errors silently
