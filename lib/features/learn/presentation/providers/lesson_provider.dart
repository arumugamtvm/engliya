import 'package:flutter/foundation.dart';
import '../../data/models/lesson.dart';
import '../../data/models/user_lesson_status.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/entities/tab_validation_result.dart';
import '../../services/lesson_flow_validation_service.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/utils/error_handler.dart';

class LessonProvider extends ChangeNotifier {
  final LessonRepository _lessonRepo;
  final ProgressRepository _progressRepo;

  LessonProvider({
    required LessonRepository lessonRepo,
    required ProgressRepository progressRepo,
  }) : _lessonRepo = lessonRepo,
       _progressRepo = progressRepo;

  Lesson? _currentLesson;
  UserLessonStatus? _currentStatus;
  int _currentTabIndex = 0;
  bool _isLoading = false;
  String? _error;
  String? _contentNotice;
  final LessonFlowValidationService _validationService =
      LessonFlowValidationService();

  TabProgressSnapshot _explainProgress = const TabProgressSnapshot();
  TabProgressSnapshot _examplesProgress = const TabProgressSnapshot();
  TabProgressSnapshot _listenProgress = const TabProgressSnapshot();
  TabProgressSnapshot _speakProgress = const TabProgressSnapshot();
  TabProgressSnapshot _practiceProgress = const TabProgressSnapshot();
  TabProgressSnapshot _masteryProgress = const TabProgressSnapshot();

  // Getters
  Lesson? get currentLesson => _currentLesson;
  UserLessonStatus? get currentStatus => _currentStatus;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get contentNotice => _contentNotice;

  bool get canGoNext => _currentTabIndex < 5;
  bool get canGoPrevious => _currentTabIndex > 0;
  bool get isOnFinalTab => _currentTabIndex == 5;
  bool get strictProgressionEnabled => !AppConfig.devMode;

  // Load lesson with error handling
  Future<void> loadLesson(String lessonId) async {
    _isLoading = true;
    _error = null;
    _contentNotice = null;
    notifyListeners();

    try {
      final validatedLesson = await _lessonRepo.loadLessonWithFallback(
        lessonId,
      );
      _currentLesson = validatedLesson.lesson;
      if (validatedLesson.source == 'fallback') {
        _contentNotice =
            'We loaded a validated backup lesson to keep your learning on track.';
      }
      _currentStatus = await _progressRepo.loadLessonProgress(lessonId);
      _resetTabProgress();

      // Initialize progress if it doesn't exist
      if (_currentStatus == null) {
        _currentStatus = _progressRepo.initializeProgress(lessonId);
        await _saveProgressWithRetry(_currentStatus!);
      }

      // Update last accessed time
      _currentStatus!.lastAccessed = DateTime.now();
      await saveProgress();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('LessonProvider.loadLesson', e);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw so UI can handle it
    }
  }

  TabValidationResult validateTab(int tabIndex) {
    final status = _currentStatus;
    if (status == null) {
      return const TabValidationResult.invalid(
        message: 'Lesson progress is unavailable. Retry loading the lesson.',
        severity: ValidationSeverity.error,
        actionLabel: 'Retry',
      );
    }

    switch (tabIndex) {
      case 0:
        return _validationService.validateExplain(
          explainDone: status.explainDone,
          snapshot: _explainProgress,
        );
      case 1:
        return _validationService.validateExamples(
          examplesDone: status.examplesDone,
          snapshot: _examplesProgress,
        );
      case 2:
        return _validationService.validateListen(
          listeningScore: status.listeningScore,
          snapshot: _listenProgress,
        );
      case 3:
        return _validationService.validateSpeak(
          speakingScore: status.speakingScore,
          snapshot: _speakProgress,
        );
      case 4:
        return _validationService.validatePractice(
          quizBestScore: status.quizBestScore,
          snapshot: _practiceProgress,
        );
      case 5:
        return _validationService.validateMastery(
          isMastered: status.isMastered,
          masteryBestScore: status.masteryBestScore,
          snapshot: _masteryProgress,
        );
      default:
        return const TabValidationResult.valid();
    }
  }

  TabValidationResult validateCurrentTab() => validateTab(_currentTabIndex);

  int get maxAccessibleTabIndex {
    if (AppConfig.devMode) return 5;
    int maxIndex = 0;
    for (int i = 1; i <= 5; i++) {
      if (isTabUnlocked(i)) {
        maxIndex = i;
      } else {
        break;
      }
    }
    return maxIndex;
  }

  bool isTabUnlocked(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 5) return false;
    if (AppConfig.devMode) return true;
    if (tabIndex == 0) return true;

