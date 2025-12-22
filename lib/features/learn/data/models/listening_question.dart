import 'package:flutter/foundation.dart';

@immutable
class ListeningQuestion {
  final String audioText;
  final List<String> options;
  final int correctIndex;

  const ListeningQuestion({
    required this.audioText,
    required this.options,
    required this.correctIndex,
  });

  String get correctAnswer =>
      (correctIndex >= 0 && correctIndex < options.length)
          ? options[correctIndex]
          : '';

  bool isCorrectAnswer(int index) => index == correctIndex;

  factory ListeningQuestion.fromJson(Map<String, dynamic> json) {
    return ListeningQuestion(
      audioText: json['audioText'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e as String).toList() ?? [],
      correctIndex: json['correctIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'audioText': audioText,
    'options': options,
    'correctIndex': correctIndex,
  };

  ListeningQuestion copyWith({
    String? audioText,
    List<String>? options,
    int? correctIndex,
  }) {
    return ListeningQuestion(
      audioText: audioText ?? this.audioText,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListeningQuestion &&
        other.audioText == audioText &&
        other.correctIndex == correctIndex &&
        listEquals(other.options, options);
  }

  @override
  int get hashCode => Object.hash(audioText, correctIndex, Object.hashAll(options));

  @override
  String toString() => 'ListeningQuestion(audioText: $audioText)';
}
