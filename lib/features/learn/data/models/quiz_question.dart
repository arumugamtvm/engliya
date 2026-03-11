import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  final String type;
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;
  final String? expectedAnswerEn;
  final List<String> acceptableAnswers;
  final List<String> orderingItems;
  final String? rubricMode;

  const QuizQuestion({
    required this.type,
    required this.promptEn,
    this.promptTa,
    required this.options,
    required this.correctIndex,
    this.expectedAnswerEn,
    this.acceptableAnswers = const [],
    this.orderingItems = const [],
    this.rubricMode,
  });

  bool get isMcqLike => options.isNotEmpty && correctIndex >= 0;

  String get correctAnswer =>
      (correctIndex >= 0 && correctIndex < options.length)
      ? options[correctIndex]
      : expectedAnswerEn ?? '';

  bool isCorrectAnswer(int index) => index == correctIndex;

  bool isCorrectAnswerText(String answer) {
    final normalized = answer.trim().toLowerCase();
    if (expectedAnswerEn != null &&
        normalized == expectedAnswerEn!.trim().toLowerCase()) {
      return true;
    }
    return acceptableAnswers
        .map((item) => item.trim().toLowerCase())
        .contains(normalized);
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(growable: false);

    return QuizQuestion(
      type: json['type'] as String? ?? 'mcq',
      promptEn: json['promptEn'] as String? ?? '',
      promptTa: json['promptTa'] as String?,
      options: options,
      correctIndex: json['correctIndex'] as int? ?? (options.isEmpty ? -1 : 0),
      expectedAnswerEn: json['expectedAnswerEn'] as String?,
      acceptableAnswers:
          (json['acceptableAnswers'] as List<dynamic>? ?? const [])
              .map((e) => e as String)
              .toList(growable: false),
      orderingItems: (json['orderingItems'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(growable: false),
      rubricMode: json['rubricMode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'promptEn': promptEn,
    if (promptTa != null) 'promptTa': promptTa,
    'options': options,
    'correctIndex': correctIndex,
    if (expectedAnswerEn != null) 'expectedAnswerEn': expectedAnswerEn,
    if (acceptableAnswers.isNotEmpty) 'acceptableAnswers': acceptableAnswers,
    if (orderingItems.isNotEmpty) 'orderingItems': orderingItems,
    if (rubricMode != null) 'rubricMode': rubricMode,
  };

  QuizQuestion copyWith({
    String? type,
    String? promptEn,
    String? promptTa,
    List<String>? options,
    int? correctIndex,
    String? expectedAnswerEn,
    List<String>? acceptableAnswers,
    List<String>? orderingItems,
    String? rubricMode,
  }) {
    return QuizQuestion(
      type: type ?? this.type,
      promptEn: promptEn ?? this.promptEn,
      promptTa: promptTa ?? this.promptTa,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      expectedAnswerEn: expectedAnswerEn ?? this.expectedAnswerEn,
      acceptableAnswers: acceptableAnswers ?? this.acceptableAnswers,
      orderingItems: orderingItems ?? this.orderingItems,
      rubricMode: rubricMode ?? this.rubricMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestion &&
        other.type == type &&
        other.promptEn == promptEn &&
        other.correctIndex == correctIndex &&
        other.expectedAnswerEn == expectedAnswerEn &&
        other.rubricMode == rubricMode &&
        listEquals(other.options, options) &&
        listEquals(other.acceptableAnswers, acceptableAnswers) &&
        listEquals(other.orderingItems, orderingItems);
  }

  @override
  int get hashCode => Object.hash(
    type,
    promptEn,
    correctIndex,
    expectedAnswerEn,
    rubricMode,
    Object.hashAll(options),
    Object.hashAll(acceptableAnswers),
    Object.hashAll(orderingItems),
  );

  @override
  String toString() => 'QuizQuestion(type: $type, promptEn: $promptEn)';
}