    for (int i = 0; i < tabIndex; i++) {
      final validation = validateTab(i);
      if (!validation.isValid) {
        return false;
      }
    }
    return true;
  }

  bool canAccessTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 5) return false;
    if (tabIndex == _currentTabIndex) return true;
    if (!isTabUnlocked(tabIndex)) return false;

    // Keep strict sequential navigation: users can only move to current or next unlocked step.
    if (!AppConfig.devMode && tabIndex > _currentTabIndex + 1) {
      return false;
    }
    return true;
  }

  TabValidationResult? getBlockingValidationForTab(int tabIndex) {
    if (AppConfig.devMode || tabIndex <= 0) return null;

    final maxCheckIndex = tabIndex > _currentTabIndex + 1
        ? _currentTabIndex + 1
        : tabIndex;
    for (int i = 0; i < maxCheckIndex; i++) {
      final validation = validateTab(i);
      if (!validation.isValid) {
        return validation;
      }
    }

    if (!AppConfig.devMode && tabIndex > _currentTabIndex + 1) {
      return const TabValidationResult.invalid(
        message: 'Complete the current step to unlock the next tab.',
        actionLabel: 'Continue lesson',
      );
    }

    return null;
  }

  void updateExplainProgress({required bool scrolledToBottom}) {
    _explainProgress = TabProgressSnapshot(
      explainScrolledToBottom: scrolledToBottom,
    );
  }

  void updateExamplesProgress({
    required int playedCount,
    required int totalCount,
  }) {
    _examplesProgress = TabProgressSnapshot(
      playedCount: playedCount,
      totalCount: totalCount,
    );
  }

  void updateListenProgress({
    required int answeredCount,
    required int totalCount,
    required double accuracy,
  }) {
    _listenProgress = TabProgressSnapshot(
      answeredCount: answeredCount,
      totalCount: totalCount,
      accuracy: accuracy,
    );
  }

  void updateSpeakProgress({
    required int practicedCount,
    required int totalCount,
    required double averageScore,
  }) {
    _speakProgress = TabProgressSnapshot(
      practicedCount: practicedCount,
      totalCount: totalCount,
      averageScore: averageScore,
    );
  }

  void updatePracticeProgress({
    required int answeredCount,
    required int totalCount,
    required double accuracy,
  }) {
    _practiceProgress = TabProgressSnapshot(
      answeredCount: answeredCount,
      totalCount: totalCount,
      accuracy: accuracy,
    );
  }

  void updateMasteryProgress({
    required int answeredCount,
    required int totalCount,
    required double accuracy,
  }) {
    _masteryProgress = TabProgressSnapshot(
      answeredCount: answeredCount,
      totalCount: totalCount,
      accuracy: accuracy,
    );
  }

  // Tab navigation
  void goToNextTab() {
    if (canGoNext) {
      _currentTabIndex++;
      notifyListeners();
    }
  }

  void goToPreviousTab() {
    if (canGoPrevious) {
      _currentTabIndex--;
      notifyListeners();
    }
  }

  void goToTab(int index) {
    if (index >= 0 && index < 6 && canAccessTab(index)) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  // Tab completion methods
  void markExplainDone() {
    if (_currentStatus != null) {
      _currentStatus!.explainDone = true;
      saveProgress();
      notifyListeners();
    }
  }

  void markExamplesDone() {
    if (_currentStatus != null) {
      _currentStatus!.examplesDone = true;
      saveProgress();
      notifyListeners();
    }
  }

  void updateListeningScore(double score) {
    if (_currentStatus != null) {
      if (score > _currentStatus!.listeningScore) {
        _currentStatus!.listeningScore = score;
        saveProgress();
        notifyListeners();
      }
    }
  }

  void updateSpeakingScore(double score) {
    if (_currentStatus != null) {
      if (score > _currentStatus!.speakingScore) {
        _currentStatus!.speakingScore = score;
        saveProgress();
        notifyListeners();
      }
    }
  }

  void updateQuizScore(double score) {
    if (_currentStatus != null) {
      if (score > _currentStatus!.quizBestScore) {
        _currentStatus!.quizBestScore = score;
        saveProgress();
        notifyListeners();
      }
    }
  }

  void updateMasteryScore(double score) {
    if (_currentStatus != null) {
      if (score > _currentStatus!.masteryBestScore) {
        _currentStatus!.masteryBestScore = score;
        // Mark as mastered if score >= 80%
        if (score >= 0.8) {
          _currentStatus!.isMastered = true;
        }
        saveProgress();
        notifyListeners();
      }
    }
  }

  // Save progress with retry logic
  Future<void> saveProgress() async {
    if (_currentStatus != null) {
      try {
        await _saveProgressWithRetry(_currentStatus!);
      } catch (e) {
        ErrorHandler.logError('LessonProvider.saveProgress', e);
        _error = ErrorHandler.getUserMessage(e);
        notifyListeners();
        // Don't rethrow - progress save failures shouldn't block user
      }
    }
  }

  // Internal method to save progress with retry
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
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 100 * retryCount));
      }
    }
  }

  // Reset state
  void reset() {
    _currentLesson = null;
    _currentStatus = null;
    _currentTabIndex = 0;
    _isLoading = false;
    _error = null;
    _contentNotice = null;
    _resetTabProgress();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    _contentNotice = null;
    notifyListeners();
  }

  void _resetTabProgress() {
    _explainProgress = const TabProgressSnapshot();
    _examplesProgress = const TabProgressSnapshot();
    _listenProgress = const TabProgressSnapshot();
    _speakProgress = const TabProgressSnapshot();
    _practiceProgress = const TabProgressSnapshot();
    _masteryProgress = const TabProgressSnapshot();
  }
}
