import 'package:flutter/foundation.dart';
import '../../../home/services/home_service.dart';
import '../../../learn/data/models/lesson.dart';
import '../../../learn/data/models/user_lesson_status.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/utils/error_handler.dart';

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
  bool _isPhase5Unlocked = false;
  Map<int, int> _phaseLessonCounts = const {};
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
  bool get isPhase2Unlocked => AppConfig.devMode || _isPhase2Unlocked;
  bool get isPhase3Unlocked => AppConfig.devMode || _isPhase3Unlocked;
  bool get isPhase4Unlocked => AppConfig.devMode || _isPhase4Unlocked;
  bool get isPhase5Unlocked => AppConfig.devMode || _isPhase5Unlocked;
  bool hasPhaseLessons(int phaseNumber) =>
      (_phaseLessonCounts[phaseNumber] ?? 0) > 0;
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
      _phaseLessonCounts = await _homeService.getPhaseLessonCounts();

      final phaseUnlockMap = await _homeService.getPhaseUnlockStatusFromAssets();
      final phaseTestMap = await _homeService.getPhaseFinalTestStatusFromAssets();

      // Load last accessed lesson
      final lastAccessedData = await _homeService.getLastAccessedLesson();
      _lastAccessedLesson = lastAccessedData['lesson'];
      _lastAccessedStatus = lastAccessedData['status'];

      _isPhase2Unlocked = phaseUnlockMap[2] ?? false;
      _isPhase3Unlocked = phaseUnlockMap[3] ?? false;
      _isPhase4Unlocked = phaseUnlockMap[4] ?? false;
      _isPhase5Unlocked = phaseUnlockMap[5] ?? false;

      _hasPassedPhase2FinalTest = phaseTestMap[2]?.passed ?? false;
      _phase2FinalTestScore = phaseTestMap[2]?.score;
      _hasPassedPhase3FinalTest = phaseTestMap[3]?.passed ?? false;
      _phase3FinalTestScore = phaseTestMap[3]?.score;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('HomeProvider.loadHomeData', e);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadHomeData();
  }
}
