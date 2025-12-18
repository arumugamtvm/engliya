import 'phase4_final_test_question.dart';

/// Model representing the result of a speaking task in the Phase 4 Final Test.
///
/// Speaking tasks are scored 0-3 points based on word count and clarity:
/// - 3 points: 20+ words, clear recognition (good fluency)
/// - 2 points: 10-19 words (okay but short)
/// - 1 point: 1-9 words (very short)
/// - 0 points: No output detected
class SpeakingResult {
  final String taskId;
  final String prompt;
  final String? recognizedText;
  final int wordCount;
  final int score;
  final String feedback;

  SpeakingResult({
    required this.taskId,
    required this.prompt,
    this.recognizedText,
    required this.wordCount,
    required this.score,
    required this.feedback,
  });

  /// Creates a SpeakingResult with automatic scoring based on word count.
  ///
  /// Scoring tiers:
  /// - 20+ words: 3 points ("Great fluency! Clear and natural speech.")
  /// - 10-19 words: 2 points ("Good effort! Try to expand your response.")
  /// - 1-9 words: 1 point ("Keep practicing! Try to speak more.")
  /// - 0 words: 0 points ("No speech detected. Please try again.")
  factory SpeakingResult.fromRecognition({
    required String taskId,
    required String prompt,
    String? recognizedText,
  }) {
    final wordCount = _countWords(recognizedText);
    final score = _calculateScore(wordCount);
    final feedback = _generateFeedback(score);

    return SpeakingResult(
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

  /// Calculates score based on word count.
  ///
  /// - 20+ words: 3 points
  /// - 10-19 words: 2 points
  /// - 1-9 words: 1 point
  /// - 0 words: 0 points
  static int _calculateScore(int wordCount) {
    if (wordCount >= 20) return 3;
    if (wordCount >= 10) return 2;
    if (wordCount >= 1) return 1;
    return 0;
  }

  /// Generates feedback message based on score.
  static String _generateFeedback(int score) {
    switch (score) {
      case 3:
        return 'Great fluency! Clear and natural speech.';
      case 2:
        return 'Good effort! Try to expand your response.';
      case 1:
        return 'Keep practicing! Try to speak more.';
      default:
        return 'No speech detected. Please try again.';
    }
  }

  factory SpeakingResult.fromJson(Map<String, dynamic> json) {
    return SpeakingResult(
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
    return 'SpeakingResult(taskId: $taskId, wordCount: $wordCount, score: $score)';
  }
}

/// Model representing an incorrectly answered MCQ in the Phase 4 Final Test.
///
/// Only MCQ questions (pronunciation, dialogue, listening) can be incorrect.
/// Speaking tasks are excluded from the incorrect answers list.
class Phase4IncorrectAnswer {
  final Phase4FinalTestQuestion question;
  final int selectedIndex;
  final String selectedAnswer;
  final String correctAnswer;

  Phase4IncorrectAnswer({
    required this.question,
    required this.selectedIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  factory Phase4IncorrectAnswer.fromJson(Map<String, dynamic> json) {
    return Phase4IncorrectAnswer(
      question: Phase4FinalTestQuestion.fromJson(
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

/// Model representing the result of a Phase 4 Final Test.
///
/// The test consists of 20 questions with a maximum score of 24 points:
/// - 6 Pronunciation MCQs (1 point each = 6 points max)
/// - 6 Dialogue Response MCQs (1 point each = 6 points max)
/// - 4 Listening MCQs (1 point each = 4 points max)
/// - 4 Speaking Tasks (0-3 points each = 12 points max)
///
/// Passing threshold: 18/24 (75%)
class Phase4TestResult {
  final int totalQuestions;
  final int maxScore;
  final int mcqCorrect;
  final int speakingScore;
  final int totalScore;
  final double percentage;
  final bool passed;
  final DateTime completedAt;
  final List<Phase4IncorrectAnswer> incorrectMcqAnswers;
  final List<SpeakingResult> speakingResults;

  /// Passing score threshold (75% = 18/24)
  static const int passingScore = 18;

  /// Maximum possible score
  static const int maxPossibleScore = 24;

  /// Total number of questions in the test
  static const int totalTestQuestions = 20;

  /// Number of MCQ questions (pronunciation + dialogue + listening)
  static const int mcqCount = 16;

  /// Number of speaking tasks
  static const int speakingCount = 4;

  /// Maximum points from MCQs (16 questions × 1 point)
  static const int maxMcqScore = 16;

  /// Maximum points from speaking (4 tasks × 3 points)
  static const int maxSpeakingScore = 12;

  Phase4TestResult({
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

  /// Creates a Phase4TestResult from calculated values.
  ///
  /// Automatically calculates:
  /// - totalScore from mcqCorrect + speakingScore
  /// - percentage as (totalScore / maxPossibleScore) * 100
  /// - passed status based on passingScore threshold (>= 18)
  factory Phase4TestResult.calculate({
    required int mcqCorrect,
    required int speakingScore,
    required DateTime completedAt,
    required List<Phase4IncorrectAnswer> incorrectMcqAnswers,
    required List<SpeakingResult> speakingResults,
  }) {
    final totalScore = mcqCorrect + speakingScore;
    final percentage = (totalScore / maxPossibleScore) * 100;
    final passed = totalScore >= passingScore;

    return Phase4TestResult(
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

  factory Phase4TestResult.fromJson(Map<String, dynamic> json) {
    return Phase4TestResult(
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
              Phase4IncorrectAnswer.fromJson(item as Map<String, dynamic>))
          .toList(),
      speakingResults: (json['speakingResults'] as List)
          .map((item) => SpeakingResult.fromJson(item as Map<String, dynamic>))
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
    return 'Phase4TestResult(score: $totalScore/$maxScore, percentage: ${percentage.toStringAsFixed(1)}%, passed: $passed)';
  }
}
