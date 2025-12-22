import 'package:flutter/foundation.dart';
import 'test_question.dart';

/// Represents performance metrics for a specific unit in a test
@immutable
class UnitPerformance {
  final String unitId;
  final String unitName;
  final int totalQuestions;
  final int correctAnswers;

  const UnitPerformance({
    required this.unitId,
    required this.unitName,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  /// Calculate accuracy percentage
  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  /// Number of incorrect answers
  int get incorrectAnswers => totalQuestions - correctAnswers;

  /// Check if all questions were answered correctly
  bool get isPerfect => correctAnswers == totalQuestions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitPerformance &&
          runtimeType == other.runtimeType &&
          unitId == other.unitId &&
          unitName == other.unitName &&
          totalQuestions == other.totalQuestions &&
          correctAnswers == other.correctAnswers;

  @override
  int get hashCode =>
      unitId.hashCode ^
      unitName.hashCode ^
      totalQuestions.hashCode ^
      correctAnswers.hashCode;

  @override
  String toString() =>
      'UnitPerformance($unitName: $correctAnswers/$totalQuestions)';
}

/// Represents details of an incorrectly answered question
@immutable
class IncorrectAnswer {
  final TestQuestion question;
  final int selectedIndex;
  final String selectedAnswer;
  final String correctAnswer;

  const IncorrectAnswer({
    required this.question,
    required this.selectedIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  /// Check if the question was skipped (no answer selected)
  bool get wasSkipped => selectedIndex < 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncorrectAnswer &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          selectedIndex == other.selectedIndex &&
          selectedAnswer == other.selectedAnswer &&
          correctAnswer == other.correctAnswer;

  @override
  int get hashCode =>
      question.hashCode ^
      selectedIndex.hashCode ^
      selectedAnswer.hashCode ^
      correctAnswer.hashCode;

  @override
  String toString() =>
      'IncorrectAnswer(question: ${question.id}, selected: $selectedAnswer, correct: $correctAnswer)';
}

/// Immutable domain entity representing a test result
/// Supports both simple tests and unit-based tests with breakdown
@immutable
class TestResult {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final bool passed;
  final DateTime completedAt;
  final Map<String, UnitPerformance>? unitBreakdown;
  final List<IncorrectAnswer> incorrectQuestionDetails;

  const TestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.passed,
    required this.completedAt,
    this.unitBreakdown,
    required this.incorrectQuestionDetails,
  });

  /// Factory constructor to calculate result from questions and answers
  factory TestResult.calculate({
    required List<TestQuestion> questions,
    required List<int?> selectedAnswers,
    required int passingScore,
    required DateTime completedAt,
    Map<String, String>? unitNames,
  }) {
    int correct = 0;
    final incorrectDetails = <IncorrectAnswer>[];
    final unitStats = <String, _UnitStats>{};

    final minLength = questions.length < selectedAnswers.length
        ? questions.length
        : selectedAnswers.length;

    for (int i = 0; i < minLength; i++) {
      final question = questions[i];
      final selectedIndex = selectedAnswers[i];

      // Track unit performance if question has unitId
      if (question.unitId != null) {
        unitStats.putIfAbsent(
          question.unitId!,
          () => _UnitStats(question.unitId!, unitNames?[question.unitId!] ?? question.unitId!),
        );
        unitStats[question.unitId!]!.total++;
      }

      if (selectedIndex != null && question.isCorrect(selectedIndex)) {
        correct++;
        if (question.unitId != null) {
          unitStats[question.unitId!]!.correct++;
        }
      } else {
        incorrectDetails.add(IncorrectAnswer(
          question: question,
          selectedIndex: selectedIndex ?? -1,
          selectedAnswer: selectedIndex != null
              ? question.getSelectedAnswer(selectedIndex)
              : 'No answer selected',
          correctAnswer: question.correctAnswer,
        ));
      }
    }

    final incorrect = questions.length - correct;
    final accuracy =
        questions.isNotEmpty ? (correct / questions.length) * 100 : 0.0;
    final passed = correct >= passingScore;

    // Build unit breakdown if we have unit data
    Map<String, UnitPerformance>? breakdown;
    if (unitStats.isNotEmpty) {
      breakdown = {};
      for (final entry in unitStats.entries) {
        breakdown[entry.key] = UnitPerformance(
          unitId: entry.value.unitId,
          unitName: entry.value.unitName,
          totalQuestions: entry.value.total,
          correctAnswers: entry.value.correct,
        );
      }
    }

    return TestResult(
      totalQuestions: questions.length,
      correctAnswers: correct,
      incorrectAnswers: incorrect,
      accuracy: accuracy,
      passed: passed,
      completedAt: completedAt,
      unitBreakdown: breakdown,
      incorrectQuestionDetails: incorrectDetails,
    );
  }

  /// Check if this result has unit breakdown data
  bool get hasUnitBreakdown => unitBreakdown != null && unitBreakdown!.isNotEmpty;

  /// Get the score as a formatted string
  String get scoreString => '$correctAnswers/$totalQuestions';

  /// Get the accuracy as a formatted percentage string
  String get accuracyString => '${accuracy.toStringAsFixed(1)}%';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResult &&
          runtimeType == other.runtimeType &&
          totalQuestions == other.totalQuestions &&
          correctAnswers == other.correctAnswers &&
          incorrectAnswers == other.incorrectAnswers &&
          accuracy == other.accuracy &&
          passed == other.passed &&
          completedAt == other.completedAt &&
          mapEquals(unitBreakdown, other.unitBreakdown) &&
          listEquals(incorrectQuestionDetails, other.incorrectQuestionDetails);

  @override
  int get hashCode =>
      totalQuestions.hashCode ^
      correctAnswers.hashCode ^
      incorrectAnswers.hashCode ^
      accuracy.hashCode ^
      passed.hashCode ^
      completedAt.hashCode ^
      unitBreakdown.hashCode ^
      incorrectQuestionDetails.hashCode;

  @override
  String toString() =>
      'TestResult(score: $scoreString, accuracy: $accuracyString, passed: $passed)';

  /// Create a copy with modified fields
  TestResult copyWith({
    int? totalQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
    double? accuracy,
    bool? passed,
    DateTime? completedAt,
    Map<String, UnitPerformance>? unitBreakdown,
    List<IncorrectAnswer>? incorrectQuestionDetails,
  }) {
    return TestResult(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      accuracy: accuracy ?? this.accuracy,
      passed: passed ?? this.passed,
      completedAt: completedAt ?? this.completedAt,
      unitBreakdown: unitBreakdown ?? this.unitBreakdown,
      incorrectQuestionDetails:
          incorrectQuestionDetails ?? this.incorrectQuestionDetails,
    );
  }
}

/// Helper class for calculating unit statistics
class _UnitStats {
  final String unitId;
  final String unitName;
  int total = 0;
  int correct = 0;

  _UnitStats(this.unitId, this.unitName);
}
