import 'phase5_final_test_question.dart';

/// Model representing the result of a speaking task in the Phase 5 Final Test.
///
/// Speaking tasks are scored 0-4 points based on word count and professional quality:
/// - 4 points: 40-80 words, clear, confident, well-structured (excellent)
/// - 3 points: 25-39 words, good but slightly short
/// - 2 points: 10-24 words, basic, lacks structure
/// - 1 point: 1-9 words, very weak
/// - 0 points: No output detected
class Phase5SpeakingResult {
  final String taskId;
  final String prompt;
  final String? recognizedText;
  final int wordCount;
  final int score;
  final String feedback;

  Phase5SpeakingResult({
    required this.taskId,
    required this.prompt,
    this.recognizedText,
    required this.wordCount,
    required this.score,
    required this.feedback,
  });

  /// Creates a Phase5SpeakingResult with automatic scoring based on word count.
  ///
  /// Scoring tiers (enhanced for professional level):
  /// - 40-80 words: 4 points ("Excellent! Clear, confident, and well-structured response.")
  /// - 25-39 words: 3 points ("Good response! Try to expand with more details.")
  /// - 10-24 words: 2 points ("Basic response. Work on structure and confidence.")
  /// - 1-9 words: 1 point ("Very brief. Practice speaking in complete sentences.")
  /// - 0 words: 0 points ("No speech detected. Please try again.")
  factory Phase5SpeakingResult.fromRecognition({
    required String taskId,
    required String prompt,
    String? recognizedText,
  }) {
    final wordCount = _countWords(recognizedText);
    final score = _calculateScore(wordCount);
    final feedback = _generateFeedback(score);

    return Phase5SpeakingResult(
      taskId: taskId,
      prompt: prompt,
      recognizedText: recognizedText,
      wordCount: wordCount,
      score: score,
      feedback: feedback,
    );
  }

