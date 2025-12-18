class Phase2FinalTestQuestion {
  final String id;
  final String unitId;
  final String lessonId;
  final String lessonTitle;
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;
  final String questionType;

  Phase2FinalTestQuestion({
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

  /// Factory constructor to create Phase2FinalTestQuestion from lesson question JSON
  factory Phase2FinalTestQuestion.fromLessonQuestion(
    Map<String, dynamic> json,
    String lessonId,
    String lessonTitle,
    String unitId,
  ) {
    // Generate unique ID from lessonId and question content
    final id = '${lessonId}_${json['promptEn'].toString().hashCode}';
    
    return Phase2FinalTestQuestion(
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

  factory Phase2FinalTestQuestion.fromJson(Map<String, dynamic> json) {
    return Phase2FinalTestQuestion(
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
}
