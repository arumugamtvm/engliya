class QuizQuestion {
  final String type;
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.type,
    required this.promptEn,
    this.promptTa,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      type: json['type'] as String,
      promptEn: json['promptEn'] as String,
      promptTa: json['promptTa'] as String?,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'promptEn': promptEn,
      if (promptTa != null) 'promptTa': promptTa,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}
