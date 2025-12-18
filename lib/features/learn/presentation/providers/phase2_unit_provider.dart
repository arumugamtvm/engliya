import 'package:flutter/foundation.dart';
import '../../data/models/phase2_unit.dart';
import 'progress_provider.dart';
import '../../../../core/utils/error_handler.dart';

/// Provider for managing Phase 2 unit screen state
/// Handles loading units and calculating progress for each unit
class Phase2UnitProvider extends ChangeNotifier {
  final ProgressProvider _progressProvider;

  Phase2UnitProvider(this._progressProvider);

  List<Phase2Unit> _units = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Phase2Unit> get units => _units;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all Phase 2 units with progress calculation
  /// Initializes 5 units (Units 7-11) and calculates mastered lesson count for each
  Future<void> loadUnits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize the 5 Phase 2 units
      _units = [
        Phase2Unit(
          id: 'phase2_unit7',
          order: 7,
          title: 'Time & Place Language',
          description: 'Learn prepositions and time expressions',
          lessonCount: 3,
        ),
        Phase2Unit(
          id: 'phase2_unit8',
          order: 8,
          title: 'Continuous Tenses',
          description: 'Present, past, and future continuous',
          lessonCount: 4,
        ),
        Phase2Unit(
          id: 'phase2_unit9',
          order: 9,
          title: 'Perfect & Perfect Continuous',
          description: 'Master perfect tenses',
          lessonCount: 5,
        ),
        Phase2Unit(
          id: 'phase2_unit10',
          order: 10,
          title: 'Questions & Negatives',
          description: 'Ask questions and form negatives',
          lessonCount: 5,
        ),
        Phase2Unit(
          id: 'phase2_unit11',
          order: 11,
          title: 'Advanced Pronouns, Adjectives & Adverbs',
          description: 'Enrich your sentences',
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
      ErrorHandler.logError('Phase2UnitProvider.loadUnits', e);
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
          'Phase2UnitProvider._calculateUnitMasteredCount', e);
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
