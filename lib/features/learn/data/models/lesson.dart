import 'package:flutter/foundation.dart';
import 'lesson_explain.dart';
import 'example_sentence.dart';
import 'listening_question.dart';
import 'speak_sentence.dart';
import 'quiz_question.dart';

@immutable
class Lesson {
  final String id;
  final int order;
  final String unitId;
  final String title;
  final String description;
  final String level;
  final LessonExplain explain;
  final List<ExampleSentence> examples;
  final List<ListeningQuestion> listeningQuestions;
  final List<SpeakSentence> speakSentences;
  final List<QuizQuestion> practiceQuestions;
  final List<QuizQuestion> masteryQuestions;

  const Lesson({
    required this.id,
    required this.order,
    required this.unitId,
    required this.title,
    required this.description,
    required this.level,
    required this.explain,
    required this.examples,
    required this.listeningQuestions,
    required this.speakSentences,
    required this.practiceQuestions,
    required this.masteryQuestions,
  });

  int get totalExamples => examples.length;
  int get totalListeningQuestions => listeningQuestions.length;
  int get totalSpeakSentences => speakSentences.length;
  int get totalPracticeQuestions => practiceQuestions.length;
  int get totalMasteryQuestions => masteryQuestions.length;

  bool get hasExamples => examples.isNotEmpty;
  bool get hasListeningQuestions => listeningQuestions.isNotEmpty;
  bool get hasSpeakSentences => speakSentences.isNotEmpty;
  bool get hasPracticeQuestions => practiceQuestions.isNotEmpty;
  bool get hasMasteryQuestions => masteryQuestions.isNotEmpty;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      unitId: json['unitId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as String? ?? '',
      explain: LessonExplain.fromJson(
        (json['explain'] as Map<String, dynamic>?) ?? {},
      ),
      examples: (json['examples'] as List?)
          ?.map((item) => ExampleSentence.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      listeningQuestions: (json['listeningQuestions'] as List?)
          ?.map((item) => ListeningQuestion.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      speakSentences: (json['speakSentences'] as List?)
          ?.map((item) => SpeakSentence.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      practiceQuestions: (json['practiceQuestions'] as List?)
          ?.map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      masteryQuestions: (json['masteryQuestions'] as List?)
          ?.map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'unitId': unitId,
    'title': title,
    'description': description,
    'level': level,
    'explain': explain.toJson(),
    'examples': examples.map((e) => e.toJson()).toList(),
    'listeningQuestions': listeningQuestions.map((q) => q.toJson()).toList(),
    'speakSentences': speakSentences.map((s) => s.toJson()).toList(),
    'practiceQuestions': practiceQuestions.map((q) => q.toJson()).toList(),
    'masteryQuestions': masteryQuestions.map((q) => q.toJson()).toList(),
  };

  Lesson copyWith({
    String? id,
    int? order,
    String? unitId,
    String? title,
    String? description,
    String? level,
    LessonExplain? explain,
    List<ExampleSentence>? examples,
    List<ListeningQuestion>? listeningQuestions,
    List<SpeakSentence>? speakSentences,
    List<QuizQuestion>? practiceQuestions,
    List<QuizQuestion>? masteryQuestions,
  }) {
    return Lesson(
      id: id ?? this.id,
      order: order ?? this.order,
      unitId: unitId ?? this.unitId,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      explain: explain ?? this.explain,
      examples: examples ?? this.examples,
      listeningQuestions: listeningQuestions ?? this.listeningQuestions,
      speakSentences: speakSentences ?? this.speakSentences,
      practiceQuestions: practiceQuestions ?? this.practiceQuestions,
      masteryQuestions: masteryQuestions ?? this.masteryQuestions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lesson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Lesson($id: $title)';
}
