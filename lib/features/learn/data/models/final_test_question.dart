class FinalTestQuestion {
  final String lessonId;
  final String lessonTitle;
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;
  final String questionType;

  FinalTestQuestion({
    required this.lessonId,
    required this.lessonTitle,
    required this.promptEn,
    this.promptTa,
    required this.options,
    required this.correctIndex,
    this.questionType = 'mcq',
  });

  /// Factory constructor to create FinalTestQuestion from lesson question JSON
  factory FinalTestQuestion.fromLessonQuestion(
    Map<String, dynamic> json,
    String lessonId,
    String lessonTitle,
  ) {
    return FinalTestQuestion(
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      promptEn: json['promptEn'] as String,
      promptTa: json['promptTa'] as String?,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      questionType: json['type'] as String? ?? 'mcq',
    );
  }

  factory FinalTestQuestion.fromJson(Map<String, dynamic> json) {
    return FinalTestQuestion(
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
