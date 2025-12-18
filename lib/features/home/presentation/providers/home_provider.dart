import 'package:flutter/foundation.dart';
import '../../../home/services/home_service.dart';
import '../../../learn/data/models/lesson.dart';
import '../../../learn/data/models/user_lesson_status.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _homeService;

  HomeProvider({
    required HomeService homeService,
  }) : _homeService = homeService;

  int _masteredCount = 0;
  int _totalLessons = 0;
  Lesson? _lastAccessedLesson;
  UserLessonStatus? _lastAccessedStatus;
  bool _isPhase2Unlocked = false;
  bool _isPhase3Unlocked = false;
  bool _isPhase4Unlocked = false;
  bool _hasPassedPhase2FinalTest = false;
  bool _hasPassedPhase3FinalTest = false;
  int? _phase2FinalTestScore;
  int? _phase3FinalTestScore;
  bool _isLoading = false;
  String? _error;

  // Getters
  int get masteredCount => _masteredCount;
  int get totalLessons => _totalLessons;
  Lesson? get lastAccessedLesson => _lastAccessedLesson;
  UserLessonStatus? get lastAccessedStatus => _lastAccessedStatus;
  bool get isPhase2Unlocked => _isPhase2Unlocked;
  bool get isPhase3Unlocked => _isPhase3Unlocked;
  bool get isPhase4Unlocked => _isPhase4Unlocked;
  bool get hasPassedPhase2FinalTest => _hasPassedPhase2FinalTest;
  bool get hasPassedPhase3FinalTest => _hasPassedPhase3FinalTest;
  int? get phase2FinalTestScore => _phase2FinalTestScore;
  int? get phase3FinalTestScore => _phase3FinalTestScore;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLastAccessedLesson => _lastAccessedLesson != null;

  // Load home screen data
  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load progress summary
      final summary = await _homeService.getProgressSummary();
      _masteredCount = summary['masteredCount'] ?? 0;
      _totalLessons = summary['totalLessons'] ?? 0;

      // Load last accessed lesson
      final lastAccessedData = await _homeService.getLastAccessedLesson();
      _lastAccessedLesson = lastAccessedData['lesson'];
      _lastAccessedStatus = lastAccessedData['status'];

      // Check if Phase 2 is unlocked
      _isPhase2Unlocked = await _homeService.isPhase2Unlocked();

      // Check if Phase 3 is unlocked
      _isPhase3Unlocked = await _homeService.isPhase3Unlocked();

      // Check if Phase 4 is unlocked
      // Requirements: 7.4, 7.9
      _isPhase4Unlocked = await _homeService.isPhase4Unlocked();

      // Check Phase 2 final test status
      _hasPassedPhase2FinalTest = await _homeService.hasPassedPhase2FinalTest();
      _phase2FinalTestScore = await _homeService.getPhase2FinalTestScore();

      // Check Phase 3 final test status
      // Requirements: 7.4, 7.9
      _hasPassedPhase3FinalTest = await _homeService.hasPassedPhase3FinalTest();
      _phase3FinalTestScore = await _homeService.getPhase3FinalTestScore();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load home data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadHomeData();
  }
}
