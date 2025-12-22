import '../data/repositories/progress_repository.dart';
import '../../../services/local_storage/storage_service.dart';
import 'debug_service.dart';

/// Centralized service for checking access permissions with debug mode bypass
/// 
/// This service provides a single point of control for all gating logic in the app.
/// When debug mode is enabled, all access checks return true, allowing developers
/// to test any feature without completing prerequisites.
/// 
/// When debug mode is disabled, normal gating logic is enforced:
/// - Phase 1 is always unlocked
/// - Phase 2 requires passing Phase 1 final test
/// - Phase 3 requires passing Phase 2 final test
/// - Phase 4 requires passing Phase 3 final test
/// - Phase 5 requires passing Phase 4 final test
/// - Lessons within a phase require the phase to be unlocked
/// - Final tests require all lessons in the phase to be mastered
class GatingService {
  final StorageService _storageService;
  final ProgressRepository _progressRepository;
  final DebugService _debugService;

  // Storage keys for phase unlock status
  static const String _keyPhase1TestPassed = 'phase1_final_test_passed';
  static const String _keyPhase2TestPassed = 'phase2_final_test_passed';
  static const String _keyPhase3TestPassed = 'phase3_final_test_passed';
  static const String _keyPhase4TestPassed = 'phase4_final_test_passed';
  static const String _keyPhase3Unlocked = 'phase3_unlocked';
  static const String _keyPhase4Unlocked = 'phase4_unlocked';
  static const String _keyPhase5Unlocked = 'phase5_unlocked';

  GatingService({
    required StorageService storageService,
    required ProgressRepository progressRepository,
    required DebugService debugService,
  })  : _storageService = storageService,
        _progressRepository = progressRepository,
        _debugService = debugService;

  /// Check if a phase is unlocked (with debug mode bypass)
  /// 
  /// Returns true if:
  /// - Debug mode is enabled, OR
  /// - Phase 1 (always unlocked), OR
  /// - Phase 2 and Phase 1 final test passed, OR
  /// - Phase 3 and Phase 2 final test passed, OR
  /// - Phase 4 and Phase 3 final test passed, OR
  /// - Phase 5 and Phase 4 final test passed
  /// 
  /// [phaseNumber] - The phase number to check (1-5)
  Future<bool> isPhaseUnlocked(int phaseNumber) async {
    // Debug mode bypass - all phases unlocked
    if (await _debugService.isDebugModeEnabled()) {
      return true;
    }

    // Normal gating logic
    switch (phaseNumber) {
      case 1:
        // Phase 1 is always unlocked
        return true;
      case 2:
        // Phase 2 requires Phase 1 final test passed
        // Check both key formats for compatibility
        final passed1 = _storageService.getBool(_keyPhase1TestPassed) ?? false;
        final passed2 = _storageService.getBool('phase1FinalTestPassed') ?? false;
        final phase2Unlocked = _storageService.getBool('phase2_unlocked') ?? false;
        return passed1 || passed2 || phase2Unlocked;
      case 3:
        // Phase 3 requires Phase 2 final test passed or explicit unlock
        // Check both key formats for compatibility
        final phase2TestPassed1 = _storageService.getBool(_keyPhase2TestPassed) ?? false;
        final phase2TestPassed2 = _storageService.getBool('phase2FinalTestPassed') ?? false;
        final phase3Unlocked = _storageService.getBool(_keyPhase3Unlocked) ?? false;
        return phase2TestPassed1 || phase2TestPassed2 || phase3Unlocked;
      case 4:
        // Phase 4 requires Phase 3 final test passed or explicit unlock
        // Check both key formats for compatibility
        final phase3TestPassed1 = _storageService.getBool(_keyPhase3TestPassed) ?? false;
        final phase3TestPassed2 = _storageService.getBool('phase3FinalTestPassed') ?? false;
        final phase4Unlocked = _storageService.getBool(_keyPhase4Unlocked) ?? false;
        return phase3TestPassed1 || phase3TestPassed2 || phase4Unlocked;
      case 5:
        // Phase 5 requires Phase 4 final test passed or explicit unlock
        // Check both key formats for compatibility
        final phase4TestPassed1 = _storageService.getBool(_keyPhase4TestPassed) ?? false;
        final phase4TestPassed2 = _storageService.getBool('phase4FinalTestPassed') ?? false;
        final phase5Unlocked = _storageService.getBool(_keyPhase5Unlocked) ?? false;
        return phase4TestPassed1 || phase4TestPassed2 || phase5Unlocked;
      default:
        return false;
    }
  }

  /// Check if Phase 5 is unlocked
  /// 
  /// Returns true if and only if phase4FinalTestPassed is true in storage.
  /// This is a convenience method that checks the Phase 4 final test passed status.
  /// 
  /// Note: Debug mode bypass is NOT applied here - this method checks the actual
  /// storage state for Phase 5 unlock status.
  Future<bool> isPhase5Unlocked() async {
    // Check if Phase 4 final test was passed
    // Check both key formats for compatibility
    final phase4TestPassed1 = _storageService.getBool(_keyPhase4TestPassed) ?? false;
    final phase4TestPassed2 = _storageService.getBool('phase4FinalTestPassed') ?? false;
    return phase4TestPassed1 || phase4TestPassed2;
  }

