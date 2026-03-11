import 'phase5_final_test_question.dart';

class RubricDimensionScore {
  final String key;
  final int score;
  final int maxScore;

  RubricDimensionScore({
    required this.key,
    required this.score,
    this.maxScore = 5,
  });

  double get ratio => maxScore == 0 ? 0 : score / maxScore;

  factory RubricDimensionScore.fromJson(Map<String, dynamic> json) {
    return RubricDimensionScore(
      key: json['key'] as String,
      score: json['score'] as int,
      maxScore: json['maxScore'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'score': score, 'maxScore': maxScore};
  }
}

class RubricScoreCard {
  final List<RubricDimensionScore> dimensions;
  final Map<String, double> weights;

  RubricScoreCard({required this.dimensions, required this.weights});

  double get weightedRatio {
    if (dimensions.isEmpty) return 0;
    var totalWeight = 0.0;
    var weighted = 0.0;
    for (final dim in dimensions) {
      final weight = weights[dim.key] ?? 1.0;
      totalWeight += weight;
      weighted += dim.ratio * weight;
    }
    if (totalWeight == 0) return 0;
    return weighted / totalWeight;
  }

  int get weightedScore100 => (weightedRatio * 100).round();

  factory RubricScoreCard.fromJson(Map<String, dynamic> json) {
    return RubricScoreCard(
      dimensions: (json['dimensions'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                RubricDimensionScore.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      weights: (json['weights'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dimensions': dimensions.map((item) => item.toJson()).toList(),
      'weights': weights,
    };
  }
}

class Phase5SpeakingResult {
  final String taskId;
  final String prompt;
  final String? recognizedText;
  final int wordCount;
  final int score;
  final String feedback;
  final double asrConfidence;
  final double fillerRatio;
  final double sentenceCompleteness;
  final RubricScoreCard rubric;

  Phase5SpeakingResult({
    required this.taskId,
    required this.prompt,
    this.recognizedText,
    required this.wordCount,
    required this.score,
    required this.feedback,
    this.asrConfidence = 0.0,
    this.fillerRatio = 0.0,
    this.sentenceCompleteness = 0.0,
    RubricScoreCard? rubric,
  }) : rubric =
           rubric ??
           RubricScoreCard(
             dimensions: [
               RubricDimensionScore(key: 'grammar_accuracy', score: 0),
               RubricDimensionScore(key: 'lexical_range', score: 0),
               RubricDimensionScore(key: 'coherence', score: 0),
               RubricDimensionScore(key: 'task_achievement', score: 0),
               RubricDimensionScore(key: 'pronunciation', score: 0),
             ],
             weights: const {
               'grammar_accuracy': 0.25,
               'lexical_range': 0.2,
               'coherence': 0.2,
               'task_achievement': 0.2,
               'pronunciation': 0.15,
             },
           );

  int get rubricScore100 => rubric.weightedScore100;

  factory Phase5SpeakingResult.fromRecognition({
    required String taskId,
    required String prompt,
    String? recognizedText,
  }) {
    final wordCount = _countWords(recognizedText);
    final asrConfidence = _estimateAsrConfidence(recognizedText);
    final fillerRatio = _estimateFillerRatio(recognizedText);
    final sentenceCompleteness = _estimateSentenceCompleteness(recognizedText);
    final score = _calculateScore(
      wordCount: wordCount,
      asrConfidence: asrConfidence,
      fillerRatio: fillerRatio,
      sentenceCompleteness: sentenceCompleteness,
    );
    final feedback = _generateFeedback(score);

    final rubric = _buildRubricScore(
      wordCount: wordCount,
      asrConfidence: asrConfidence,
      fillerRatio: fillerRatio,
      sentenceCompleteness: sentenceCompleteness,
    );

    return Phase5SpeakingResult(
      taskId: taskId,
      prompt: prompt,
      recognizedText: recognizedText,
      wordCount: wordCount,
      score: score,
      feedback: feedback,
      asrConfidence: asrConfidence,
      fillerRatio: fillerRatio,
      sentenceCompleteness: sentenceCompleteness,
      rubric: rubric,
    );
  }

  static int _countWords(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  static double _estimateAsrConfidence(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    final hasPunctuation = RegExp(r'[.,!?]').hasMatch(text);
    final base = hasPunctuation ? 0.8 : 0.65;
    return base.clamp(0.0, 1.0);
  }

  static double _estimateFillerRatio(String? text) {
    if (text == null || text.trim().isEmpty) return 1.0;
    final words = text.trim().toLowerCase().split(RegExp(r'\s+'));
    if (words.isEmpty) return 1.0;
    const fillers = {'um', 'uh', 'like', 'you know', 'hmm'};
    var fillerCount = 0;
    for (final w in words) {
      if (fillers.contains(w)) fillerCount++;
    }
    return (fillerCount / words.length).clamp(0.0, 1.0);
  }

  static double _estimateSentenceCompleteness(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    final clauses = text
        .split(RegExp(r'[.!?]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (clauses.isEmpty) return 0;
    final complete = clauses
        .where((c) => c.split(RegExp(r'\s+')).length >= 5)
        .length;
    return (complete / clauses.length).clamp(0.0, 1.0);
  }

  static int _calculateScore({
    required int wordCount,
    required double asrConfidence,
    required double fillerRatio,
    required double sentenceCompleteness,
  }) {
    if (wordCount == 0) return 0;

    final lengthScore = wordCount >= 40
        ? 1.0
        : wordCount >= 25
        ? 0.8
        : wordCount >= 10
        ? 0.55
        : 0.3;

    final fluencyScore = (1 - fillerRatio).clamp(0.0, 1.0);
    final aggregate =
        (lengthScore * 0.4) +
        (asrConfidence * 0.2) +
        (fluencyScore * 0.2) +
        (sentenceCompleteness * 0.2);

    if (aggregate >= 0.85) return 4;
    if (aggregate >= 0.65) return 3;
    if (aggregate >= 0.45) return 2;
    return 1;
  }

  static RubricScoreCard _buildRubricScore({
    required int wordCount,
    required double asrConfidence,
    required double fillerRatio,
    required double sentenceCompleteness,
  }) {
    final grammar = (sentenceCompleteness * 5).round().clamp(0, 5);
    final lexical = wordCount >= 40
        ? 5
        : wordCount >= 25
        ? 4
        : wordCount >= 12
        ? 3
        : 2;
    final coherence = (sentenceCompleteness * (1 - fillerRatio) * 5)
        .round()
        .clamp(0, 5);
    final task = wordCount >= 30 ? 4 : (wordCount >= 15 ? 3 : 2);
    final pronunciation = (asrConfidence * (1 - fillerRatio) * 5).round().clamp(
      0,
      5,
    );

    return RubricScoreCard(
      dimensions: [
        RubricDimensionScore(key: 'grammar_accuracy', score: grammar),
        RubricDimensionScore(key: 'lexical_range', score: lexical),
        RubricDimensionScore(key: 'coherence', score: coherence),
        RubricDimensionScore(key: 'task_achievement', score: task),
        RubricDimensionScore(key: 'pronunciation', score: pronunciation),
      ],
      weights: const {
        'grammar_accuracy': 0.25,
        'lexical_range': 0.2,
        'coherence': 0.2,
        'task_achievement': 0.2,
        'pronunciation': 0.15,
      },
    );
  }

  static String _generateFeedback(int score) {
    switch (score) {
      case 4:
        return 'Excellent! Clear, accurate, and well-structured response.';
      case 3:
        return 'Good response. Improve precision and detail for top score.';
      case 2:
        return 'Basic response. Focus on sentence quality and clarity.';
      case 1:
        return 'Short response. Build fuller answers with stronger structure.';
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
      asrConfidence: (json['asrConfidence'] as num?)?.toDouble() ?? 0.0,
      fillerRatio: (json['fillerRatio'] as num?)?.toDouble() ?? 0.0,
      sentenceCompleteness:
          (json['sentenceCompleteness'] as num?)?.toDouble() ?? 0.0,
      rubric: json['rubric'] == null
          ? null
          : RubricScoreCard.fromJson(json['rubric'] as Map<String, dynamic>),
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
      'asrConfidence': asrConfidence,
      'fillerRatio': fillerRatio,
      'sentenceCompleteness': sentenceCompleteness,
      'rubric': rubric.toJson(),
    };
  }

  @override
  String toString() {
    return 'Phase5SpeakingResult(taskId: $taskId, score: $score, rubric: $rubricScore100)';
  }
}

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
        json['question'] as Map<String, dynamic>,
      ),
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

  // Section percentages used for hard passing rule.
  final double listeningPercent;
  final double readingGrammarPercent;
  final double speakingPercent;
  final double writingPercent;

  static const int passingScore = 42; // 70% of 60
  static const int maxPossibleScore = 60;
  static const int totalTestQuestions = 35;
  static const int mcqCount = 27;
  static const int speakingCount = 8;
  static const int maxMcqScore = mcqCount;
  static const int maxSpeakingScore = maxPossibleScore - mcqCount;

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
    required this.listeningPercent,
    required this.readingGrammarPercent,
    required this.speakingPercent,
    required this.writingPercent,
  });

  factory Phase5TestResult.calculate({
    required int mcqCorrect,
    required int speakingScore,
    required DateTime completedAt,
    required List<Phase5IncorrectAnswer> incorrectMcqAnswers,
    required List<Phase5SpeakingResult> speakingResults,
    double listeningPercent = 70,
    double readingGrammarPercent = 70,
    double speakingPercent = 70,
    double writingPercent = 70,
  }) {
    final totalScore = mcqCorrect + speakingScore;
    final percentage = (totalScore / maxPossibleScore) * 100;

    final passed =
        totalScore >= passingScore &&
        listeningPercent >= 50 &&
        readingGrammarPercent >= 50 &&
        speakingPercent >= 60 &&
        writingPercent >= 60;

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
      listeningPercent: listeningPercent,
      readingGrammarPercent: readingGrammarPercent,
      speakingPercent: speakingPercent,
      writingPercent: writingPercent,
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
      incorrectMcqAnswers: (json['incorrectMcqAnswers'] as List<dynamic>)
          .map(
            (item) =>
                Phase5IncorrectAnswer.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      speakingResults: (json['speakingResults'] as List<dynamic>)
          .map(
            (item) =>
                Phase5SpeakingResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      listeningPercent: (json['listeningPercent'] as num?)?.toDouble() ?? 0,
      readingGrammarPercent:
          (json['readingGrammarPercent'] as num?)?.toDouble() ?? 0,
      speakingPercent: (json['speakingPercent'] as num?)?.toDouble() ?? 0,
      writingPercent: (json['writingPercent'] as num?)?.toDouble() ?? 0,
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
      'incorrectMcqAnswers': incorrectMcqAnswers
          .map((item) => item.toJson())
          .toList(),
      'speakingResults': speakingResults.map((item) => item.toJson()).toList(),
      'listeningPercent': listeningPercent,
      'readingGrammarPercent': readingGrammarPercent,
      'speakingPercent': speakingPercent,
      'writingPercent': writingPercent,
    };
  }

  @override
  String toString() {
    return 'Phase5TestResult(score: $totalScore/$maxScore, passed: $passed)';
  }
}
