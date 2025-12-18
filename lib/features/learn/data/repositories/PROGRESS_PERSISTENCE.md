# Progress Persistence and Restoration

This document explains how progress persistence and restoration works in the Engliya app.

## Overview

The app implements a robust progress persistence system that ensures user progress is:
- Saved automatically after each tab completion
- Loaded on app startup
- Restored after app restart
- Maintained when navigating between screens
- Preserved when the app goes to background

## Architecture

### Components

1. **StorageService** (`lib/services/local_storage/storage_service.dart`)
   - Low-level storage abstraction using SharedPreferences
   - Provides JSON serialization/deserialization
   - Handles storage errors with exceptions

2. **ProgressRepository** (`lib/features/learn/data/repositories/progress_repository.dart`)
   - Manages progress data persistence
   - Implements retry logic for save operations
   - Provides methods for loading, saving, and querying progress

3. **ProgressProvider** (`lib/features/learn/presentation/providers/progress_provider.dart`)
   - State management for progress data
   - Loads all progress on initialization
   - Tracks unlock status and mastery

4. **LessonProvider** (`lib/features/learn/presentation/providers/lesson_provider.dart`)
   - Manages current lesson state
   - Saves progress after each tab completion
   - Updates lastAccessed timestamp

## Progress Persistence Flow

### 1. App Startup

```
main.dart
  ├─ Initialize StorageService
  ├─ Create ProgressProvider
  ├─ Pre-load progress data (await progressProvider.loadAllData())
  └─ Wrap app with AppLifecycleManager
```

**Key Implementation:**
```dart
// Pre-load progress data on app startup
final progressProvider = ProgressProvider(
  progressRepository: progressRepository,
  lessonRepository: lessonRepository,
);
await progressProvider.loadAllData();
```

### 2. Tab Completion

When a user completes a tab (e.g., Explain, Examples, Listen):

```
Tab Widget (e.g., ExplainTab)
  ├─ User completes activity
  ├─ Call provider method (e.g., markExplainDone())
  └─ LessonProvider
      ├─ Update status in memory
      ├─ Call saveProgress()
      └─ ProgressRepository
          ├─ Load existing progress
          ├─ Merge with updated status
          ├─ Save to storage (with retry)
          └─ Return success/error
```

**Key Implementation:**
```dart
void markExplainDone() {
  if (_currentStatus != null) {
    _currentStatus!.explainDone = true;
    saveProgress(); // Saves immediately
    notifyListeners();
  }
}
```

### 3. Lesson Access Tracking

When a user opens a lesson:

```
LessonProvider.loadLesson()
  ├─ Load lesson data
  ├─ Load or initialize progress
  ├─ Update lastAccessed = DateTime.now()
  └─ Save progress
```

**Key Implementation:**
```dart
// Update last accessed time
_currentStatus!.lastAccessed = DateTime.now();
await saveProgress();
```

### 4. Navigation Back

When user navigates back from a lesson:

```
LessonScreen (WillPopScope)
  ├─ User presses back button
  ├─ Save progress before pop
  └─ Phase1UnitScreen
      └─ Reload progress data
```

**Key Implementation:**
```dart
WillPopScope(
  onWillPop: () async {
    await lessonProvider.saveProgress();
    return true;
  },
  // ...
)
```

### 5. App Lifecycle Events

The AppLifecycleManager handles app state changes:

```
AppLifecycleManager
  ├─ App goes to background (paused/inactive)
  │   └─ Save current lesson progress
  └─ App returns to foreground (resumed)
      └─ Reload all progress data
```

**Key Implementation:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    _saveProgressOnPause();
  }
  if (state == AppLifecycleState.resumed) {
    _reloadProgressOnResume();
  }
}
```

## Data Storage Format

Progress is stored in SharedPreferences with key `user_progress`:

```json
{
  "phase1_lesson1": {
    "lessonId": "phase1_lesson1",
    "explainDone": true,
    "examplesDone": true,
    "listeningScore": 0.8,
    "speakingScore": 0.85,
    "quizBestScore": 0.9,
    "masteryBestScore": 0.9,
    "isMastered": true,
    "lastAccessed": "2025-11-24T10:30:00.000Z"
  },
  "phase1_lesson2": {
    "lessonId": "phase1_lesson2",
    "explainDone": false,
    "examplesDone": false,
    "listeningScore": 0.0,
    "speakingScore": 0.0,
    "quizBestScore": 0.0,
    "masteryBestScore": 0.0,
    "isMastered": false,
    "lastAccessed": null
  }
}
```

## Error Handling

### Save Failures

The repository implements retry logic:

```dart
Future<void> _saveWithRetry(Map<String, dynamic> progressJson) async {
  try {
    await _storage.setJson(_progressKey, progressJson);
  } catch (e) {
    // Retry once after 100ms delay
    await Future.delayed(const Duration(milliseconds: 100));
    await _storage.setJson(_progressKey, progressJson);
  }
}
```

### Load Failures

If progress loading fails:
- Empty map is returned (no progress)
- App continues with default state
- User can retry from UI

## Testing

The implementation includes comprehensive tests:

1. **Progress saves and loads correctly**
   - Verifies all fields persist

2. **Progress persists across repository instances**
   - Simulates app restart

3. **Last accessed lesson tracking**
   - Verifies most recent lesson is tracked

4. **Progress updates when lesson is mastered**
   - Verifies state transitions

5. **Multiple lessons progress maintained independently**
   - Verifies no data corruption

Run tests with:
```bash
flutter test test/widget_test.dart
```

## Verification Checklist

✅ Progress saves after each tab completion
✅ Progress loads on app startup
✅ Progress restores after app restart
✅ Unlock status persists correctly
✅ Last accessed lesson tracking works
✅ Progress saves when app goes to background
✅ Progress reloads when app resumes
✅ Progress refreshes after returning from lesson
✅ Error handling with retry logic
✅ Comprehensive test coverage

## Future Improvements

1. **Batch Updates**: Group multiple progress updates to reduce storage writes
2. **Cloud Sync**: Add backend integration for cross-device sync
3. **Conflict Resolution**: Handle conflicts when syncing from multiple devices
4. **Progress Analytics**: Track detailed learning patterns
5. **Backup/Restore**: Allow users to backup and restore progress
