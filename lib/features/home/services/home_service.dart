import '../../learn/data/repositories/lesson_repository.dart';
import '../../learn/data/repositories/progress_repository.dart';
import '../../learn/data/models/user_lesson_status.dart';
import '../../learn/services/gating_service.dart';
import '../../../services/local_storage/storage_service.dart';
import '../../../core/constants/app_config.dart';

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
  })  : _lessonRepo = lessonRepo,
        _progressRepo = progressRepo,
        _storageService = storageService,
        _gatingService = gatingService;

  /// Get progress summary (mastered count and total lessons)
  /// Returns a map with 'masteredCount' and 'totalLessons'
  Future<Map<String, int>> getProgressSummary() async {
    try {
      // Load all lessons from all phases
      int totalLessons = 0;
      
      // Load Phase 1 lessons
      final phase1Lessons = await _lessonRepo.loadUnitLessons('phase1');
      totalLessons += phase1Lessons.length;
      
      // Load Phase 2 lessons (Units 7-11)
      final phase2Units = ['phase2_unit7', 'phase2_unit8', 'phase2_unit9', 'phase2_unit10', 'phase2_unit11'];
      for (final unitId in phase2Units) {
        try {
          final unitLessons = await _lessonRepo.loadUnitLessons(unitId);
          totalLessons += unitLessons.length;
        } catch (e) {
          // Log but continue loading other units
          print('Warning: Failed to load $unitId: $e');
        }
      }
      
      // Load Phase 3 lessons (Units 12-17)
      final phase3Units = ['phase3_unit12', 'phase3_unit13', 'phase3_unit14', 'phase3_unit15', 'phase3_unit16', 'phase3_unit17'];
      for (final unitId in phase3Units) {
        try {
          final unitLessons = await _lessonRepo.loadUnitLessons(unitId);
          totalLessons += unitLessons.length;
        } catch (e) {
          // Log but continue loading other units
          print('Warning: Failed to load $unitId: $e');
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

      return {
        'masteredCount': masteredCount,
        'totalLessons': totalLessons,
      };
    } catch (e) {
      throw HomeServiceException('Failed to get progress summary: $e');
    }
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
        return {
          'lesson': null,
          'status': null,
        };
      }

      // Load the lesson details
      final lesson = await _lessonRepo.loadLesson(lastAccessedStatus.lessonId);

      return {
        'lesson': lesson,
        'status': lastAccessedStatus,
      };
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
    // Development mode: unlock all phases
    if (AppConfig.isDevelopmentMode) {
      return true;
    }
    
    // Use GatingService if available (includes debug mode bypass)
    if (_gatingService != null) {
      try {
        return await _gatingService.isPhaseUnlocked(2);
      } catch (e) {
        print('Warning: GatingService error, falling back to direct check: $e');
      }
    }
    
    // Fallback to direct storage check
    try {
      final passed = _storageService.getBool('phase1_final_test_passed');
      return passed ?? false;
    } catch (e) {
      // If there's an error reading storage, assume Phase 2 is locked
      return false;
    }
  }

  /// Check if Phase 3 is unlocked
  /// Uses GatingService for centralized access control with debug mode bypass
  /// Falls back to direct storage check if GatingService is not available
  /// In development mode, always returns true
  /// 
  /// Requirements: 12.1, 12.6, 12.7
  Future<bool> isPhase3Unlocked() async {
    // Development mode: unlock all phases
    if (AppConfig.isDevelopmentMode) {
      return true;
    }
    
    // Use GatingService if available (includes debug mode bypass)
    if (_gatingService != null) {
      try {
        return await _gatingService.isPhaseUnlocked(3);
      } catch (e) {
        print('Warning: GatingService error, falling back to direct check: $e');
      }
    }
    
    // Fallback to direct storage check
    try {
      final unlocked = _storageService.getBool('phase3_unlocked');
      return unlocked ?? false;
    } catch (e) {
      // If there's an error reading storage, assume Phase 3 is locked
      return false;
    }
  }

  /// Check if Phase 2 final test has been passed
  /// Returns true if the test was passed
  Future<bool> hasPassedPhase2FinalTest() async {
    try {
      final passed = _storageService.getBool('phase2_final_test_passed');
      return passed ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get Phase 2 final test score
  /// Returns null if no test has been taken
  Future<int?> getPhase2FinalTestScore() async {
    try {
      return _storageService.getInt('phase2_final_test_score');
    } catch (e) {
      return null;
    }
  }

  /// Check if Phase 4 is unlocked
  /// Uses GatingService for centralized access control with debug mode bypass
  /// Falls back to direct storage check if GatingService is not available
  /// In development mode, always returns true
  /// 
  /// Requirements: 7.4, 7.9, 12.1, 12.6, 12.7
  Future<bool> isPhase4Unlocked() async {
    // Development mode: unlock all phases
    if (AppConfig.isDevelopmentMode) {
      return true;
    }
    
    // Use GatingService if available (includes debug mode bypass)
    if (_gatingService != null) {
      try {
        return await _gatingService.isPhaseUnlocked(4);
      } catch (e) {
        print('Warning: GatingService error, falling back to direct check: $e');
      }
    }
    
    // Fallback to direct storage check
    try {
      final phase3TestPassed = _storageService.getBool('phase3_final_test_passed') ?? false;
      final phase4Unlocked = _storageService.getBool('phase4_unlocked') ?? false;
      return phase3TestPassed || phase4Unlocked;
    } catch (e) {
      // If there's an error reading storage, assume Phase 4 is locked
      return false;
    }
  }

  /// Check if Phase 3 final test has been passed
  /// Returns true if the test was passed
  /// 
  /// Requirements: 7.4, 7.9
  Future<bool> hasPassedPhase3FinalTest() async {
    try {
      final passed = _storageService.getBool('phase3_final_test_passed');
      return passed ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get Phase 3 final test score
  /// Returns null if no test has been taken
  Future<int?> getPhase3FinalTestScore() async {
    try {
      return _storageService.getInt('phase3_final_test_score');
    } catch (e) {
      return null;
    }
  }
}

/// Custom exception for home service errors
class HomeServiceException implements Exception {
  final String message;

  HomeServiceException(this.message);

  @override
  String toString() => 'HomeServiceException: $message';
}
