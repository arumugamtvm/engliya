import 'incorrect_answer.dart';

class TestResult {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final bool passed;
  final DateTime completedAt;
  final List<IncorrectAnswer> incorrectQuestionDetails;

  TestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.passed,
    required this.completedAt,
    required this.incorrectQuestionDetails,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      incorrectAnswers: json['incorrectAnswers'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      passed: json['passed'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      incorrectQuestionDetails: (json['incorrectQuestionDetails'] as List)
          .map((item) => IncorrectAnswer.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'accuracy': accuracy,
      'passed': passed,
      'completedAt': completedAt.toIso8601String(),
      'incorrectQuestionDetails':
          incorrectQuestionDetails.map((item) => item.toJson()).toList(),
    };
  }
}
