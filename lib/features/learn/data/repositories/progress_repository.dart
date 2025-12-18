import '../models/user_lesson_status.dart';
import '../../../../services/local_storage/storage_service.dart';

/// Repository for managing user progress data
/// Handles loading, saving, and initializing progress using local storage
class ProgressRepository {
  final StorageService _storage;

  // Storage key for progress data
  static const String _progressKey = 'user_progress';

  ProgressRepository(this._storage);

  /// Load all progress data for all lessons
  /// Returns a map of lessonId -> UserLessonStatus
  /// Returns empty map if no progress data exists
  Future<Map<String, UserLessonStatus>> loadAllProgress() async {
    try {
      final progressJson = _storage.getJson(_progressKey);

      if (progressJson == null) {
        return {};
      }

      // Convert JSON map to UserLessonStatus map
      final progressMap = <String, UserLessonStatus>{};

      progressJson.forEach((lessonId, statusJson) {
        try {
          if (statusJson is Map<String, dynamic>) {
            progressMap[lessonId] = UserLessonStatus.fromJson(statusJson);
          }
        } catch (e) {
          // Log error but continue loading other progress entries
          print('Warning: Failed to parse progress for $lessonId: $e');
        }
      });

      return progressMap;
    } on StorageException catch (e) {
      throw ProgressLoadException(
        'Failed to load progress from storage: ${e.message}',
      );
    } catch (e) {
      throw ProgressLoadException('Unexpected error loading progress: $e');
    }
  }

  /// Load progress for a specific lesson
  /// Returns null if no progress exists for the lesson
  Future<UserLessonStatus?> loadLessonProgress(String lessonId) async {
    try {
      final allProgress = await loadAllProgress();
      return allProgress[lessonId];
    } catch (e) {
      throw ProgressLoadException(
        'Failed to load progress for lesson $lessonId: $e',
      );
    }
  }

  /// Save progress for a specific lesson
  /// Merges with existing progress data
  Future<void> saveLessonProgress(UserLessonStatus status) async {
    try {
      // Load existing progress
      final allProgress = await loadAllProgress();

      // Update or add the lesson progress
      allProgress[status.lessonId] = status;

      // Save back to storage
      await saveAllProgress(allProgress);
    } on StorageException catch (e) {
      throw ProgressSaveException(
        'Failed to save progress for lesson ${status.lessonId}: ${e.message}',
      );
    } catch (e) {
      throw ProgressSaveException(
        'Unexpected error saving progress for lesson ${status.lessonId}: $e',
      );
    }
  }

  /// Save all progress data
  /// Overwrites existing progress data
  Future<void> saveAllProgress(Map<String, UserLessonStatus> progress) async {
    try {
      // Convert UserLessonStatus map to JSON map
      final progressJson = <String, dynamic>{};

      progress.forEach((lessonId, status) {
        progressJson[lessonId] = status.toJson();
      });

      // Save to storage with retry logic
      await _saveWithRetry(progressJson);
    } on StorageException catch (e) {
      throw ProgressSaveException(
        'Failed to save all progress: ${e.message}',
      );
    } catch (e) {
      throw ProgressSaveException('Unexpected error saving all progress: $e');
    }
  }

  /// Save with retry logic (one retry attempt)
  Future<void> _saveWithRetry(Map<String, dynamic> progressJson) async {
    try {
      await _storage.setJson(_progressKey, progressJson);
    } catch (e) {
      // Retry once
      print('First save attempt failed, retrying...');
      await Future.delayed(const Duration(milliseconds: 100));
      await _storage.setJson(_progressKey, progressJson);
    }
  }

  /// Initialize default progress for a new lesson
  /// Returns a UserLessonStatus with all values set to defaults
  UserLessonStatus initializeProgress(String lessonId) {
    return UserLessonStatus(
      lessonId: lessonId,
      explainDone: false,
      examplesDone: false,
      listeningScore: 0.0,
      speakingScore: 0.0,
      quizBestScore: 0.0,
      masteryBestScore: 0.0,
      isMastered: false,
      lastAccessed: null,
    );
  }

  /// Check if progress exists for a lesson
  Future<bool> hasProgress(String lessonId) async {
    try {
      final progress = await loadLessonProgress(lessonId);
      return progress != null;
    } catch (e) {
      return false;
    }
  }

  /// Delete progress for a specific lesson
  Future<void> deleteLessonProgress(String lessonId) async {
    try {
      final allProgress = await loadAllProgress();
      allProgress.remove(lessonId);
      await saveAllProgress(allProgress);
    } catch (e) {
      throw ProgressSaveException(
        'Failed to delete progress for lesson $lessonId: $e',
      );
    }
  }

  /// Clear all progress data
  Future<void> clearAllProgress() async {
    try {
      await _storage.remove(_progressKey);
    } on StorageException catch (e) {
      throw ProgressSaveException('Failed to clear all progress: ${e.message}');
    } catch (e) {
      throw ProgressSaveException('Unexpected error clearing all progress: $e');
    }
  }

  /// Get progress statistics
  Future<ProgressStats> getProgressStats() async {
    try {
      final allProgress = await loadAllProgress();

      int totalLessons = allProgress.length;
      int masteredLessons = 0;
      int inProgressLessons = 0;

      for (var status in allProgress.values) {
        if (status.isMastered) {
          masteredLessons++;
        } else if (status.explainDone || status.examplesDone) {
          inProgressLessons++;
        }
      }

      return ProgressStats(
        totalLessons: totalLessons,
        masteredLessons: masteredLessons,
        inProgressLessons: inProgressLessons,
      );
    } catch (e) {
      throw ProgressLoadException('Failed to get progress stats: $e');
    }
  }
}

/// Statistics about user progress
class ProgressStats {
  final int totalLessons;
  final int masteredLessons;
  final int inProgressLessons;

  ProgressStats({
    required this.totalLessons,
    required this.masteredLessons,
    required this.inProgressLessons,
  });

  int get notStartedLessons =>
      totalLessons - masteredLessons - inProgressLessons;
}

/// Custom exception for progress loading errors
class ProgressLoadException implements Exception {
  final String message;

  ProgressLoadException(this.message);

  @override
  String toString() => 'ProgressLoadException: $message';
}

/// Custom exception for progress saving errors
class ProgressSaveException implements Exception {
  final String message;

  ProgressSaveException(this.message);

  @override
  String toString() => 'ProgressSaveException: $message';
}
