import 'incorrect_answer.dart';
import 'unit_performance.dart';

/// Model representing the result of a Phase 3 Final Test.
/// 
/// The test consists of 30 questions distributed across 6 units:
/// - Unit 12: 6 questions (Story Listening & Retelling)
/// - Unit 13: 7 questions (Complex Sentences & Connectors)
/// - Unit 14: 5 questions (Passive Voice)
/// - Unit 15: 5 questions (Reported Speech)
/// - Unit 16: 4 questions (Functional English)
/// - Unit 17: 3 questions (Speaking & Writing Projects)
/// 
/// Passing threshold: 24/30 (80%)
class Phase3TestResult {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final bool passed;
  final DateTime completedAt;
  final Map<String, UnitPerformance> unitBreakdown;
  final List<IncorrectAnswer> incorrectQuestionDetails;

  /// Passing score threshold (80% = 24/30)
  static const int passingScore = 24;
  
  /// Total number of questions in the test
  static const int totalTestQuestions = 30;

  Phase3TestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.passed,
    required this.completedAt,
    required this.unitBreakdown,
    required this.incorrectQuestionDetails,
  });

  /// Creates a Phase3TestResult from calculated values.
  /// 
  /// Automatically calculates:
  /// - incorrectAnswers from totalQuestions - correctAnswers
  /// - accuracy as percentage
  /// - passed status based on passingScore threshold
  factory Phase3TestResult.calculate({
    required int correctAnswers,
    required DateTime completedAt,
    required Map<String, UnitPerformance> unitBreakdown,
    required List<IncorrectAnswer> incorrectQuestionDetails,
  }) {
    final incorrectAnswers = totalTestQuestions - correctAnswers;
    final accuracy = (correctAnswers / totalTestQuestions) * 100;
    final passed = correctAnswers >= passingScore;

    return Phase3TestResult(
      totalQuestions: totalTestQuestions,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      accuracy: accuracy,
      passed: passed,
      completedAt: completedAt,
      unitBreakdown: unitBreakdown,
      incorrectQuestionDetails: incorrectQuestionDetails,
    );
  }

  factory Phase3TestResult.fromJson(Map<String, dynamic> json) {
    // Parse unit breakdown map
    final unitBreakdownJson = json['unitBreakdown'] as Map<String, dynamic>;
    final unitBreakdown = <String, UnitPerformance>{};
    
    unitBreakdownJson.forEach((key, value) {
      unitBreakdown[key] = UnitPerformance.fromJson(value as Map<String, dynamic>);
    });

    return Phase3TestResult(
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      incorrectAnswers: json['incorrectAnswers'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      passed: json['passed'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      unitBreakdown: unitBreakdown,
      incorrectQuestionDetails: (json['incorrectQuestionDetails'] as List)
          .map((item) => IncorrectAnswer.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    // Convert unit breakdown map to JSON
    final unitBreakdownJson = <String, dynamic>{};
    unitBreakdown.forEach((key, value) {
      unitBreakdownJson[key] = value.toJson();
    });

    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'accuracy': accuracy,
      'passed': passed,
      'completedAt': completedAt.toIso8601String(),
      'unitBreakdown': unitBreakdownJson,
      'incorrectQuestionDetails':
          incorrectQuestionDetails.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Phase3TestResult(score: $correctAnswers/$totalQuestions, accuracy: ${accuracy.toStringAsFixed(1)}%, passed: $passed)';
  }
}
