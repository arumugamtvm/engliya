import '../entities/phase_config.dart';
import '../entities/test_question.dart';
import '../repositories/test_repository.dart';

/// Use case for generating a test for a specific phase
/// 
/// This encapsulates the business logic for test generation,
/// delegating the actual data fetching to the repository.
class GenerateTestUseCase {
  final TestRepository _repository;

  const GenerateTestUseCase(this._repository);

  /// Generate a test with questions for the given phase
  /// 
  /// [config] - The phase configuration determining which questions to load
  /// Returns a list of [TestQuestion] objects ready for the test
  /// 
  /// Throws [TestGenerationException] if test generation fails
  Future<List<TestQuestion>> call(PhaseConfig config) {
    return _repository.generateTest(config);
  }
}
