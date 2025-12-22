import 'package:flutter/foundation.dart';

@immutable
abstract class BaseTestResult {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final bool passed;
  final DateTime timestamp;
  final Duration? duration;

  const BaseTestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.passed,
    required this.timestamp,
    this.duration,
  });

  int get incorrectAnswers => totalQuestions - correctAnswers;
  
  double get score => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseTestResult &&
        other.totalQuestions == totalQuestions &&
        other.correctAnswers == correctAnswers &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(totalQuestions, correctAnswers, timestamp);
}

@immutable
class UnitPerformance {
  final String unitId;
  final String unitName;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;

  const UnitPerformance({
    required this.unitId,
    required this.unitName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
  });

  factory UnitPerformance.fromJson(Map<String, dynamic> json) {
    return UnitPerformance(
      unitId: json['unitId'] as String,
      unitName: json['unitName'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
    );
  }

  factory UnitPerformance.calculate({
    required String unitId,
    required String unitName,
    required int totalQuestions,
    required int correctAnswers,
  }) {
    final accuracy = totalQuestions > 0 
        ? (correctAnswers / totalQuestions) * 100 
        : 0.0;
    
    return UnitPerformance(
      unitId: unitId,
      unitName: unitName,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      accuracy: accuracy,
    );
  }

  Map<String, dynamic> toJson() => {
    'unitId': unitId,
    'unitName': unitName,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'accuracy': accuracy,
  };

  UnitPerformance copyWith({
    String? unitId,
    String? unitName,
    int? totalQuestions,
    int? correctAnswers,
    double? accuracy,
  }) {
    return UnitPerformance(
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitPerformance &&
        other.unitId == unitId &&
        other.unitName == unitName;
  }

  @override
  int get hashCode => Object.hash(unitId, unitName);

  @override
  String toString() => 'UnitPerformance($unitName: $accuracy%)';
}

@immutable
class IncorrectAnswerRecord {
  final String questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final String? explanation;
  final String? unitId;

  const IncorrectAnswerRecord({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    this.explanation,
    this.unitId,
  });

  factory IncorrectAnswerRecord.fromJson(Map<String, dynamic> json) {
    return IncorrectAnswerRecord(
      questionId: json['questionId'] as String,
      question: json['question'] as String,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      unitId: json['unitId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'question': question,
    'userAnswer': userAnswer,
    'correctAnswer': correctAnswer,
    if (explanation != null) 'explanation': explanation,
    if (unitId != null) 'unitId': unitId,
  };

  IncorrectAnswerRecord copyWith({
    String? questionId,
    String? question,
    String? userAnswer,
    String? correctAnswer,
    String? explanation,
    String? unitId,
  }) {
    return IncorrectAnswerRecord(
      questionId: questionId ?? this.questionId,
      question: question ?? this.question,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      unitId: unitId ?? this.unitId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IncorrectAnswerRecord && other.questionId == questionId;
  }

  @override
  int get hashCode => questionId.hashCode;
}
