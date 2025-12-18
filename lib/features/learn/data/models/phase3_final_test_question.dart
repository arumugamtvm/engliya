/// Model representing a single Phase 3 Final Test question with unit tracking.
/// 
/// Phase 3 covers Units 12-17:
/// - Unit 12: Story Listening & Retelling (6 questions)
/// - Unit 13: Complex Sentences & Connectors (7 questions)
/// - Unit 14: Passive Voice (5 questions)
/// - Unit 15: Reported Speech (5 questions)
/// - Unit 16: Functional English (4 questions)
/// - Unit 17: Speaking & Writing Projects (3 questions)
class Phase3FinalTestQuestion {
  final String id;
  final String unitId;
  final String lessonId;
  final String lessonTitle;
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;
  final String questionType;

  Phase3FinalTestQuestion({
    required this.id,
    required this.unitId,
    required this.lessonId,
    required this.lessonTitle,
    required this.promptEn,
    this.promptTa,
    required this.options,
    required this.correctIndex,
    this.questionType = 'mcq',
  });

  /// Factory constructor to create Phase3FinalTestQuestion from lesson question JSON.
  /// 
  /// Supports three question types:
  /// - Type A: Story Comprehension (story_comprehension)
  /// - Type B: Connector/Sentence Building (connector)
  /// - Type C: Transformations (transformation)
  factory Phase3FinalTestQuestion.fromLessonQuestion(
    Map<String, dynamic> json,
    String lessonId,
    String lessonTitle,
    String unitId,
  ) {
    // Generate unique ID from lessonId and question content
    final id = '${lessonId}_${json['promptEn'].toString().hashCode}';
    
    return Phase3FinalTestQuestion(
      id: id,
      unitId: unitId,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      promptEn: json['promptEn'] as String,
      promptTa: json['promptTa'] as String?,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      questionType: json['type'] as String? ?? 'mcq',
    );
  }

  factory Phase3FinalTestQuestion.fromJson(Map<String, dynamic> json) {
    return Phase3FinalTestQuestion(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String,
      promptEn: json['promptEn'] as String,
      promptTa: json['promptTa'] as String?,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      questionType: json['questionType'] as String? ?? 'mcq',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitId': unitId,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'promptEn': promptEn,
      if (promptTa != null) 'promptTa': promptTa,
      'options': options,
      'correctIndex': correctIndex,
      'questionType': questionType,
    };
  }

  @override
  String toString() {
    return 'Phase3FinalTestQuestion(id: $id, unitId: $unitId, lessonId: $lessonId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Phase3FinalTestQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
