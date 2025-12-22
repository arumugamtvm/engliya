import '../entities/phase_config.dart';
import '../entities/test_question.dart';
import '../entities/test_result.dart';
import '../repositories/test_repository.dart';

/// Use case for submitting a completed test and calculating results
/// 
/// This encapsulates the business logic for test submission,
/// including result calculation and persistence.
class SubmitTestUseCase {
  final TestRepository _repository;

  const SubmitTestUseCase(this._repository);

  /// Submit a completed test and calculate the result
  /// 
  /// [config] - The phase configuration for scoring rules
  /// [questions] - The list of questions that were answered
  /// [answers] - The list of selected answer indices (null for unanswered)
  /// 
  /// Returns the calculated [TestResult] after saving to storage
  /// 
  /// Throws [TestStorageException] if saving fails
  Future<TestResult> call({
    required PhaseConfig config,
    required List<TestQuestion> questions,
    required List<int?> answers,
  }) async {
    // Calculate the result using the domain entity's factory
    final result = TestResult.calculate(
      questions: questions,
      selectedAnswers: answers,
      passingScore: config.passingScore,
      completedAt: DateTime.now(),
      unitNames: config.unitNames.isNotEmpty ? config.unitNames : null,
    );

    // Persist the result
    await _repository.saveTestResult(config, result);

    return result;
  }
}
