import 'incorrect_answer.dart';
import 'unit_performance.dart';

class Phase2TestResult {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final bool passed;
  final DateTime completedAt;
  final Map<String, UnitPerformance> unitBreakdown;
  final List<IncorrectAnswer> incorrectQuestionDetails;

  Phase2TestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.passed,
    required this.completedAt,
    required this.unitBreakdown,
    required this.incorrectQuestionDetails,
  });

  factory Phase2TestResult.fromJson(Map<String, dynamic> json) {
    // Parse unit breakdown map
    final unitBreakdownJson = json['unitBreakdown'] as Map<String, dynamic>;
    final unitBreakdown = <String, UnitPerformance>{};
    
    unitBreakdownJson.forEach((key, value) {
      unitBreakdown[key] = UnitPerformance.fromJson(value as Map<String, dynamic>);
    });

    return Phase2TestResult(
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
}
