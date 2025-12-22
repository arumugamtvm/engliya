import '../entities/phase_config.dart';
import '../entities/unit.dart';

/// Abstract repository interface for unit-related operations
/// Implementations should be placed in the data layer
abstract class UnitRepository {
  /// Load all units for the given phase with their current progress
  /// Returns a list of [Unit] objects with mastered counts populated
  Future<List<Unit>> loadUnits(PhaseConfig config);

  /// Get a specific unit by ID for the given phase
  /// Returns null if the unit doesn't exist
  Future<Unit?> getUnit(PhaseConfig config, String unitId);

  /// Update the mastered count for a specific unit
  Future<void> updateUnitProgress(
    PhaseConfig config,
    String unitId,
    int masteredCount,
  );

  /// Check if all units in the phase are completed
  Future<bool> areAllUnitsCompleted(PhaseConfig config);

  /// Get the total lesson count across all units in the phase
  Future<int> getTotalLessonCount(PhaseConfig config);

  /// Get the total mastered lesson count across all units in the phase
  Future<int> getTotalMasteredCount(PhaseConfig config);
}
