import '../data/models/user_lesson_status.dart';
import '../data/repositories/progress_repository.dart';
import '../../../services/local_storage/storage_service.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/logging/app_logger.dart';

/// Service for managing debug mode operations
/// Provides functionality to bypass gating logic, unlock all content, and reset progress
///
/// Debug mode is activated by long-pressing the app title 5 times consecutively
/// When enabled, all phases and lessons become accessible regardless of completion status
class DebugService {
  final StorageService _storageService;
  final ProgressRepository _progressRepository;

  // Storage key for debug mode state
  static const String _keyDebugMode = 'debug_mode_enabled';

  // Number of consecutive taps required to activate debug mode
  static const int activationTapCount = 5;

  // Storage keys for phase unlock status
  static const String _keyPhase1TestPassed = 'phase1_final_test_passed';
  static const String _keyPhase2TestPassed = 'phase2_final_test_passed';
  static const String _keyPhase3TestPassed = 'phase3_final_test_passed';
  static const String _keyPhase4TestPassed = 'phase4_final_test_passed';
  static const String _keyPhase5TestPassed = 'phase5_final_test_passed';
  static const String _keyPhase2Unlocked = 'phase2_unlocked';
  static const String _keyPhase3Unlocked = 'phase3_unlocked';
  static const String _keyPhase4Unlocked = 'phase4_unlocked';
  static const String _keyPhase5Unlocked = 'phase5_unlocked';

  // Storage keys for test scores
  static const String _keyPhase1TestScore = 'phase1_final_test_score';
  static const String _keyPhase2TestScore = 'phase2_final_test_score';
  static const String _keyPhase3TestScore = 'phase3_final_test_score';

  DebugService({
    required StorageService storageService,
    required ProgressRepository progressRepository,
  }) : _storageService = storageService,
       _progressRepository = progressRepository;

