import 'package:flutter/foundation.dart';
import '../../data/models/lesson.dart';
import '../../data/models/user_lesson_status.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../../../core/utils/error_handler.dart';

class LessonProvider extends ChangeNotifier {
  final LessonRepository _lessonRepo;
  final ProgressRepository _progressRepo;

  LessonProvider({
    required LessonRepository lessonRepo,
    required ProgressRepository progressRepo,
  })  : _lessonRepo = lessonRepo,
        _progressRepo = progressRepo;

  Lesson? _currentLesson;
  UserLessonStatus? _currentStatus;
  int _currentTabIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  Lesson? get currentLesson => _currentLesson;
  UserLessonStatus? get currentStatus => _currentStatus;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get canGoNext => _currentTabIndex < 5;
  bool get canGoPrevious => _currentTabIndex > 0;

  // Load lesson with error handling
  Future<void> loadLesson(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLesson = await _lessonRepo.loadLesson(lessonId);
      _currentStatus = await _progressRepo.loadLessonProgress(lessonId);

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
    if (index >= 0 && index < 6) {
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
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
