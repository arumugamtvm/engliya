import '../entities/phase_config.dart';
import '../entities/test_question.dart';
import '../entities/test_result.dart';

/// Abstract repository interface for test-related operations
/// Implementations should be placed in the data layer
abstract class TestRepository {
  /// Generate a test with questions for the given phase configuration
  /// Returns a list of [TestQuestion] objects shuffled and ready for the test
  Future<List<TestQuestion>> generateTest(PhaseConfig config);

  /// Save the test result for the given phase
  Future<void> saveTestResult(PhaseConfig config, TestResult result);

  /// Load the previously saved test result for the given phase
  /// Returns null if no result exists
  Future<TestResult?> loadTestResult(PhaseConfig config);

  /// Check if the user has passed the test for the given phase
  Future<bool> hasPassedTest(PhaseConfig config);

  /// Get the last test score for the given phase
  /// Returns null if no test has been taken
  Future<int?> getLastTestScore(PhaseConfig config);

  /// Clear all test data for the given phase
  Future<void> clearTestData(PhaseConfig config);
}
