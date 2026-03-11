import 'package:flutter_test/flutter_test.dart';
import 'package:engliya/features/learn/services/lesson_flow_validation_service.dart';

void main() {
  group('LessonFlowValidationService', () {
    final service = LessonFlowValidationService();

    test('Explain is invalid until scrolled/completed', () {
      final invalid = service.validateExplain(
        explainDone: false,
        snapshot: const TabProgressSnapshot(explainScrolledToBottom: false),
      );
      expect(invalid.isValid, isFalse);

      final valid = service.validateExplain(
        explainDone: true,
        snapshot: const TabProgressSnapshot(),
      );
      expect(valid.isValid, isTrue);
    });

    test('Examples requires at least 3 played', () {
      final invalid = service.validateExamples(
        examplesDone: false,
        snapshot: const TabProgressSnapshot(playedCount: 2),
      );
      expect(invalid.isValid, isFalse);

      final valid = service.validateExamples(
        examplesDone: false,
        snapshot: const TabProgressSnapshot(playedCount: 3),
      );
      expect(valid.isValid, isTrue);
    });

    test('Listen requires 3 answers with 70%+', () {
      final invalidLowCount = service.validateListen(
        listeningScore: 0,
        snapshot: const TabProgressSnapshot(answeredCount: 2, accuracy: 1.0),
      );
      expect(invalidLowCount.isValid, isFalse);

      final invalidLowAccuracy = service.validateListen(
        listeningScore: 0,
        snapshot: const TabProgressSnapshot(answeredCount: 3, accuracy: 0.6),
      );
      expect(invalidLowAccuracy.isValid, isFalse);

      final valid = service.validateListen(
        listeningScore: 0,
        snapshot: const TabProgressSnapshot(answeredCount: 3, accuracy: 0.7),
      );
      expect(valid.isValid, isTrue);
    });

    test('Practice and Mastery thresholds are enforced', () {
      final practiceInvalid = service.validatePractice(
        quizBestScore: 0,
        snapshot: const TabProgressSnapshot(answeredCount: 4, totalCount: 4, accuracy: 0.5),
      );
      expect(practiceInvalid.isValid, isFalse);

      final practiceValid = service.validatePractice(
        quizBestScore: 0,
        snapshot: const TabProgressSnapshot(answeredCount: 4, totalCount: 4, accuracy: 0.6),
      );
      expect(practiceValid.isValid, isTrue);

      final masteryInvalid = service.validateMastery(
        isMastered: false,
        masteryBestScore: 0,
        snapshot: const TabProgressSnapshot(answeredCount: 5, totalCount: 5, accuracy: 0.79),
      );
      expect(masteryInvalid.isValid, isFalse);

      final masteryValid = service.validateMastery(
        isMastered: false,
        masteryBestScore: 0,
        snapshot: const TabProgressSnapshot(answeredCount: 5, totalCount: 5, accuracy: 0.8),
      );
      expect(masteryValid.isValid, isTrue);
    });
  });
}
