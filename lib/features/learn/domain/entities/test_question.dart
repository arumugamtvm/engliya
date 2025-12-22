import 'package:flutter/foundation.dart';

/// Immutable domain entity representing a test question
/// Works across all phases with optional unit support
@immutable
class TestQuestion {
  final String id;
  final String lessonId;
  final String lessonTitle;
  final String? unitId;
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;
  final String questionType;

  const TestQuestion({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    this.unitId,
    required this.promptEn,
    this.promptTa,
    required this.options,
    required this.correctIndex,
    this.questionType = 'mcq',
  });

  /// Check if the selected answer is correct
  bool isCorrect(int selectedIndex) {
    if (selectedIndex < 0 || selectedIndex >= options.length) {
      return false;
    }
    return selectedIndex == correctIndex;
  }

  /// Get the correct answer text
  String get correctAnswer {
    if (correctIndex >= 0 && correctIndex < options.length) {
      return options[correctIndex];
    }
    return '';
  }

  /// Get the selected answer text
  String getSelectedAnswer(int selectedIndex) {
    if (selectedIndex >= 0 && selectedIndex < options.length) {
      return options[selectedIndex];
    }
    return 'No answer selected';
  }

  /// Check if this question has a valid structure
  bool get isValid {
    return id.isNotEmpty &&
        lessonId.isNotEmpty &&
        promptEn.isNotEmpty &&
        options.isNotEmpty &&
        correctIndex >= 0 &&
        correctIndex < options.length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lessonId == other.lessonId &&
          lessonTitle == other.lessonTitle &&
          unitId == other.unitId &&
          promptEn == other.promptEn &&
          promptTa == other.promptTa &&
          listEquals(options, other.options) &&
          correctIndex == other.correctIndex &&
          questionType == other.questionType;

  @override
  int get hashCode =>
      id.hashCode ^
      lessonId.hashCode ^
      lessonTitle.hashCode ^
      unitId.hashCode ^
      promptEn.hashCode ^
      promptTa.hashCode ^
      options.hashCode ^
      correctIndex.hashCode ^
      questionType.hashCode;

  @override
  String toString() =>
      'TestQuestion(id: $id, lessonId: $lessonId, unitId: $unitId, type: $questionType)';

  /// Create a copy with modified fields
  TestQuestion copyWith({
    String? id,
    String? lessonId,
    String? lessonTitle,
    String? unitId,
    String? promptEn,
    String? promptTa,
    List<String>? options,
    int? correctIndex,
    String? questionType,
  }) {
    return TestQuestion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      unitId: unitId ?? this.unitId,
      promptEn: promptEn ?? this.promptEn,
      promptTa: promptTa ?? this.promptTa,
      options: options ?? List.unmodifiable(this.options),
      correctIndex: correctIndex ?? this.correctIndex,
      questionType: questionType ?? this.questionType,
    );
  }
}
