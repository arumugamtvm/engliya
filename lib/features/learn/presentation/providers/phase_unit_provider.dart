import 'package:flutter/foundation.dart';

import '../../domain/entities/phase_config.dart';
import '../../domain/entities/unit.dart';
import 'progress_provider.dart';
import '../../../../core/utils/error_handler.dart';

class PhaseUnitProvider extends ChangeNotifier {
  final ProgressProvider _progressProvider;
  final PhaseType _phaseType;

  PhaseUnitProvider(
    this._progressProvider,
    this._phaseType,
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
      _units = _progressProvider.getUnitsForPhase(_phaseType);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('PhaseUnitProvider.loadUnits', e);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
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
