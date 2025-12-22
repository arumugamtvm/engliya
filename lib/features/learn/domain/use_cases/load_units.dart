import '../entities/phase_config.dart';
import '../entities/unit.dart';
import '../repositories/unit_repository.dart';

/// Use case for loading units with progress for a specific phase
/// 
/// This encapsulates the business logic for loading unit data,
/// delegating the actual data fetching to the repository.
class LoadUnitsUseCase {
  final UnitRepository _repository;

  const LoadUnitsUseCase(this._repository);

  /// Load all units for the given phase with their current progress
  /// 
  /// [config] - The phase configuration determining which units to load
  /// Returns a list of [Unit] objects with mastered counts populated
  /// 
  /// Throws [LessonLoadException] if loading fails
  Future<List<Unit>> call(PhaseConfig config) {
    return _repository.loadUnits(config);
  }
}