  /// Check if a lesson is unlocked (with debug mode bypass)
  /// 
  /// Returns true if:
  /// - Debug mode is enabled, OR
  /// - The lesson's phase is unlocked
  /// 
  /// [lessonId] - The lesson ID to check (e.g., 'phase1_lesson1', 'phase2_lesson7_1')
  Future<bool> isLessonUnlocked(String lessonId) async {
    // Debug mode bypass - all lessons unlocked
    if (await _debugService.isDebugModeEnabled()) {
      return true;
    }

    // Determine which phase the lesson belongs to
    final phaseNumber = _getPhaseFromLessonId(lessonId);
    if (phaseNumber == null) {
      // Unknown lesson format, default to locked
      return false;
    }

    // Check if the phase is unlocked
    return isPhaseUnlocked(phaseNumber);
  }

  /// Check if final test is accessible (with debug mode bypass)
  /// 
  /// Returns true if:
  /// - Debug mode is enabled, OR
  /// - All required lessons in the phase are mastered
  /// 
  /// [phaseNumber] - The phase number for the final test (1-3)
  Future<bool> isFinalTestAccessible(int phaseNumber) async {
    // Debug mode bypass - all tests accessible
    if (await _debugService.isDebugModeEnabled()) {
      return true;
    }

    // First check if the phase itself is unlocked
    if (!await isPhaseUnlocked(phaseNumber)) {
      return false;
    }

    // Check if all required lessons in the phase are mastered
    return _areAllPhaseLessonsMastered(phaseNumber);
  }

  /// Get the phase number from a lesson ID
  /// 
  /// Returns the phase number (1-4) or null if the format is unrecognized
  int? _getPhaseFromLessonId(String lessonId) {
    if (lessonId.startsWith('phase1_')) {
      return 1;
    } else if (lessonId.startsWith('phase2_')) {
      return 2;
    } else if (lessonId.startsWith('phase3_')) {
      return 3;
    } else if (lessonId.startsWith('phase4_')) {
      return 4;
    }
    return null;
  }

  /// Check if all required lessons in a phase are mastered
  /// 
  /// For Phase 3, Unit 17 (project lessons) are optional
  Future<bool> _areAllPhaseLessonsMastered(int phaseNumber) async {
    try {
      final allProgress = await _progressRepository.loadAllProgress();
      final requiredLessonIds = _getRequiredLessonIds(phaseNumber);

      for (final lessonId in requiredLessonIds) {
        final status = allProgress[lessonId];
        if (status == null || !status.isMastered) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Warning: Failed to check lesson mastery: $e');
      return false;
    }
  }

  /// Get the required lesson IDs for a phase
  /// 
  /// For Phase 3, Unit 17 lessons are excluded (optional for test access)
  List<String> _getRequiredLessonIds(int phaseNumber) {
    switch (phaseNumber) {
      case 1:
        return _getPhase1LessonIds();
      case 2:
        return _getPhase2LessonIds();
      case 3:
        return _getPhase3RequiredLessonIds();
      case 4:
        return _getPhase4RequiredLessonIds();
      default:
        return [];
    }
  }

  /// Get Phase 1 lesson IDs (lesson1 to lesson6)
  List<String> _getPhase1LessonIds() {
    return List.generate(6, (i) => 'phase1_lesson${i + 1}');
  }

  /// Get Phase 2 lesson IDs (lesson7_1 to lesson11_5)
  List<String> _getPhase2LessonIds() {
    final lessonIds = <String>[];

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

    return lessonIds;
  }

  /// Get Phase 3 required lesson IDs (Units 12-16, excluding Unit 17 which is optional)
  List<String> _getPhase3RequiredLessonIds() {
    final lessonIds = <String>[];

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

    // Note: Unit 17 (Speaking & Writing Projects) is optional for test access
    // per Requirement 1.6

    return lessonIds;
  }

  /// Get Phase 4 required lesson IDs (Units 18-21)
  /// 
  /// Phase 4 focuses on Fluency & Pronunciation with 17 lessons total:
  /// - Unit 18: Pronunciation & Sound (4 lessons)
  /// - Unit 19: Fluency Techniques (4 lessons)
  /// - Unit 20: Real-Life Conversations (5 lessons)
  /// - Unit 21: Discussion & Opinion Skills (4 lessons)
  List<String> _getPhase4RequiredLessonIds() {
    final lessonIds = <String>[];

    // Unit 18: Pronunciation & Sound (4 lessons)
    lessonIds.addAll([
      'phase4_lesson18_1',
      'phase4_lesson18_2',
      'phase4_lesson18_3',
      'phase4_lesson18_4',
    ]);

    // Unit 19: Fluency Techniques (4 lessons)
    lessonIds.addAll([
      'phase4_lesson19_1',
      'phase4_lesson19_2',
      'phase4_lesson19_3',
      'phase4_lesson19_4',
    ]);

    // Unit 20: Real-Life Conversations (5 lessons)
    lessonIds.addAll([
      'phase4_lesson20_1',
      'phase4_lesson20_2',
      'phase4_lesson20_3',
      'phase4_lesson20_4',
      'phase4_lesson20_5',
    ]);

    // Unit 21: Discussion & Opinion Skills (4 lessons)
    lessonIds.addAll([
      'phase4_lesson21_1',
      'phase4_lesson21_2',
      'phase4_lesson21_3',
      'phase4_lesson21_4',
    ]);

    return lessonIds;
  }
}

/// Custom exception for gating service errors
class GatingServiceException implements Exception {
  final String message;

  GatingServiceException(this.message);

  @override
  String toString() => 'GatingServiceException: $message';
}
