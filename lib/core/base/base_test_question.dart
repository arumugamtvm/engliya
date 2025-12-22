import 'package:flutter/foundation.dart';

enum QuestionType {
  mcq('mcq'),
  fillBlank('fill_blank'),
  trueFalse('true_false'),
  matching('matching'),
  speaking('speaking'),
  listening('listening'),
  reorder('reorder'),
  transform('transform'),
  open('open');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value || type.name == value,
      orElse: () => QuestionType.mcq,
    );
  }
}

@immutable
abstract class BaseTestQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final String correctAnswer;
  final String? explanation;
  final String? audioId;

  const BaseTestQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.correctAnswer,
    this.explanation,
    this.audioId,
  });

  bool validateAnswer(String userAnswer);

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseTestQuestion &&
        other.id == id &&
        other.question == question &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, question, type);

  @override
  String toString() => 'BaseTestQuestion(id: $id, type: ${type.value})';
}

@immutable
class MCQTestQuestion extends BaseTestQuestion {
  final List<String> options;

  const MCQTestQuestion({
    required super.id,
    required super.question,
    required super.correctAnswer,
    required this.options,
    super.explanation,
    super.audioId,
  }) : super(type: QuestionType.mcq);

  factory MCQTestQuestion.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? 
        '${json['question'].hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    
    return MCQTestQuestion(
      id: id,
      question: json['question'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? json['answer'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      explanation: json['explanation'] as String?,
      audioId: json['audioId'] as String?,
    );
  }

  @override
  bool validateAnswer(String userAnswer) {
    return userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'type': type.value,
    'correctAnswer': correctAnswer,
    'options': options,
    if (explanation != null) 'explanation': explanation,
    if (audioId != null) 'audioId': audioId,
  };

  MCQTestQuestion copyWith({
    String? id,
    String? question,
    String? correctAnswer,
    List<String>? options,
    String? explanation,
    String? audioId,
  }) {
    return MCQTestQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
      audioId: audioId ?? this.audioId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCQTestQuestion &&
        other.id == id &&
        other.question == question &&
        listEquals(other.options, options);
  }

  @override
  int get hashCode => Object.hash(id, question, Object.hashAll(options));
}

@immutable
class FillBlankTestQuestion extends BaseTestQuestion {
  final String prompt;

  const FillBlankTestQuestion({
    required super.id,
    required super.question,
    required super.correctAnswer,
    required this.prompt,
    super.explanation,
    super.audioId,
  }) : super(type: QuestionType.fillBlank);

  factory FillBlankTestQuestion.fromJson(Map<String, dynamic> json) {
    return FillBlankTestQuestion(
      id: json['id'] as String? ?? 
          '${json['question'].hashCode}_${DateTime.now().millisecondsSinceEpoch}',
      question: json['question'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? json['answer'] as String? ?? '',
      prompt: json['prompt'] as String? ?? json['question'] as String? ?? '',
      explanation: json['explanation'] as String?,
      audioId: json['audioId'] as String?,
    );
  }

  @override
  bool validateAnswer(String userAnswer) {
    return userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'type': type.value,
    'correctAnswer': correctAnswer,
    'prompt': prompt,
    if (explanation != null) 'explanation': explanation,
    if (audioId != null) 'audioId': audioId,
  };

  FillBlankTestQuestion copyWith({
    String? id,
    String? question,
    String? correctAnswer,
    String? prompt,
    String? explanation,
    String? audioId,
  }) {
    return FillBlankTestQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      prompt: prompt ?? this.prompt,
      explanation: explanation ?? this.explanation,
      audioId: audioId ?? this.audioId,
    );
  }
}

@immutable
class SpeakingTestQuestion extends BaseTestQuestion {
  final String targetText;
  final String? audioText;

  const SpeakingTestQuestion({
    required super.id,
    required super.question,
    required this.targetText,
    this.audioText,
    super.explanation,
    super.audioId,
  }) : super(
    type: QuestionType.speaking,
    correctAnswer: '',
  );

  factory SpeakingTestQuestion.fromJson(Map<String, dynamic> json) {
    return SpeakingTestQuestion(
      id: json['id'] as String? ?? 
          '${json['targetText'].hashCode}_${DateTime.now().millisecondsSinceEpoch}',
      question: json['question'] as String? ?? json['prompt'] as String? ?? '',
      targetText: json['targetText'] as String? ?? json['text'] as String? ?? '',
      audioText: json['audioText'] as String?,
      explanation: json['explanation'] as String?,
      audioId: json['audioId'] as String?,
    );
  }

  @override
  bool validateAnswer(String userAnswer) {
    final normalizedUser = _normalizeText(userAnswer);
    final normalizedTarget = _normalizeText(targetText);
    return _calculateSimilarity(normalizedUser, normalizedTarget) >= 0.7;
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;

    final aWords = a.split(' ').toSet();
    final bWords = b.split(' ').toSet();
    final intersection = aWords.intersection(bWords).length;
    final union = aWords.union(bWords).length;

    return union > 0 ? intersection / union : 0.0;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'type': type.value,
    'targetText': targetText,
    if (audioText != null) 'audioText': audioText,
    if (explanation != null) 'explanation': explanation,
    if (audioId != null) 'audioId': audioId,
  };

  SpeakingTestQuestion copyWith({
    String? id,
    String? question,
    String? targetText,
    String? audioText,
    String? explanation,
    String? audioId,
  }) {
    return SpeakingTestQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      targetText: targetText ?? this.targetText,
      audioText: audioText ?? this.audioText,
      explanation: explanation ?? this.explanation,
      audioId: audioId ?? this.audioId,
    );
  }
}
