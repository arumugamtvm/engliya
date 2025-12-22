/// Enum representing the different question types in the Phase 5 Final Test.
/// 
/// Phase 5 Final Test consists of:
/// - 8 Business English MCQs (professional tone, grammar, workplace communication)
/// - 7 Interview Response MCQs (best interview answer selection)
/// - 6 Presentation Language MCQs (presentation openings, transitions, conclusions)
/// - 6 Writing Logic MCQs (writing structure, conclusions, opinion expression)
/// - 8 Professional Speaking Tasks (30-60 seconds professional speech)
enum Phase5QuestionType {
  businessEnglish,
  interview,
  presentation,
  writing,
  speaking,
}

/// Model representing a single Phase 5 Final Test question.
/// 
/// This is a union type that supports all five question types:
/// - Business English MCQ: Tests professional tone, grammar, and workplace communication
/// - Interview MCQ: Tests ability to select the best interview answers
/// - Presentation MCQ: Tests presentation structure and professional language
/// - Writing MCQ: Tests advanced writing structure and opinion expression
/// - Speaking Task: Tests professional speaking with 30-60 second responses
/// 
/// MCQ types (businessEnglish, interview, presentation, writing) have non-null options and correctIndex.
/// Speaking tasks have null options and correctIndex.
class Phase5FinalTestQuestion {
  final String id;
  final Phase5QuestionType type;
  final String unitId;
  final String lessonId;
  final String prompt;
  final List<String>? options;      // null for speaking tasks
  final int? correctIndex;          // null for speaking tasks

  Phase5FinalTestQuestion({
    required this.id,
    required this.type,
    required this.unitId,
    required this.lessonId,
    required this.prompt,
    this.options,
    this.correctIndex,
  });

  /// Factory constructor for Business English MCQ questions.
  /// 
  /// Business English questions test professional tone, grammar, and workplace communication.
  /// Example prompt: "Choose the most professional sentence for a business email."
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

  /// Factory constructor for Interview Response MCQ questions.
  /// 
  /// Interview questions test ability to select the best interview answers.
  /// Example prompt: "Interviewer: What is your biggest strength?"
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

  /// Factory constructor for Presentation Language MCQ questions.
  /// 
  /// Presentation questions test presentation openings, transitions, and conclusions.
  /// Example prompt: "Choose the best opening sentence for a presentation."
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

  /// Factory constructor for Writing Logic MCQ questions.
  /// 
  /// Writing questions test writing structure, conclusions, and opinion expression.
  /// Example prompt: "Which is the best concluding sentence?"
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

  /// Factory constructor for Professional Speaking Task questions.
  /// 
  /// Speaking tasks require 30-60 seconds of professional speech and are scored 0-4 points.
  /// Example prompt: "Introduce yourself as a software developer in 30 seconds."
  factory Phase5FinalTestQuestion.speaking({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
  }) {
    return Phase5FinalTestQuestion(
      id: id,
      type: Phase5QuestionType.speaking,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: null,
      correctIndex: null,
    );
  }

  /// Returns true if this is an MCQ question (businessEnglish, interview, presentation, or writing).
  bool get isMcq => type != Phase5QuestionType.speaking;

  /// Returns true if this is a speaking task.
  bool get isSpeakingTask => type == Phase5QuestionType.speaking;

  /// Factory constructor to create from JSON.
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
          ? (json['options'] as List).map((e) => e as String).toList()
          : null,
      correctIndex: json['correctIndex'] as int?,
    );
  }

  /// Converts this question to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'unitId': unitId,
      'lessonId': lessonId,
      'prompt': prompt,
      if (options != null) 'options': options,
      if (correctIndex != null) 'correctIndex': correctIndex,
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
