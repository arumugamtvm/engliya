import 'package:flutter/foundation.dart';

import '../../domain/entities/unit.dart';
import 'progress_provider.dart';
import '../../../../core/utils/error_handler.dart';

class PhaseUnitProvider extends ChangeNotifier {
  final ProgressProvider _progressProvider;
  final List<Unit> _unitDefinitions;

  PhaseUnitProvider(
    this._progressProvider,
    this._unitDefinitions,
  );

  List<Unit> _units = [];
  bool _isLoading = false;
  String? _error;

  List<Unit> get units => _units;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUnits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _units = _unitDefinitions
          .map((unit) => unit.withMasteredCount(_calculateUnitMasteredCount(unit.id)))
          .toList(growable: false);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('PhaseUnitProvider.loadUnits', e);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  int _calculateUnitMasteredCount(String unitId) {
    try {
      final lessons = _progressProvider.getUnitLessons(unitId);
      return lessons
          .where((lesson) =>
              _progressProvider.getLessonStatus(lesson.id)?.isMastered ?? false)
          .length;
    } catch (e) {
      ErrorHandler.logError('PhaseUnitProvider._calculateUnitMasteredCount', e);
      return 0;
    }
  }

  Future<void> reload() async {
    await loadUnits();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
