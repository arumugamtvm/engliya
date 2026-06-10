import 'package:engliya/features/learn/data/models/user_lesson_status.dart';
import 'package:engliya/features/learn/services/mastery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MasteryService.lessonOrderFromId', () {
    test('parses phase1 format (phaseN_lessonM)', () {
      expect(MasteryService.lessonOrderFromId('phase1_lesson1'), 1);
      expect(MasteryService.lessonOrderFromId('phase1_lesson6'), 6);
    });

    test('parses sub-lesson format (phaseN_lessonM_K) using K as order', () {
      expect(MasteryService.lessonOrderFromId('phase2_lesson7_1'), 1);
      expect(MasteryService.lessonOrderFromId('phase2_lesson7_3'), 3);
      expect(MasteryService.lessonOrderFromId('phase5_lesson25_4'), 4);
    });

    test('returns null for unrecognized formats', () {
      expect(MasteryService.lessonOrderFromId('lesson1_pronouns'), isNull);
      expect(MasteryService.lessonOrderFromId('not_a_lesson'), isNull);
    });
  });

  group('MasteryService.shouldUnlockLesson', () {
    final service = MasteryService();

    test('first lesson is always unlocked', () {
      expect(service.shouldUnlockLesson(1, []), isTrue);
    });

    test('phase 1 behavior: unlocks when previous lesson is mastered', () {
      final statuses = [
        UserLessonStatus(lessonId: 'phase1_lesson1', isMastered: true),
        UserLessonStatus(lessonId: 'phase1_lesson2', isMastered: false),
      ];
      expect(service.shouldUnlockLesson(2, statuses), isTrue);
      expect(service.shouldUnlockLesson(3, statuses), isFalse);
    });

    test('phase 1 behavior: locked when previous lesson is not mastered', () {
      final statuses = [
        UserLessonStatus(lessonId: 'phase1_lesson1', isMastered: false),
      ];
      expect(service.shouldUnlockLesson(2, statuses), isFalse);
    });

    test('locked when previous lesson status is missing', () {
      expect(service.shouldUnlockLesson(2, []), isFalse);
    });

    test('handles phaseN_lessonM_K ids using sub-lesson number as order', () {
      final statuses = [
        UserLessonStatus(lessonId: 'phase2_lesson7_1', isMastered: true),
        UserLessonStatus(lessonId: 'phase2_lesson7_2', isMastered: false),
      ];
      // Lesson order 2 within the unit unlocks because order 1 is mastered.
      expect(service.shouldUnlockLesson(2, statuses), isTrue);
      // Lesson order 3 stays locked because order 2 is not mastered.
      expect(service.shouldUnlockLesson(3, statuses), isFalse);
    });

    test('explicit previousLessonId match takes precedence over parsing', () {
      final statuses = [
        UserLessonStatus(lessonId: 'phase2_lesson7_3', isMastered: true),
        UserLessonStatus(lessonId: 'phase2_lesson8_1', isMastered: false),
      ];
      expect(
        service.shouldUnlockLesson(
          4,
          statuses,
          previousLessonId: 'phase2_lesson7_3',
        ),
        isTrue,
      );
      expect(
        service.shouldUnlockLesson(
          2,
          statuses,
          previousLessonId: 'phase2_lesson8_1',
        ),
        isFalse,
      );
      // Unknown previous lesson id keeps the lesson locked.
      expect(
        service.shouldUnlockLesson(
          2,
          statuses,
          previousLessonId: 'phase2_lesson9_9',
        ),
        isFalse,
      );
    });
  });
}
