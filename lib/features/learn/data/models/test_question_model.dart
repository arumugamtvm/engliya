import '../../domain/entities/test_question.dart';

/// Data model for TestQuestion with JSON serialization support
/// Extends the domain entity to add serialization capabilities
class TestQuestionModel extends TestQuestion {
  const TestQuestionModel({
    required super.id,
    required super.lessonId,
    required super.lessonTitle,
    super.unitId,
    required super.promptEn,
    super.promptTa,
    required super.options,
    required super.correctIndex,
    super.questionType = 'mcq',
  });

  /// Create a TestQuestionModel from JSON data
  factory TestQuestionModel.fromJson(Map<String, dynamic> json) {
    return TestQuestionModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String,
      unitId: json['unitId'] as String?,
      promptEn: json['promptEn'] as String,
      promptTa: json['promptTa'] as String?,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      questionType: json['questionType'] as String? ?? 'mcq',
    );
  }

  /// Create a TestQuestionModel from lesson question JSON data
  /// Used when loading questions from lesson asset files
  factory TestQuestionModel.fromLessonQuestion(
    Map<String, dynamic> json,
    String lessonId,
    String lessonTitle,
    String? unitId,
  ) {
    // Generate unique ID from lessonId and question content
    final id = '${lessonId}_${json['promptEn'].toString().hashCode}';

    return TestQuestionModel(
      id: id,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      unitId: unitId,
      promptEn: json['promptEn'] as String,
      promptTa: json['promptTa'] as String?,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      questionType: json['type'] as String? ?? 'mcq',
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      if (unitId != null) 'unitId': unitId,
      'promptEn': promptEn,
      if (promptTa != null) 'promptTa': promptTa,
      'options': options,
      'correctIndex': correctIndex,
      'questionType': questionType,
    };
  }

  /// Convert to domain entity
  TestQuestion toEntity() {
    return TestQuestion(
      id: id,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      unitId: unitId,
      promptEn: promptEn,
      promptTa: promptTa,
      options: List.unmodifiable(options),
      correctIndex: correctIndex,
      questionType: questionType,
    );
  }

  /// Create a TestQuestionModel from a domain entity
  factory TestQuestionModel.fromEntity(TestQuestion entity) {
    return TestQuestionModel(
      id: entity.id,
      lessonId: entity.lessonId,
      lessonTitle: entity.lessonTitle,
      unitId: entity.unitId,
      promptEn: entity.promptEn,
      promptTa: entity.promptTa,
      options: entity.options,
      correctIndex: entity.correctIndex,
      questionType: entity.questionType,
    );
  }
}