  /// Check if debug mode is currently enabled
  /// Returns false if the value cannot be read from storage
  Future<bool> isDebugModeEnabled() async {
    if (AppConfig.devMode) return true;
    try {
      return _storageService.getBool(_keyDebugMode) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Enable or disable debug mode
  /// Persists the setting across app sessions
  ///
  /// Throws [DebugServiceException] if the operation fails
  Future<void> setDebugMode(bool enabled) async {
    // Dev mode is code-level only.
    // Keep this method for compatibility with existing call sites.
    try {
      await _storageService.setBool(_keyDebugMode, enabled);
      AppLogger.debug('Debug mode ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      AppLogger.error('Error: Failed to set debug mode: $e');
      throw DebugServiceException(
        'Failed to ${enabled ? 'enable' : 'disable'} debug mode',
      );
    }
  }

  /// Unlock all phases and mark all lessons as mastered
  ///
  /// This operation:
  /// - Sets all phase final test passed flags to true
  /// - Sets all phase unlock flags to true
  /// - Creates/updates UserLessonStatus for every lesson with mastered status
  ///
  /// Throws [DebugServiceException] if the operation fails
  Future<void> unlockAll() async {
    try {
      // Set all phase test passed flags (both key formats for compatibility)
      await _storageService.setBool(_keyPhase1TestPassed, true);
      await _storageService.setBool('phase1FinalTestPassed', true);
      await _storageService.setBool(_keyPhase2TestPassed, true);
      await _storageService.setBool('phase2FinalTestPassed', true);
      await _storageService.setBool(_keyPhase3TestPassed, true);
      await _storageService.setBool('phase3FinalTestPassed', true);
      await _storageService.setBool(_keyPhase4TestPassed, true);
      await _storageService.setBool('phase4FinalTestPassed', true);
      await _storageService.setBool(_keyPhase5TestPassed, true);
      await _storageService.setBool('phase5FinalTestPassed', true);

      // Set all phase unlock flags
      await _storageService.setBool(_keyPhase2Unlocked, true);
      await _storageService.setBool(_keyPhase3Unlocked, true);
      await _storageService.setBool(_keyPhase4Unlocked, true);
      await _storageService.setBool(_keyPhase5Unlocked, true);

      // Get all lesson IDs and create mastered status for each
      final allLessonIds = _getAllLessonIds();
      final now = DateTime.now();

      // Load existing progress to preserve any additional data
      final existingProgress = await _progressRepository.loadAllProgress();

      // Create/update mastered status for all lessons
      for (final lessonId in allLessonIds) {
        final masteredStatus = UserLessonStatus(
          lessonId: lessonId,
          explainDone: true,
          examplesDone: true,
          listeningScore: 1.0,
          speakingScore: 1.0,
          quizBestScore: 1.0,
          masteryBestScore: 1.0,
          isMastered: true,
          lastAccessed: now,
        );
        existingProgress[lessonId] = masteredStatus;
      }

      // Save all progress at once
      await _progressRepository.saveAllProgress(existingProgress);

      AppLogger.debug(
        'All content unlocked successfully: ${allLessonIds.length} lessons mastered',
      );
    } catch (e) {
      AppLogger.error('Error: Failed to unlock all content: $e');
      throw DebugServiceException('Failed to unlock all content: $e');
    }
  }

  /// Reset all progress to a fresh state
  ///
  /// This operation:
  /// - Clears all UserLessonStatus data
  /// - Sets all phase test passed flags to false
  /// - Clears all test scores
  /// - Sets all phase unlock flags to false
  /// - Disables debug mode
  ///
  /// Throws [DebugServiceException] if the operation fails
  Future<void> resetAll() async {
    try {
      // Clear all lesson progress
      await _progressRepository.clearAllProgress();

      // Reset all phase test passed flags (both key formats for compatibility)
      await _storageService.setBool(_keyPhase1TestPassed, false);
      await _storageService.setBool('phase1FinalTestPassed', false);
      await _storageService.setBool(_keyPhase2TestPassed, false);
      await _storageService.setBool('phase2FinalTestPassed', false);
      await _storageService.setBool(_keyPhase3TestPassed, false);
      await _storageService.setBool('phase3FinalTestPassed', false);
      await _storageService.setBool(_keyPhase4TestPassed, false);
      await _storageService.setBool('phase4FinalTestPassed', false);
      await _storageService.setBool(_keyPhase5TestPassed, false);
      await _storageService.setBool('phase5FinalTestPassed', false);

      // Clear all test scores (remove the keys)
      try {
        await _storageService.remove(_keyPhase1TestScore);
      } catch (_) {
        // Key might not exist, ignore
      }
      try {
        await _storageService.remove(_keyPhase2TestScore);
      } catch (_) {
        // Key might not exist, ignore
      }
      try {
        await _storageService.remove(_keyPhase3TestScore);
      } catch (_) {
        // Key might not exist, ignore
      }

      // Reset all phase unlock flags
      await _storageService.setBool(_keyPhase2Unlocked, false);
      await _storageService.setBool(_keyPhase3Unlocked, false);
      await _storageService.setBool(_keyPhase4Unlocked, false);
      await _storageService.setBool(_keyPhase5Unlocked, false);

      // Disable debug mode
      await _storageService.setBool(_keyDebugMode, false);

      AppLogger.debug('All progress reset successfully');
    } catch (e) {
      AppLogger.error('Error: Failed to reset all progress: $e');
      throw DebugServiceException('Failed to reset all progress: $e');
    }
  }

  /// Get all lesson IDs across all phases
  ///
  /// Returns lesson IDs for:
  /// - Phase 1: lesson1 to lesson6
  /// - Phase 2: lesson7_1 to lesson11_5
  /// - Phase 3: lesson12_1 to lesson17_5
  /// - Phase 4: lesson18_1 to lesson21_4
  /// - Phase 5: lesson22_1 to lesson25_4
  List<String> _getAllLessonIds() {
    final lessonIds = <String>[];

    // Phase 1 lessons (lesson1 to lesson6)
    for (int i = 1; i <= 6; i++) {
      lessonIds.add('phase1_lesson$i');
    }

    // Phase 2 lessons (lesson7_1 to lesson11_5)
    // Unit 7: Time and Place Prepositions (3 lessons)
    lessonIds.addAll([
      'phase2_lesson7_1',
      'phase2_lesson7_2',
      'phase2_lesson7_3',
    ]);

    // Unit 8: Continuous Tenses (4 lessons)
    lessonIds.addAll([
      'phase2_lesson8_1',
      'phase2_lesson8_2',
      'phase2_lesson8_3',
      'phase2_lesson8_4',
    ]);

    // Unit 9: Perfect Tenses (5 lessons)
    lessonIds.addAll([
      'phase2_lesson9_1',
      'phase2_lesson9_2',
      'phase2_lesson9_3',
      'phase2_lesson9_4',
      'phase2_lesson9_5',
    ]);

    // Unit 10: Questions and Negatives (5 lessons)
    lessonIds.addAll([
      'phase2_lesson10_1',
      'phase2_lesson10_2',
      'phase2_lesson10_3',
      'phase2_lesson10_4',
      'phase2_lesson10_5',
    ]);

    // Unit 11: Pronouns, Adjectives, Adverbs (5 lessons)
    lessonIds.addAll([
      'phase2_lesson11_1',
      'phase2_lesson11_2',
      'phase2_lesson11_3',
      'phase2_lesson11_4',
      'phase2_lesson11_5',
    ]);

    // Phase 3 lessons (lesson12_1 to lesson17_5)
    // Unit 12: Story Listening & Retelling (4 lessons)
    lessonIds.addAll([
      'phase3_lesson12_1',
      'phase3_lesson12_2',
      'phase3_lesson12_3',
      'phase3_lesson12_4',
    ]);

    // Unit 13: Complex Sentences & Connectors (5 lessons)
    lessonIds.addAll([
      'phase3_lesson13_1',
      'phase3_lesson13_2',
      'phase3_lesson13_3',
      'phase3_lesson13_4',
      'phase3_lesson13_5',
    ]);

    // Unit 14: Passive Voice (4 lessons)
    lessonIds.addAll([
      'phase3_lesson14_1',
      'phase3_lesson14_2',
      'phase3_lesson14_3',
      'phase3_lesson14_4',
    ]);

    // Unit 15: Reported Speech (4 lessons)
    lessonIds.addAll([
      'phase3_lesson15_1',
      'phase3_lesson15_2',
      'phase3_lesson15_3',
      'phase3_lesson15_4',
    ]);

    // Unit 16: Functional English (5 lessons)
    lessonIds.addAll([
      'phase3_lesson16_1',
      'phase3_lesson16_2',
      'phase3_lesson16_3',
      'phase3_lesson16_4',
      'phase3_lesson16_5',
    ]);

    // Unit 17: Speaking & Writing Projects (5 lessons)
    lessonIds.addAll([
      'phase3_lesson17_1',
      'phase3_lesson17_2',
      'phase3_lesson17_3',
      'phase3_lesson17_4',
      'phase3_lesson17_5',
    ]);

    // Phase 4 lessons (lesson18_1 to lesson21_4)
    // Unit 18: Pronunciation (4 lessons)
    lessonIds.addAll([
      'phase4_lesson18_1',
      'phase4_lesson18_2',
      'phase4_lesson18_3',
      'phase4_lesson18_4',
    ]);

    // Unit 19: Fluency Building (4 lessons)
    lessonIds.addAll([
      'phase4_lesson19_1',
      'phase4_lesson19_2',
      'phase4_lesson19_3',
      'phase4_lesson19_4',
    ]);

    // Unit 20: Real-Life Situations (5 lessons)
    lessonIds.addAll([
      'phase4_lesson20_1',
      'phase4_lesson20_2',
      'phase4_lesson20_3',
      'phase4_lesson20_4',
      'phase4_lesson20_5',
    ]);

    // Unit 21: Discussions & Opinions (4 lessons)
    lessonIds.addAll([
      'phase4_lesson21_1',
      'phase4_lesson21_2',
      'phase4_lesson21_3',
      'phase4_lesson21_4',
    ]);

    // Phase 5 lessons (lesson22_1 to lesson25_4)
    // Unit 22: Professional Communication (4 lessons)
    lessonIds.addAll([
      'phase5_lesson22_1',
      'phase5_lesson22_2',
      'phase5_lesson22_3',
      'phase5_lesson22_4',
    ]);

    // Unit 23: Interviews (4 lessons)
    lessonIds.addAll([
      'phase5_lesson23_1',
      'phase5_lesson23_2',
      'phase5_lesson23_3',
      'phase5_lesson23_4',
    ]);

    // Unit 24: Presentations (4 lessons)
    lessonIds.addAll([
      'phase5_lesson24_1',
      'phase5_lesson24_2',
      'phase5_lesson24_3',
      'phase5_lesson24_4',
    ]);

    // Unit 25: Academic Writing (4 lessons)
    lessonIds.addAll([
      'phase5_lesson25_1',
      'phase5_lesson25_2',
      'phase5_lesson25_3',
      'phase5_lesson25_4',
    ]);

    return lessonIds;
  }
}

/// Custom exception for debug service errors
class DebugServiceException implements Exception {
  final String message;

  DebugServiceException(this.message);

  @override
  String toString() => 'DebugServiceException: $message';
}
