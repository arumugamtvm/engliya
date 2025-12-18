import 'lesson_explain.dart';
import 'example_sentence.dart';
import 'listening_question.dart';
import 'speak_sentence.dart';
import 'quiz_question.dart';

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

  Lesson({
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

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      order: json['order'] as int,
      unitId: json['unitId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      explain: LessonExplain.fromJson(json['explain'] as Map<String, dynamic>),
      examples: (json['examples'] as List)
          .map((item) => ExampleSentence.fromJson(item as Map<String, dynamic>))
          .toList(),
      listeningQuestions: (json['listeningQuestions'] as List)
          .map((item) => ListeningQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      speakSentences: (json['speakSentences'] as List)
          .map((item) => SpeakSentence.fromJson(item as Map<String, dynamic>))
          .toList(),
      practiceQuestions: (json['practiceQuestions'] as List)
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      masteryQuestions: (json['masteryQuestions'] as List)
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }
}
