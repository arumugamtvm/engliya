import 'package:flutter/foundation.dart';
import '../../data/models/phase4_unit.dart';
import 'progress_provider.dart';
import '../../../../core/utils/error_handler.dart';

/// Provider for managing Phase 4 unit screen state
/// Handles loading units and calculating progress for each unit
class Phase4UnitProvider extends ChangeNotifier {
  final ProgressProvider _progressProvider;

  Phase4UnitProvider(this._progressProvider);

  List<Phase4Unit> _units = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Phase4Unit> get units => _units;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all Phase 4 units with progress calculation
  /// Initializes 4 units (Units 18-21) and calculates mastered lesson count for each
  Future<void> loadUnits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize the 4 Phase 4 units
      _units = [
        Phase4Unit(
          id: 'phase4_unit18',
          order: 18,
          title: 'Pronunciation & Sound',
          description: 'Learn English sounds, syllables, and stress patterns',
          lessonCount: 4,
        ),
        Phase4Unit(
          id: 'phase4_unit19',
          order: 19,
          title: 'Fluency Techniques',
          description: 'Speak more smoothly and naturally',
          lessonCount: 4,
        ),
        Phase4Unit(
          id: 'phase4_unit20',
          order: 20,
          title: 'Real-Life Conversations',
          description: 'Practice everyday communication scenarios',
          lessonCount: 5,
        ),
        Phase4Unit(
          id: 'phase4_unit21',
          order: 21,
          title: 'Discussion & Opinion Skills',
          description: 'Express opinions and engage in discussions',
          lessonCount: 4,
        ),
      ];

      // Calculate mastered lesson count for each unit
      for (final unit in _units) {
        unit.masteredCount = getMasteredCount(unit.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('Phase4UnitProvider.loadUnits', e);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculate the number of mastered lessons for a specific unit
  /// Returns the count of lessons with isMastered = true
  int getMasteredCount(String unitId) {
    try {
      final lessons = _progressProvider.getUnitLessons(unitId);
      return lessons
          .where((lesson) =>
              _progressProvider.getLessonStatus(lesson.id)?.isMastered ?? false)
          .length;
    } catch (e) {
      // If lessons aren't loaded yet, return 0
      ErrorHandler.logError(
          'Phase4UnitProvider.getMasteredCount', e);
      return 0;
    }
  }

  /// Reload units and recalculate progress
  /// Useful after completing lessons to update unit progress
  Future<void> reload() async {
    await loadUnits();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
