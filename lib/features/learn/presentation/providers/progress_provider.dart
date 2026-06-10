import 'package:flutter/foundation.dart';
import '../../data/models/lesson.dart';
import '../../data/models/user_lesson_status.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/entities/phase_config.dart';
import '../../domain/entities/phase_units.dart';
import '../../domain/entities/unit.dart';
import '../../services/gating_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../services/local_storage/storage_service.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/logging/app_logger.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepo;
  final LessonRepository _lessonRepo;
  final StorageService _storageService;
  final GatingService? _gatingService;

  // Cached phase unlock status (updated asynchronously)
  bool _isPhase2UnlockedCached = false;
  bool _isPhase3UnlockedCached = false;
  bool _isPhase4UnlockedCached = false;
  bool _isPhase5UnlockedCached = false;

  ProgressProvider({
    required ProgressRepository progressRepo,
    required LessonRepository lessonRepo,
    required StorageService storageService,
    GatingService? gatingService,
  }) : _progressRepo = progressRepo,
       _lessonRepo = lessonRepo,
       _storageService = storageService,
       _gatingService = gatingService;

  Map<String, UserLessonStatus> _allProgress = {};
  List<Lesson> _allLessons = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, UserLessonStatus> get allProgress => _allProgress;
  List<Lesson> get allLessons => _allLessons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get masteredCount {
    return _allProgress.values.where((status) => status.isMastered).length;
  }

  int get totalLessons => _allLessons.length;

  String? get lastAccessedLessonId {
    UserLessonStatus? lastAccessed;
    DateTime? latestTime;

    for (var status in _allProgress.values) {
      if (status.lastAccessed != null) {
        if (latestTime == null || status.lastAccessed!.isAfter(latestTime)) {
          latestTime = status.lastAccessed;
          lastAccessed = status;
        }
      }
    }

    return lastAccessed?.lessonId;
  }

  // Phase 2 specific getters

  /// Check if Phase 2 is unlocked (synchronous getter using cached value)
  /// Uses GatingService for centralized access control with debug mode bypass
  /// In development mode, always returns true
  ///
  /// Note: This is a synchronous getter that uses cached values.
  /// Call refreshPhaseUnlockStatus() to update the cache from GatingService.
  ///
  /// Requirements: 12.1, 12.6, 12.7
  bool get isPhase2Unlocked {
    if (AppConfig.devMode) return true;
    return _isPhase2UnlockedCached || _isPhaseUnlockedInStorage(2);
  }

  /// Check if Phase 3 is unlocked (synchronous getter using cached value)
  /// Uses GatingService for centralized access control with debug mode bypass
  /// In development mode, always returns true
  ///
  /// Note: This is a synchronous getter that uses cached values.
  /// Call refreshPhaseUnlockStatus() to update the cache from GatingService.
  ///
  /// Requirements: 12.1, 12.6, 12.7
  bool get isPhase3Unlocked {
    if (AppConfig.devMode) return true;
    return _isPhase3UnlockedCached || _isPhaseUnlockedInStorage(3);
  }

  /// Check if Phase 4 is unlocked (synchronous getter using cached value)
  /// Uses GatingService for centralized access control with debug mode bypass
  /// In development mode, always returns true
  ///
  /// Note: This is a synchronous getter that uses cached values.
  /// Call refreshPhaseUnlockStatus() to update the cache from GatingService.
  ///
  /// Requirements: 1.1, 1.3
  bool get isPhase4Unlocked {
    if (AppConfig.devMode) return true;
    return _isPhase4UnlockedCached || _isPhaseUnlockedInStorage(4);
  }

  bool get isPhase5Unlocked {
    if (AppConfig.devMode) return true;
    return _isPhase5UnlockedCached || _isPhaseUnlockedInStorage(5);
  }

  /// Refresh phase unlock status from GatingService
  /// Should be called when loading data or when debug mode changes
  ///
  /// Requirements: 12.1, 12.6, 12.7
  Future<void> refreshPhaseUnlockStatus() async {
    if (_gatingService != null) {
      try {
        _isPhase2UnlockedCached = await _gatingService.isPhaseUnlocked(2);
        _isPhase3UnlockedCached = await _gatingService.isPhaseUnlocked(3);
        _isPhase4UnlockedCached = await _gatingService.isPhaseUnlocked(4);
        _isPhase5UnlockedCached = await _gatingService.isPhaseUnlocked(5);
      } catch (e) {
        AppLogger.debug(
          'Warning: Failed to refresh phase unlock status from GatingService: $e',
        );
        // Fall back to direct storage check
        _refreshPhaseUnlockStatusFromStorage();
      }
    } else {
      // Fall back to direct storage check if GatingService not available
      _refreshPhaseUnlockStatusFromStorage();
    }
  }

  /// Fallback method to refresh phase unlock status directly from storage.
  ///
  /// Uses the same storage keys as [GatingService.isPhaseUnlocked]:
  /// the canonical 'phaseN_final_test_passed' key (written when a final test
  /// passes), the legacy camelCase key (backward compatibility), and the
  /// explicit 'phaseN_unlocked' flag.
  void _refreshPhaseUnlockStatusFromStorage() {
    _isPhase2UnlockedCached = _isPhaseUnlockedInStorage(2);
    _isPhase3UnlockedCached = _isPhaseUnlockedInStorage(3);
    _isPhase4UnlockedCached = _isPhaseUnlockedInStorage(4);
    _isPhase5UnlockedCached = _isPhaseUnlockedInStorage(5);
  }

  /// Synchronous storage check for whether [phase] (2-5) is unlocked.
  ///
  /// Used both as the fallback refresh source and directly by the
  /// isPhaseNUnlocked getters so unlock state is correct even before the
  /// async GatingService refresh completes (e.g. right after construction).
  bool _isPhaseUnlockedInStorage(int phase) {
    bool read(String key) => _storageService.getBool(key) ?? false;

    switch (phase) {
      case 2:
        return read(GatingService.keyPhase1TestPassed) ||
            read(GatingService.legacyKeyPhase1TestPassed) ||
            read(GatingService.keyPhase2Unlocked);
      case 3:
        return read(GatingService.keyPhase2TestPassed) ||
            read(GatingService.legacyKeyPhase2TestPassed) ||
            read(GatingService.keyPhase3Unlocked);
      case 4:
        return read(GatingService.keyPhase3TestPassed) ||
            read(GatingService.legacyKeyPhase3TestPassed) ||
            read(GatingService.keyPhase4Unlocked);
      case 5:
        return read(GatingService.keyPhase4TestPassed) ||
            read(GatingService.legacyKeyPhase4TestPassed) ||
            read(GatingService.keyPhase5Unlocked);
      default:
        return false;
    }
  }

  /// Get Phase 2 progress summary
  /// Returns the count of mastered lessons out of total Phase 2 lessons
  Phase2Progress get phase2Progress {
    final phase2Lessons = _allLessons.where(
      (l) => l.unitId.startsWith('phase2_unit'),
    );

    final mastered = phase2Lessons
        .where((l) => _allProgress[l.id]?.isMastered ?? false)
        .length;

    return Phase2Progress(
      totalLessons: phase2Lessons.length,
      masteredLessons: mastered,
    );
  }

  /// Get Phase 3 progress summary
  /// Returns the count of mastered lessons out of total Phase 3 lessons
  Phase3Progress get phase3Progress {
    final phase3Lessons = _allLessons.where(
      (l) => l.unitId.startsWith('phase3_unit'),
    );

    final mastered = phase3Lessons
        .where((l) => _allProgress[l.id]?.isMastered ?? false)
        .length;

    return Phase3Progress(
      totalLessons: phase3Lessons.length,
      masteredLessons: mastered,
    );
  }

  /// Get Phase 4 progress summary
  /// Returns the count of mastered lessons out of total Phase 4 lessons
  Phase4Progress get phase4Progress {
    final phase4Lessons = _allLessons.where(
      (l) => l.unitId.startsWith('phase4_unit'),
    );

    final mastered = phase4Lessons
        .where((l) => _allProgress[l.id]?.isMastered ?? false)
        .length;

    return Phase4Progress(
      totalLessons: phase4Lessons.length,
      masteredLessons: mastered,
    );
  }

  Phase4Progress get phase5Progress {
    final phase5Lessons = _allLessons.where(
      (l) => l.unitId.startsWith('phase5_unit'),
    );
    final mastered = phase5Lessons
        .where((l) => _allProgress[l.id]?.isMastered ?? false)
        .length;

    return Phase4Progress(
      totalLessons: phase5Lessons.length,
      masteredLessons: mastered,
    );
  }

  // Load all data with error handling and retry
  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Refresh phase unlock status from GatingService (includes debug mode bypass)
      // Requirements: 12.1, 12.6, 12.7
      await refreshPhaseUnlockStatus();

      // Load all lessons from whatever phase assets are actually bundled.
      final allLessonsById = <String, Lesson>{};
      for (int phase = 1; phase <= 5; phase++) {
        try {
          final phaseLessons = await _lessonRepo.loadLessonsForPhase(phase);
          for (final lesson in phaseLessons) {
            allLessonsById[lesson.id] = lesson;
          }
        } catch (e) {
          AppLogger.warning('Warning: Failed to load phase $phase lessons: $e');
        }
      }

      _allLessons = allLessonsById.values.toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));

      // Load all progress with retry
      _allProgress = await _loadProgressWithRetry();

      // Initialize progress for lessons that don't have it
      bool needsSave = false;
      for (var lesson in _allLessons) {
        if (!_allProgress.containsKey(lesson.id)) {
          _allProgress[lesson.id] = _progressRepo.initializeProgress(lesson.id);
          needsSave = true;
        }
      }

      // Save initialized progress if needed
      if (needsSave) {
        await _saveProgressWithRetry(_allProgress);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('ProgressProvider.loadAllData', e);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw so UI can handle it
    }
  }

  // Load progress with retry logic
  Future<Map<String, UserLessonStatus>> _loadProgressWithRetry() async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount < maxRetries) {
      try {
        return await _progressRepo.loadAllProgress();
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 100 * retryCount));
      }
    }
    return {}; // Should never reach here
  }

  // Save progress with retry logic
  Future<void> _saveProgressWithRetry(
    Map<String, UserLessonStatus> progress,
  ) async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount < maxRetries) {
      try {
        await _progressRepo.saveAllProgress(progress);
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

  /// Get all lessons for a specific unit
  /// Filters lessons by unitId and returns them sorted by order
  List<Lesson> getUnitLessons(String unitId) {
    return _allLessons.where((lesson) => lesson.unitId == unitId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<Unit> getUnitsForPhase(PhaseType phaseType) {
    final phasePrefix = 'phase${_phaseNumberFromType(phaseType)}_';
    final phaseLessons = _allLessons
        .where((lesson) => lesson.id.startsWith(phasePrefix))
        .toList(growable: false);

    final lessonsByUnit = <String, List<Lesson>>{};
    for (final lesson in phaseLessons) {
      lessonsByUnit.putIfAbsent(lesson.unitId, () => <Lesson>[]).add(lesson);
    }

    final units = lessonsByUnit.entries.map((entry) {
      final unitId = entry.key;
      final lessons = entry.value..sort((a, b) => a.order.compareTo(b.order));
      final unitOrder = _extractUnitOrder(unitId) ?? lessons.first.order;
      final unitDef = PhaseUnits.findById(unitId);
      final masteredCount = lessons
          .where((lesson) => _allProgress[lesson.id]?.isMastered ?? false)
          .length;

      return Unit(
        id: unitId,
        order: unitOrder,
        title: unitDef?.title ?? 'Unit $unitOrder',
        description:
            unitDef?.description ?? '${lessons.length} lessons available',
        lessonCount: lessons.length,
        masteredCount: masteredCount,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));

    return units;
  }

  int? _extractUnitOrder(String unitId) {
    final match = RegExp(r'_unit(\d+)$').firstMatch(unitId);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  int _phaseNumberFromType(PhaseType phaseType) {
    switch (phaseType) {
      case PhaseType.phase1:
        return 1;
      case PhaseType.phase2:
        return 2;
      case PhaseType.phase3:
        return 3;
      case PhaseType.phase4:
        return 4;
      case PhaseType.phase5:
        return 5;
    }
  }

  /// Check if a lesson is unlocked
  /// Uses cached phase unlock status which is updated via GatingService
  /// This includes debug mode bypass when GatingService is configured
  ///
  /// Requirements: 12.2, 12.6, 12.7
  bool isLessonUnlocked(String lessonId) {
    // Development mode: all lessons are unlocked
    if (AppConfig.devMode) {
      return true;
    }

    // Phase 1 logic
    if (lessonId.startsWith('phase1_')) {
      // Find the lesson
      final lesson = _allLessons.firstWhere(
        (l) => l.id == lessonId,
        orElse: () => throw Exception('Lesson not found: $lessonId'),
      );

      // First lesson is always unlocked
      if (lesson.order == 1) {
        return true;
      }

      // Check if previous lesson is mastered
      final previousLesson = _allLessons.firstWhere(
        (l) => l.order == lesson.order - 1,
        orElse: () => throw Exception('Previous lesson not found'),
      );

      final previousStatus = _allProgress[previousLesson.id];
      return previousStatus?.isMastered ?? false;
    }

    // Phase 2 logic - uses cached isPhase2Unlocked which respects debug mode
    if (lessonId.startsWith('phase2_')) {
      // Check if Phase 2 is unlocked (uses GatingService via cached value)
      if (!isPhase2Unlocked) return false;

      // First lesson of Phase 2 is unlocked by default
      if (lessonId == 'phase2_lesson7_1') return true;

      // Find previous lesson
      final previousLessonId = _getPreviousLessonId(lessonId);
      if (previousLessonId == null) return false;

      // Check if previous lesson is mastered
      final previousStatus = _allProgress[previousLessonId];
      return previousStatus?.isMastered ?? false;
    }

    // Phase 3 logic - uses cached isPhase3Unlocked which respects debug mode
    if (lessonId.startsWith('phase3_')) {
      // Check if Phase 3 is unlocked (uses GatingService via cached value)
      if (!isPhase3Unlocked) return false;

      // First lesson of Phase 3 (Unit 12, Lesson 1) is unlocked by default
      if (lessonId == 'phase3_lesson12_1') return true;

      // Find previous lesson
      final previousLessonId = _getPhase3PreviousLessonId(lessonId);
      if (previousLessonId == null) return false;

      // Check if previous lesson is mastered
      final previousStatus = _allProgress[previousLessonId];
      return previousStatus?.isMastered ?? false;
    }

    // Phase 4 logic - uses cached isPhase4Unlocked which respects debug mode
    if (lessonId.startsWith('phase4_')) {
      // Check if Phase 4 is unlocked (uses GatingService via cached value)
      if (!isPhase4Unlocked) return false;

      // First lesson of Phase 4 (Unit 18, Lesson 1) is unlocked by default
      if (lessonId == 'phase4_lesson18_1') return true;

      // Find previous lesson
      final previousLessonId = _getPhase4PreviousLessonId(lessonId);
      if (previousLessonId == null) return false;

      // Check if previous lesson is mastered
      final previousStatus = _allProgress[previousLessonId];
      return previousStatus?.isMastered ?? false;
    }

    // Phase 5 logic - uses cached isPhase5Unlocked
    if (lessonId.startsWith('phase5_')) {
      if (!isPhase5Unlocked) return false;

      if (lessonId == 'phase5_lesson22_1') return true;

      final previousLessonId = _getPhase5PreviousLessonId(lessonId);
      if (previousLessonId == null) return false;

      final previousStatus = _allProgress[previousLessonId];
      return previousStatus?.isMastered ?? false;
    }

    return false;
  }

  /// Get the previous lesson ID in the Phase 2 sequence
  /// Returns null if this is the first lesson or lesson ID is invalid
  String? _getPreviousLessonId(String lessonId) {
    // Map of lesson progression for Phase 2
    final lessonSequence = {
      'phase2_lesson7_2': 'phase2_lesson7_1',
      'phase2_lesson7_3': 'phase2_lesson7_2',
      'phase2_lesson8_1': 'phase2_lesson7_3',
      'phase2_lesson8_2': 'phase2_lesson8_1',
      'phase2_lesson8_3': 'phase2_lesson8_2',
      'phase2_lesson8_4': 'phase2_lesson8_3',
      'phase2_lesson9_1': 'phase2_lesson8_4',
      'phase2_lesson9_2': 'phase2_lesson9_1',
      'phase2_lesson9_3': 'phase2_lesson9_2',
      'phase2_lesson9_4': 'phase2_lesson9_3',
      'phase2_lesson9_5': 'phase2_lesson9_4',
      'phase2_lesson10_1': 'phase2_lesson9_5',
      'phase2_lesson10_2': 'phase2_lesson10_1',
      'phase2_lesson10_3': 'phase2_lesson10_2',
      'phase2_lesson10_4': 'phase2_lesson10_3',
      'phase2_lesson10_5': 'phase2_lesson10_4',
      'phase2_lesson11_1': 'phase2_lesson10_5',
      'phase2_lesson11_2': 'phase2_lesson11_1',
      'phase2_lesson11_3': 'phase2_lesson11_2',
      'phase2_lesson11_4': 'phase2_lesson11_3',
      'phase2_lesson11_5': 'phase2_lesson11_4',
    };

    return lessonSequence[lessonId];
  }

  /// Get the previous lesson ID in the Phase 3 sequence
  /// Returns null if this is the first lesson or lesson ID is invalid
  String? _getPhase3PreviousLessonId(String lessonId) {
    // Map of lesson progression for Phase 3
    final lessonSequence = {
      // Unit 12: Story Listening & Retelling (4 lessons)
      'phase3_lesson12_2': 'phase3_lesson12_1',
      'phase3_lesson12_3': 'phase3_lesson12_2',
      'phase3_lesson12_4': 'phase3_lesson12_3',
      // Unit 13: Complex Sentences & Connectors (5 lessons)
      'phase3_lesson13_1': 'phase3_lesson12_4',
      'phase3_lesson13_2': 'phase3_lesson13_1',
      'phase3_lesson13_3': 'phase3_lesson13_2',
      'phase3_lesson13_4': 'phase3_lesson13_3',
      'phase3_lesson13_5': 'phase3_lesson13_4',
      // Unit 14: Passive Voice (4 lessons)
      'phase3_lesson14_1': 'phase3_lesson13_5',
      'phase3_lesson14_2': 'phase3_lesson14_1',
      'phase3_lesson14_3': 'phase3_lesson14_2',
      'phase3_lesson14_4': 'phase3_lesson14_3',
      // Unit 15: Reported Speech (4 lessons)
      'phase3_lesson15_1': 'phase3_lesson14_4',
      'phase3_lesson15_2': 'phase3_lesson15_1',
      'phase3_lesson15_3': 'phase3_lesson15_2',
      'phase3_lesson15_4': 'phase3_lesson15_3',
      // Unit 16: Functional English (5 lessons)
      'phase3_lesson16_1': 'phase3_lesson15_4',
      'phase3_lesson16_2': 'phase3_lesson16_1',
      'phase3_lesson16_3': 'phase3_lesson16_2',
      'phase3_lesson16_4': 'phase3_lesson16_3',
      'phase3_lesson16_5': 'phase3_lesson16_4',
      // Unit 17: Speaking & Writing Projects (5 lessons)
      'phase3_lesson17_1': 'phase3_lesson16_5',
      'phase3_lesson17_2': 'phase3_lesson17_1',
      'phase3_lesson17_3': 'phase3_lesson17_2',
      'phase3_lesson17_4': 'phase3_lesson17_3',
      'phase3_lesson17_5': 'phase3_lesson17_4',
    };

    return lessonSequence[lessonId];
  }

  /// Get the previous lesson ID in the Phase 4 sequence
  /// Returns null if this is the first lesson or lesson ID is invalid
  /// Handles both within-unit and cross-unit progression
  /// Requirements: 3.2, 3.3
  String? _getPhase4PreviousLessonId(String lessonId) {
    // Map of lesson progression for Phase 4
    final lessonSequence = {
      // Unit 18: Pronunciation & Sound (4 lessons)
      'phase4_lesson18_2': 'phase4_lesson18_1',
      'phase4_lesson18_3': 'phase4_lesson18_2',
      'phase4_lesson18_4': 'phase4_lesson18_3',
      // Unit 19: Fluency Techniques (4 lessons) - first lesson requires Unit 18 completion
      'phase4_lesson19_1': 'phase4_lesson18_4',
      'phase4_lesson19_2': 'phase4_lesson19_1',
      'phase4_lesson19_3': 'phase4_lesson19_2',
      'phase4_lesson19_4': 'phase4_lesson19_3',
      // Unit 20: Real-Life Conversations (5 lessons) - first lesson requires Unit 19 completion
      'phase4_lesson20_1': 'phase4_lesson19_4',
      'phase4_lesson20_2': 'phase4_lesson20_1',
      'phase4_lesson20_3': 'phase4_lesson20_2',
      'phase4_lesson20_4': 'phase4_lesson20_3',
      'phase4_lesson20_5': 'phase4_lesson20_4',
      // Unit 21: Discussion & Opinion Skills (4 lessons) - first lesson requires Unit 20 completion
      'phase4_lesson21_1': 'phase4_lesson20_5',
      'phase4_lesson21_2': 'phase4_lesson21_1',
      'phase4_lesson21_3': 'phase4_lesson21_2',
      'phase4_lesson21_4': 'phase4_lesson21_3',
    };

    return lessonSequence[lessonId];
  }

  /// Get the previous lesson ID in the Phase 5 sequence
  String? _getPhase5PreviousLessonId(String lessonId) {
    final lessonSequence = {
      // Unit 22
      'phase5_lesson22_2': 'phase5_lesson22_1',
      'phase5_lesson22_3': 'phase5_lesson22_2',
      'phase5_lesson22_4': 'phase5_lesson22_3',
      // Unit 23
      'phase5_lesson23_1': 'phase5_lesson22_4',
      'phase5_lesson23_2': 'phase5_lesson23_1',
      'phase5_lesson23_3': 'phase5_lesson23_2',
      'phase5_lesson23_4': 'phase5_lesson23_3',
      // Unit 24
      'phase5_lesson24_1': 'phase5_lesson23_4',
      'phase5_lesson24_2': 'phase5_lesson24_1',
      'phase5_lesson24_3': 'phase5_lesson24_2',
      'phase5_lesson24_4': 'phase5_lesson24_3',
      // Unit 25
      'phase5_lesson25_1': 'phase5_lesson24_4',
      'phase5_lesson25_2': 'phase5_lesson25_1',
      'phase5_lesson25_3': 'phase5_lesson25_2',
      'phase5_lesson25_4': 'phase5_lesson25_3',
    };

    return lessonSequence[lessonId];
  }

  // Get lesson status
  UserLessonStatus? getLessonStatus(String lessonId) {
    return _allProgress[lessonId];
  }

  // Refresh progress for a specific lesson
  Future<void> refreshLessonProgress(String lessonId) async {
    try {
      final status = await _progressRepo.loadLessonProgress(lessonId);
      if (status != null) {
        _allProgress[lessonId] = status;
        notifyListeners();
      }
    } catch (e) {
      ErrorHandler.logError('ProgressProvider.refreshLessonProgress', e);
      _error = ErrorHandler.getUserMessage(e);
      notifyListeners();
    }
  }

  // Reload all data
  Future<void> reload() async {
    await loadAllData();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Phase 2 progress summary
class Phase2Progress {
  final int totalLessons;
  final int masteredLessons;

  Phase2Progress({required this.totalLessons, required this.masteredLessons});

  double get progressPercentage {
    if (totalLessons == 0) return 0.0;
    return masteredLessons / totalLessons;
  }
}

/// Phase 3 progress summary
class Phase3Progress {
  final int totalLessons;
  final int masteredLessons;

  Phase3Progress({required this.totalLessons, required this.masteredLessons});

  double get progressPercentage {
    if (totalLessons == 0) return 0.0;
    return masteredLessons / totalLessons;
  }
}

/// Phase 4 progress summary
class Phase4Progress {
  final int totalLessons;
  final int masteredLessons;

  Phase4Progress({required this.totalLessons, required this.masteredLessons});

  double get progressPercentage {
    if (totalLessons == 0) return 0.0;
    return masteredLessons / totalLessons;
  }
}
