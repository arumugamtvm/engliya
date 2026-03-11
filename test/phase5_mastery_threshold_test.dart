import 'package:engliya/features/learn/data/models/phase5_test_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'strong objective score still fails when speaking/writing floor is weak',
    () {
      final result = Phase5TestResult.calculate(
        mcqCorrect: 24,
        speakingScore: 20,
        completedAt: DateTime.now(),
        incorrectMcqAnswers: [],
        speakingResults: [],
        listeningPercent: 85,
        readingGrammarPercent: 80,
        speakingPercent: 55,
        writingPercent: 58,
      );

      expect(result.totalScore, 44);
      expect(
        result.passed,
        isFalse,
        reason: 'Must fail when speaking/writing section minimum is not met',
      );
    },
  );
}
