import '../../learn/data/repositories/lesson_repository.dart';
import '../../learn/data/repositories/progress_repository.dart';
import '../../learn/data/models/user_lesson_status.dart';
import '../../learn/services/gating_service.dart';
import '../../../services/local_storage/storage_service.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/logging/app_logger.dart';

/// Service for home screen data operations
/// Provides progress summary and last accessed lesson information
class HomeService {
  final LessonRepository _lessonRepo;
  final ProgressRepository _progressRepo;
  final StorageService _storageService;
  final GatingService? _gatingService;

  HomeService({
    required LessonRepository lessonRepo,
    required ProgressRepository progressRepo,
    required StorageService storageService,
    GatingService? gatingService,
  }) : _lessonRepo = lessonRepo,
       _progressRepo = progressRepo,
       _storageService = storageService,
       _gatingService = gatingService;

  /// Get progress summary (mastered count and total lessons)
  /// Returns a map with 'masteredCount' and 'totalLessons'
  Future<Map<String, int>> getProgressSummary() async {
    try {
      // Load all lessons from all phases
      int totalLessons = 0;
      for (int phase = 1; phase <= 5; phase++) {
        try {
          final phaseLessons = await _lessonRepo.loadLessonsForPhase(phase);
          totalLessons += phaseLessons.length;
        } catch (e) {
          AppLogger.warning(
            'Failed to load phase $phase lessons',
            tag: 'HomeService',
            error: e,
          );
        }
      }

      // Load all progress
      final allProgress = await _progressRepo.loadAllProgress();

      // Count mastered lessons
      int masteredCount = 0;
      for (var status in allProgress.values) {
        if (status.isMastered) {
          masteredCount++;
        }
      }

      return {'masteredCount': masteredCount, 'totalLessons': totalLessons};
    } catch (e) {
      throw HomeServiceException('Failed to get progress summary: $e');
    }
  }

  Future<Map<int, int>> getPhaseLessonCounts() async {
    final counts = <int, int>{};
    for (int phase = 1; phase <= 5; phase++) {
      try {
        counts[phase] = (await _lessonRepo.loadLessonsForPhase(phase)).length;
      } catch (_) {
        counts[phase] = 0;
      }
    }
    return counts;
  }

