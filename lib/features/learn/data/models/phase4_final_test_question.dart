/// Enum representing the different question types in the Phase 4 Final Test.
/// 
/// Phase 4 Final Test consists of:
/// - 6 Pronunciation MCQs (syllable stress, rhythm, natural sounds)
/// - 6 Dialogue Response MCQs (best reply selection)
/// - 4 Listening Comprehension MCQs (audio/dialogue based)
/// - 4 Speaking Tasks (prompted speaking exercises)
enum Phase4QuestionType {
  pronunciation,
  dialogue,
  listening,
  speaking,
}

/// Model representing a single Phase 4 Final Test question.
/// 
/// This is a union type that supports all four question types:
/// - Pronunciation MCQ: Tests syllable stress, rhythm, and natural sound patterns
/// - Dialogue MCQ: Tests ability to choose appropriate replies in conversations
/// - Listening MCQ: Tests comprehension of spoken English conversations
/// - Speaking Task: Tests speaking fluency with prompted exercises
/// 
/// MCQ types (pronunciation, dialogue, listening) have non-null options and correctIndex.
/// Speaking tasks have null options and correctIndex.
class Phase4FinalTestQuestion {
  final String id;
  final Phase4QuestionType type;
  final String unitId;
  final String lessonId;
  final String prompt;
  final List<String>? options;      // null for speaking tasks
  final int? correctIndex;          // null for speaking tasks
  final String? audioText;          // for listening questions (dialogue text to display)

  Phase4FinalTestQuestion({
    required this.id,
    required this.type,
    required this.unitId,
    required this.lessonId,
    required this.prompt,
    this.options,
    this.correctIndex,
    this.audioText,
  });

  /// Factory constructor for pronunciation MCQ questions.
  /// 
  /// Pronunciation questions test syllable stress, rhythm, and natural sound patterns.
  /// Example prompt: "Which sentence sounds more natural?"
  factory Phase4FinalTestQuestion.pronunciation({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return Phase4FinalTestQuestion(
      id: id,
      type: Phase4QuestionType.pronunciation,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// Factory constructor for dialogue response MCQ questions.
  /// 
  /// Dialogue questions test ability to choose the best reply in conversations.
  /// Example prompt: "Waiter: Would you like anything else?"
  factory Phase4FinalTestQuestion.dialogue({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return Phase4FinalTestQuestion(
      id: id,
      type: Phase4QuestionType.dialogue,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// Factory constructor for listening comprehension MCQ questions.
  /// 
  /// Listening questions test understanding of spoken English conversations.
  /// Can include audioText for displaying dialogue content.
  factory Phase4FinalTestQuestion.listening({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
    required List<String> options,
    required int correctIndex,
    String? audioText,
  }) {
    return Phase4FinalTestQuestion(
      id: id,
      type: Phase4QuestionType.listening,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
      audioText: audioText,
    );
  }

  /// Factory constructor for speaking task questions.
  /// 
  /// Speaking tasks require 20-30 seconds of speech and are scored 0-3 points.
  /// Example prompt: "Describe your last shopping experience in 3-4 sentences"
  factory Phase4FinalTestQuestion.speaking({
    required String id,
    required String unitId,
    required String lessonId,
    required String prompt,
  }) {
    return Phase4FinalTestQuestion(
      id: id,
      type: Phase4QuestionType.speaking,
      unitId: unitId,
      lessonId: lessonId,
      prompt: prompt,
      options: null,
      correctIndex: null,
    );
  }

  /// Returns true if this is an MCQ question (pronunciation, dialogue, or listening).
  bool get isMcq => type != Phase4QuestionType.speaking;

  /// Returns true if this is a speaking task.
  bool get isSpeakingTask => type == Phase4QuestionType.speaking;

  /// Factory constructor to create from JSON.
  factory Phase4FinalTestQuestion.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = Phase4QuestionType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => Phase4QuestionType.pronunciation,
    );

    return Phase4FinalTestQuestion(
      id: json['id'] as String,
      type: type,
      unitId: json['unitId'] as String,
      lessonId: json['lessonId'] as String,
      prompt: json['prompt'] as String,
      options: json['options'] != null
          ? (json['options'] as List).map((e) => e as String).toList()
          : null,
      correctIndex: json['correctIndex'] as int?,
      audioText: json['audioText'] as String?,
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
      if (audioText != null) 'audioText': audioText,
    };
  }

  @override
  String toString() {
    return 'Phase4FinalTestQuestion(id: $id, type: ${type.name}, unitId: $unitId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Phase4FinalTestQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
