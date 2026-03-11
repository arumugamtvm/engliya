/// Enum representing the different question types in the Phase 5 Final Test.
enum Phase5QuestionType {
  businessEnglish,
  interview,
  presentation,
  writing,
  shortAnswer,
  rewrite,
  ordering,
  speakingRubricScored,
  writingRubricScored,
}

class Phase5FinalTestQuestion {
  final String id;
  final Phase5QuestionType type;
  final String unitId;
  final String lessonId;
  final String prompt;
  final List<String>? options;
  final int? correctIndex;
  final String? expectedAnswer;

  Phase5FinalTestQuestion({
    required this.id,
    required this.type,
    required this.unitId,
    required this.lessonId,
    required this.prompt,
    this.options,
    this.correctIndex,
    this.expectedAnswer,
  });

  factory Phase5FinalTestQuestion.businessEnglish({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.businessEnglish,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }

  factory Phase5FinalTestQuestion.interview({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.interview,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }

  factory Phase5FinalTestQuestion.presentation({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.presentation,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }

  factory Phase5FinalTestQuestion.writing({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.writing,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }

  factory Phase5FinalTestQuestion.shortAnswer({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required String expectedAnswer,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.shortAnswer,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      expectedAnswer: expectedAnswer,
    );
  }

  factory Phase5FinalTestQuestion.rewrite({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required String expectedAnswer,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.rewrite,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      expectedAnswer: expectedAnswer,
    );
  }

  factory Phase5FinalTestQuestion.ordering({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.ordering,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }

  factory Phase5FinalTestQuestion.speakingRubricScored({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.speakingRubricScored,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
    );
  }

  factory Phase5FinalTestQuestion.writingRubricScored({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.writingRubricScored,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
    );
  }

  bool get isMcq =>
      type == Phase5QuestionType.businessEnglish ||
      type == Phase5QuestionType.interview ||
      type == Phase5QuestionType.presentation ||
      type == Phase5QuestionType.writing ||
      type == Phase5QuestionType.ordering;

  bool get isSpeakingTask => type == Phase5QuestionType.speakingRubricScored;
  bool get isWritingTask => type == Phase5QuestionType.writingRubricScored;

  factory Phase5FinalTestQuestion.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = Phase5QuestionType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => Phase5QuestionType.businessEnglish,
    );

    return Phase5FinalTestQuestion(
      id: json['id'] as String,
      type: type,
      unitId: json['unitId'] as String,
      lessonId: json['lessonId'] as String,
      prompt: json['prompt'] as String,
      options: json['options'] != null
          ? (json['options'] as List<dynamic>).map((e) => e as String).toList()
          : null,
      correctIndex: json['correctIndex'] as int?,
      expectedAnswer: json['expectedAnswer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'unitId': unitId,
      'lessonId': lessonId,
      'prompt': prompt,
      if (options != null) 'options': options,
      if (correctIndex != null) 'correctIndex': correctIndex,
      if (expectedAnswer != null) 'expectedAnswer': expectedAnswer,
    };
  }

  @override
  String toString() {
    return 'Phase5FinalTestQuestion(id: $id, type: ${type.name}, unitId: $unitId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Phase5FinalTestQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