  Future<Map<int, bool>> getPhaseUnlockStatusFromAssets() async {
    final counts = await getPhaseLessonCounts();
    final unlockMap = <int, bool>{};

    for (final entry in counts.entries) {
      final phaseNumber = entry.key;
      if (entry.value <= 0) continue;

      if (AppConfig.devMode) {
        unlockMap[phaseNumber] = true;
        continue;
      }

      if (_gatingService != null) {
        try {
          unlockMap[phaseNumber] = await _gatingService.isPhaseUnlocked(
            phaseNumber,
          );
          continue;
        } catch (e, stackTrace) {
          AppLogger.warning(
            'GatingService failed for phase $phaseNumber; '
            'falling back to storage check',
            tag: 'HomeService',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      unlockMap[phaseNumber] = _isPhaseUnlockedFromStorage(phaseNumber);
    }

    return unlockMap;
  }

  Future<Map<int, PhaseFinalTestStatus>> getPhaseFinalTestStatusFromAssets()
  async {
    final counts = await getPhaseLessonCounts();
    final testMap = <int, PhaseFinalTestStatus>{};

    for (final entry in counts.entries) {
      final phaseNumber = entry.key;
      if (entry.value <= 0) continue;

      testMap[phaseNumber] = PhaseFinalTestStatus(
        passed: _isPhaseTestPassedFromStorage(phaseNumber),
        score: _storageService.getInt('phase${phaseNumber}_final_test_score'),
      );
    }

    return testMap;
  }

  bool _isPhaseUnlockedFromStorage(int phaseNumber) {
    if (phaseNumber <= 1) return true;

    final explicitUnlock =
        _storageService.getBool('phase${phaseNumber}_unlocked') ?? false;
    final previousPhasePassed = _isPhaseTestPassedFromStorage(phaseNumber - 1);
    return explicitUnlock || previousPhasePassed;
  }

  bool _isPhaseTestPassedFromStorage(int phaseNumber) {
    final snake =
        _storageService.getBool('phase${phaseNumber}_final_test_passed') ??
        false;
    final camel =
        _storageService.getBool('phase${phaseNumber}FinalTestPassed') ?? false;
    return snake || camel;
  }

  /// Get last accessed lesson with its status
  /// Returns a map with 'lesson' and 'status' keys
  /// Returns null values if no lesson has been accessed
  Future<Map<String, dynamic>> getLastAccessedLesson() async {
    try {
      // Load all progress
      final allProgress = await _progressRepo.loadAllProgress();

      // Find the most recently accessed lesson
      UserLessonStatus? lastAccessedStatus;
      DateTime? latestTime;

      for (var status in allProgress.values) {
        if (status.lastAccessed != null) {
          if (latestTime == null || status.lastAccessed!.isAfter(latestTime)) {
            latestTime = status.lastAccessed;
            lastAccessedStatus = status;
          }
        }
      }

      // If no lesson has been accessed, return null values
      if (lastAccessedStatus == null) {
        return {'lesson': null, 'status': null};
      }

      // Load the lesson details
      final lesson = await _lessonRepo.loadLesson(lastAccessedStatus.lessonId);

      return {'lesson': lesson, 'status': lastAccessedStatus};
    } catch (e) {
      throw HomeServiceException('Failed to get last accessed lesson: $e');
    }
  }

  /// Check if Phase 2 is unlocked
  /// Uses GatingService for centralized access control with debug mode bypass
  /// Falls back to direct storage check if GatingService is not available
  /// In development mode, always returns true
  ///
  /// Requirements: 12.1, 12.6, 12.7
  Future<bool> isPhase2Unlocked() async {
    final map = await getPhaseUnlockStatusFromAssets();
    return map[2] ?? false;
  }

  /// Check if Phase 3 is unlocked
  /// Uses GatingService for centralized access control with debug mode bypass
  /// Falls back to direct storage check if GatingService is not available
  /// In development mode, always returns true
  ///
  /// Requirements: 12.1, 12.6, 12.7
  Future<bool> isPhase3Unlocked() async {
    final map = await getPhaseUnlockStatusFromAssets();
    return map[3] ?? false;
  }

  /// Check if Phase 2 final test has been passed
  /// Returns true if the test was passed
  Future<bool> hasPassedPhase2FinalTest() async {
    final map = await getPhaseFinalTestStatusFromAssets();
    return map[2]?.passed ?? false;
  }

  /// Get Phase 2 final test score
  /// Returns null if no test has been taken
  Future<int?> getPhase2FinalTestScore() async {
    final map = await getPhaseFinalTestStatusFromAssets();
    return map[2]?.score;
  }

  /// Check if Phase 4 is unlocked
  /// Uses GatingService for centralized access control with debug mode bypass
  /// Falls back to direct storage check if GatingService is not available
  /// In development mode, always returns true
  ///
  /// Requirements: 7.4, 7.9, 12.1, 12.6, 12.7
  Future<bool> isPhase4Unlocked() async {
    final map = await getPhaseUnlockStatusFromAssets();
    return map[4] ?? false;
  }

  /// Check if Phase 5 is unlocked
  /// Uses GatingService for centralized access control with debug mode bypass
  /// Falls back to direct storage check if GatingService is not available
  /// In development mode, always returns true
  Future<bool> isPhase5Unlocked() async {
    final map = await getPhaseUnlockStatusFromAssets();
    return map[5] ?? false;
  }

  /// Check if Phase 3 final test has been passed
  /// Returns true if the test was passed
  ///
  /// Requirements: 7.4, 7.9
  Future<bool> hasPassedPhase3FinalTest() async {
    final map = await getPhaseFinalTestStatusFromAssets();
    return map[3]?.passed ?? false;
  }

  /// Get Phase 3 final test score
  /// Returns null if no test has been taken
  Future<int?> getPhase3FinalTestScore() async {
    final map = await getPhaseFinalTestStatusFromAssets();
    return map[3]?.score;
  }
}

class PhaseFinalTestStatus {
  final bool passed;
  final int? score;

  const PhaseFinalTestStatus({required this.passed, required this.score});
}

/// Custom exception for home service errors
class HomeServiceException implements Exception {
  final String message;

  HomeServiceException(this.message);

  @override
  String toString() => 'HomeServiceException: $message';
}
