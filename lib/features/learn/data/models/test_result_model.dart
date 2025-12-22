import '../../domain/entities/test_result.dart';
import 'test_question_model.dart';

/// Data model for UnitPerformance with JSON serialization support
class UnitPerformanceModel extends UnitPerformance {
  const UnitPerformanceModel({
    required super.unitId,
    required super.unitName,
    required super.totalQuestions,
    required super.correctAnswers,
  });

  /// Create from JSON
  factory UnitPerformanceModel.fromJson(Map<String, dynamic> json) {
    return UnitPerformanceModel(
      unitId: json['unitId'] as String,
      unitName: json['unitName'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unitId': unitId,
      'unitName': unitName,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
    };
  }

  /// Create from domain entity
  factory UnitPerformanceModel.fromEntity(UnitPerformance entity) {
    return UnitPerformanceModel(
      unitId: entity.unitId,
      unitName: entity.unitName,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
    );
  }

  /// Convert to domain entity
  UnitPerformance toEntity() {
    return UnitPerformance(
      unitId: unitId,
      unitName: unitName,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
    );
  }
}

/// Data model for IncorrectAnswer with JSON serialization support
class IncorrectAnswerModel extends IncorrectAnswer {
  const IncorrectAnswerModel({
    required super.question,
    required super.selectedIndex,
    required super.selectedAnswer,
    required super.correctAnswer,
  });

  /// Create from JSON
  factory IncorrectAnswerModel.fromJson(Map<String, dynamic> json) {
    final questionJson = json['question'] as Map<String, dynamic>;
    final question = TestQuestionModel.fromJson(questionJson).toEntity();

    return IncorrectAnswerModel(
      question: question,
      selectedIndex: json['selectedIndex'] as int,
      selectedAnswer: json['selectedAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'question': TestQuestionModel.fromEntity(question).toJson(),
      'selectedIndex': selectedIndex,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
    };
  }

  /// Create from domain entity
  factory IncorrectAnswerModel.fromEntity(IncorrectAnswer entity) {
    return IncorrectAnswerModel(
      question: entity.question,
      selectedIndex: entity.selectedIndex,
      selectedAnswer: entity.selectedAnswer,
      correctAnswer: entity.correctAnswer,
    );
  }

  /// Convert to domain entity
  IncorrectAnswer toEntity() {
    return IncorrectAnswer(
      question: question,
      selectedIndex: selectedIndex,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
    );
  }
}

/// Data model for TestResult with JSON serialization support
class TestResultModel extends TestResult {
  const TestResultModel({
    required super.totalQuestions,
    required super.correctAnswers,
    required super.incorrectAnswers,
    required super.accuracy,
    required super.passed,
    required super.completedAt,
    super.unitBreakdown,
    required super.incorrectQuestionDetails,
  });

  /// Create from JSON
  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    // Parse unit breakdown map if present
    Map<String, UnitPerformance>? unitBreakdown;
    if (json['unitBreakdown'] != null) {
      final unitBreakdownJson = json['unitBreakdown'] as Map<String, dynamic>;
      unitBreakdown = {};
      unitBreakdownJson.forEach((key, value) {
        unitBreakdown![key] =
            UnitPerformanceModel.fromJson(value as Map<String, dynamic>)
                .toEntity();
      });
    }

    return TestResultModel(
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      incorrectAnswers: json['incorrectAnswers'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      passed: json['passed'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      unitBreakdown: unitBreakdown,
      incorrectQuestionDetails: (json['incorrectQuestionDetails'] as List)
          .map((item) =>
              IncorrectAnswerModel.fromJson(item as Map<String, dynamic>)
                  .toEntity())
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    // Convert unit breakdown map to JSON if present
    Map<String, dynamic>? unitBreakdownJson;
    if (unitBreakdown != null) {
      unitBreakdownJson = {};
      unitBreakdown!.forEach((key, value) {
        unitBreakdownJson![key] =
            UnitPerformanceModel.fromEntity(value).toJson();
      });
    }

    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'accuracy': accuracy,
      'passed': passed,
      'completedAt': completedAt.toIso8601String(),
      if (unitBreakdownJson != null) 'unitBreakdown': unitBreakdownJson,
      'incorrectQuestionDetails': incorrectQuestionDetails
          .map((item) => IncorrectAnswerModel.fromEntity(item).toJson())
          .toList(),
    };
  }

  /// Create from domain entity
  factory TestResultModel.fromEntity(TestResult entity) {
    return TestResultModel(
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      incorrectAnswers: entity.incorrectAnswers,
      accuracy: entity.accuracy,
      passed: entity.passed,
      completedAt: entity.completedAt,
      unitBreakdown: entity.unitBreakdown,
      incorrectQuestionDetails: entity.incorrectQuestionDetails,
    );
  }

  /// Convert to domain entity
  TestResult toEntity() {
    return TestResult(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      accuracy: accuracy,
      passed: passed,
      completedAt: completedAt,
      unitBreakdown: unitBreakdown,
      incorrectQuestionDetails: incorrectQuestionDetails,
    );
  }
}
