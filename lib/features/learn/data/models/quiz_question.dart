import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  final String type;
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.type,
    required this.promptEn,
    this.promptTa,
    required this.options,
    required this.correctIndex,
  });

  String get correctAnswer => 
      (correctIndex >= 0 && correctIndex < options.length) 
          ? options[correctIndex] 
          : '';

  bool isCorrectAnswer(int index) => index == correctIndex;
  
  bool isCorrectAnswerText(String answer) => 
      answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      type: json['type'] as String? ?? 'mcq',
      promptEn: json['promptEn'] as String? ?? '',
      promptTa: json['promptTa'] as String?,
      options: (json['options'] as List?)?.map((e) => e as String).toList() ?? [],
      correctIndex: json['correctIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'promptEn': promptEn,
    if (promptTa != null) 'promptTa': promptTa,
    'options': options,
    'correctIndex': correctIndex,
  };

  QuizQuestion copyWith({
    String? type,
    String? promptEn,
    String? promptTa,
    List<String>? options,
    int? correctIndex,
  }) {
    return QuizQuestion(
      type: type ?? this.type,
      promptEn: promptEn ?? this.promptEn,
      promptTa: promptTa ?? this.promptTa,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestion &&
        other.type == type &&
        other.promptEn == promptEn &&
        other.correctIndex == correctIndex &&
        listEquals(other.options, options);
  }

  @override
  int get hashCode => Object.hash(type, promptEn, correctIndex, Object.hashAll(options));

  @override
  String toString() => 'QuizQuestion(type: $type, promptEn: $promptEn)';
}
