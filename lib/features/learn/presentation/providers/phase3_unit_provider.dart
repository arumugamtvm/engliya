import 'package:flutter/foundation.dart';
import '../../data/models/phase3_unit.dart';
import 'progress_provider.dart';
import '../../../../core/utils/error_handler.dart';

/// Provider for managing Phase 3 unit screen state
/// Handles loading units and calculating progress for each unit
class Phase3UnitProvider extends ChangeNotifier {
  final ProgressProvider _progressProvider;

  Phase3UnitProvider(this._progressProvider);

  List<Phase3Unit> _units = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Phase3Unit> get units => _units;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all Phase 3 units with progress calculation
  /// Initializes 6 units (Units 12-17) and calculates mastered lesson count for each
  Future<void> loadUnits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize the 6 Phase 3 units
      _units = [
        Phase3Unit(
          id: 'phase3_unit12',
          order: 12,
          title: 'Story Listening & Retelling',
          description: 'Understand and retell stories',
          lessonCount: 4,
        ),
        Phase3Unit(
          id: 'phase3_unit13',
          order: 13,
          title: 'Complex Sentences & Connectors',
          description: 'Join ideas with connectors',
          lessonCount: 5,
        ),
        Phase3Unit(
          id: 'phase3_unit14',
          order: 14,
          title: 'Passive Voice',
          description: 'Use passive constructions',
          lessonCount: 4,
        ),
        Phase3Unit(
          id: 'phase3_unit15',
          order: 15,
          title: 'Reported Speech',
          description: 'Report what others said',
          lessonCount: 4,
        ),
        Phase3Unit(
          id: 'phase3_unit16',
          order: 16,
          title: 'Functional English',
          description: 'Handle everyday situations',
          lessonCount: 5,
        ),
        Phase3Unit(
          id: 'phase3_unit17',
          order: 17,
          title: 'Speaking & Writing Projects',
          description: 'Demonstrate communication skills',
          lessonCount: 5,
        ),
      ];

      // Calculate mastered lesson count for each unit
      for (final unit in _units) {
        unit.masteredCount = _calculateUnitMasteredCount(unit.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('Phase3UnitProvider.loadUnits', e);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculate the number of mastered lessons for a specific unit
  /// Returns the count of lessons with isMastered = true
  int _calculateUnitMasteredCount(String unitId) {
    try {
      final lessons = _progressProvider.getUnitLessons(unitId);
      return lessons
          .where((lesson) =>
              _progressProvider.getLessonStatus(lesson.id)?.isMastered ?? false)
          .length;
    } catch (e) {
      // If lessons aren't loaded yet, return 0
      ErrorHandler.logError(
          'Phase3UnitProvider._calculateUnitMasteredCount', e);
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