  /// Counts words in the recognized text.
  static int _countWords(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Calculates score based on word count (enhanced for professional level).
  ///
  /// - 40-80 words: 4 points (excellent)
  /// - 25-39 words: 3 points (good)
  /// - 10-24 words: 2 points (basic)
  /// - 1-9 words: 1 point (weak)
  /// - 0 words: 0 points (no response)
  static int _calculateScore(int wordCount) {
    if (wordCount >= 40 && wordCount <= 80) return 4;
    if (wordCount >= 25) return 3;
    if (wordCount >= 10) return 2;
    if (wordCount >= 1) return 1;
    return 0;
  }

  /// Generates feedback message based on score.
  static String _generateFeedback(int score) {
    switch (score) {
      case 4:
        return 'Excellent! Clear, confident, and well-structured response.';
      case 3:
        return 'Good response! Try to expand with more details.';
      case 2:
        return 'Basic response. Work on structure and confidence.';
      case 1:
        return 'Very brief. Practice speaking in complete sentences.';
      default:
        return 'No speech detected. Please try again.';
    }
  }

  factory Phase5SpeakingResult.fromJson(Map<String, dynamic> json) {
    return Phase5SpeakingResult(
      taskId: json['taskId'] as String,
      prompt: json['prompt'] as String,
      recognizedText: json['recognizedText'] as String?,
      wordCount: json['wordCount'] as int,
      score: json['score'] as int,
      feedback: json['feedback'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'prompt': prompt,
      'recognizedText': recognizedText,
      'wordCount': wordCount,
      'score': score,
      'feedback': feedback,
    };
  }

  @override
  String toString() {
    return 'Phase5SpeakingResult(taskId: $taskId, wordCount: $wordCount, score: $score)';
  }
}

/// Model representing an incorrectly answered MCQ in the Phase 5 Final Test.
///
/// Only MCQ questions (businessEnglish, interview, presentation, writing) can be incorrect.
/// Speaking tasks are excluded from the incorrect answers list.
class Phase5IncorrectAnswer {
  final Phase5FinalTestQuestion question;
  final int selectedIndex;
  final String selectedAnswer;
  final String correctAnswer;

  Phase5IncorrectAnswer({
    required this.question,
    required this.selectedIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  factory Phase5IncorrectAnswer.fromJson(Map<String, dynamic> json) {
    return Phase5IncorrectAnswer(
      question: Phase5FinalTestQuestion.fromJson(
          json['question'] as Map<String, dynamic>),
      selectedIndex: json['selectedIndex'] as int,
      selectedAnswer: json['selectedAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question.toJson(),
      'selectedIndex': selectedIndex,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
    };
  }
}

/// Model representing the result of a Phase 5 Final Test.
///
/// The test consists of 35 tasks with a maximum score of 60 points:
/// - 8 Business English MCQs (1 point each = 8 points max)
/// - 7 Interview Response MCQs (1 point each = 7 points max)
/// - 6 Presentation Language MCQs (1 point each = 6 points max)
/// - 6 Writing Logic MCQs (1 point each = 6 points max)
/// - 8 Professional Speaking Tasks (0-4 points each = 32 points max)
///
/// Passing threshold: 45/60 (75%)
class Phase5TestResult {
  final int totalQuestions;
  final int maxScore;
  final int mcqCorrect;
  final int speakingScore;
  final int totalScore;
  final double percentage;
  final bool passed;
  final DateTime completedAt;
  final List<Phase5IncorrectAnswer> incorrectMcqAnswers;
  final List<Phase5SpeakingResult> speakingResults;

  /// Passing score threshold (75% = 45/60)
  static const int passingScore = 45;

  /// Maximum possible score
  static const int maxPossibleScore = 60;

  /// Total number of tasks in the test
  static const int totalTestQuestions = 35;

  /// Number of MCQ questions (business + interview + presentation + writing)
  static const int mcqCount = 27; // 8 + 7 + 6 + 6

  /// Number of speaking tasks
  static const int speakingCount = 8;

  /// Maximum points from MCQs (27 questions × 1 point)
  static const int maxMcqScore = 27;

  /// Maximum points from speaking (8 tasks × 4 points)
  static const int maxSpeakingScore = 32;

  Phase5TestResult({
    required this.totalQuestions,
    required this.maxScore,
    required this.mcqCorrect,
    required this.speakingScore,
    required this.totalScore,
    required this.percentage,
    required this.passed,
    required this.completedAt,
    required this.incorrectMcqAnswers,
    required this.speakingResults,
  });

  /// Creates a Phase5TestResult from calculated values.
  ///
  /// Automatically calculates:
  /// - totalScore from mcqCorrect + speakingScore
  /// - percentage as (totalScore / maxPossibleScore) * 100
  /// - passed status based on passingScore threshold (>= 45)
  factory Phase5TestResult.calculate({
    required int mcqCorrect,
    required int speakingScore,
    required DateTime completedAt,
    required List<Phase5IncorrectAnswer> incorrectMcqAnswers,
    required List<Phase5SpeakingResult> speakingResults,
  }) {
    final totalScore = mcqCorrect + speakingScore;
    final percentage = (totalScore / maxPossibleScore) * 100;
    final passed = totalScore >= passingScore;

    return Phase5TestResult(
      totalQuestions: totalTestQuestions,
      maxScore: maxPossibleScore,
      mcqCorrect: mcqCorrect,
      speakingScore: speakingScore,
      totalScore: totalScore,
      percentage: percentage,
      passed: passed,
      completedAt: completedAt,
      incorrectMcqAnswers: incorrectMcqAnswers,
      speakingResults: speakingResults,
    );
  }

  factory Phase5TestResult.fromJson(Map<String, dynamic> json) {
    return Phase5TestResult(
      totalQuestions: json['totalQuestions'] as int,
      maxScore: json['maxScore'] as int,
      mcqCorrect: json['mcqCorrect'] as int,
      speakingScore: json['speakingScore'] as int,
      totalScore: json['totalScore'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      passed: json['passed'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      incorrectMcqAnswers: (json['incorrectMcqAnswers'] as List)
          .map((item) =>
              Phase5IncorrectAnswer.fromJson(item as Map<String, dynamic>))
          .toList(),
      speakingResults: (json['speakingResults'] as List)
          .map((item) => Phase5SpeakingResult.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'maxScore': maxScore,
      'mcqCorrect': mcqCorrect,
      'speakingScore': speakingScore,
      'totalScore': totalScore,
      'percentage': percentage,
      'passed': passed,
      'completedAt': completedAt.toIso8601String(),
      'incorrectMcqAnswers':
          incorrectMcqAnswers.map((item) => item.toJson()).toList(),
      'speakingResults': speakingResults.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Phase5TestResult(score: $totalScore/$maxScore, percentage: ${percentage.toStringAsFixed(1)}%, passed: $passed)';
  }
}
