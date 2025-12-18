import 'package:flutter_test/flutter_test.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Repository Extensions', () {
    late LessonRepository repository;

    setUp(() {
      repository = LessonRepository();
    });

    tearDown(() {
      repository.clearCache();
    });

    group('Load All 25 Phase 2 Lessons', () {
      test('Loads all Unit 7 lessons correctly', () async {
        final lesson7_1 = await repository.loadLesson('phase2_lesson7_1');
        final lesson7_2 = await repository.loadLesson('phase2_lesson7_2');
        final lesson7_3 = await repository.loadLesson('phase2_lesson7_3');

        expect(lesson7_1.id, 'phase2_lesson7_1');
        expect(lesson7_1.unitId, 'phase2_unit7');
        expect(lesson7_1.title, 'Time Prepositions');

        expect(lesson7_2.id, 'phase2_lesson7_2');
        expect(lesson7_2.unitId, 'phase2_unit7');
        expect(lesson7_2.title, 'Place & Movement Prepositions');

        expect(lesson7_3.id, 'phase2_lesson7_3');
        expect(lesson7_3.unitId, 'phase2_unit7');
        expect(lesson7_3.title, 'Daily Time Expressions');
      });

      test('Loads all Unit 8 lessons correctly', () async {
        final lesson8_1 = await repository.loadLesson('phase2_lesson8_1');
        final lesson8_2 = await repository.loadLesson('phase2_lesson8_2');
        final lesson8_3 = await repository.loadLesson('phase2_lesson8_3');
        final lesson8_4 = await repository.loadLesson('phase2_lesson8_4');

        expect(lesson8_1.id, 'phase2_lesson8_1');
        expect(lesson8_1.unitId, 'phase2_unit8');
        expect(lesson8_1.title, 'Present Continuous');

        expect(lesson8_2.id, 'phase2_lesson8_2');
        expect(lesson8_2.unitId, 'phase2_unit8');
        expect(lesson8_2.title, 'Past Continuous');

        expect(lesson8_3.id, 'phase2_lesson8_3');
        expect(lesson8_3.unitId, 'phase2_unit8');
        expect(lesson8_3.title, 'Future Continuous');

        expect(lesson8_4.id, 'phase2_lesson8_4');
        expect(lesson8_4.unitId, 'phase2_unit8');
        expect(lesson8_4.title, 'Continuous Tenses in Conversation');
      });

      test('Loads all Unit 9 lessons correctly', () async {
        final lesson9_1 = await repository.loadLesson('phase2_lesson9_1');
        final lesson9_2 = await repository.loadLesson('phase2_lesson9_2');
        final lesson9_3 = await repository.loadLesson('phase2_lesson9_3');
        final lesson9_4 = await repository.loadLesson('phase2_lesson9_4');
        final lesson9_5 = await repository.loadLesson('phase2_lesson9_5');

        expect(lesson9_1.id, 'phase2_lesson9_1');
        expect(lesson9_1.unitId, 'phase2_unit9');
        expect(lesson9_1.title, 'Present Perfect');

        expect(lesson9_2.id, 'phase2_lesson9_2');
        expect(lesson9_2.unitId, 'phase2_unit9');
        expect(lesson9_2.title, 'Past Perfect');

        expect(lesson9_3.id, 'phase2_lesson9_3');
        expect(lesson9_3.unitId, 'phase2_unit9');
        expect(lesson9_3.title, 'Future Perfect');

        expect(lesson9_4.id, 'phase2_lesson9_4');
        expect(lesson9_4.unitId, 'phase2_unit9');
        expect(lesson9_4.title, 'Present Perfect Continuous');

        expect(lesson9_5.id, 'phase2_lesson9_5');
        expect(lesson9_5.unitId, 'phase2_unit9');
        expect(lesson9_5.title, 'Perfect vs Simple Past');
      });

      test('Loads all Unit 10 lessons correctly', () async {
        final lesson10_1 = await repository.loadLesson('phase2_lesson10_1');
        final lesson10_2 = await repository.loadLesson('phase2_lesson10_2');
        final lesson10_3 = await repository.loadLesson('phase2_lesson10_3');
        final lesson10_4 = await repository.loadLesson('phase2_lesson10_4');
        final lesson10_5 = await repository.loadLesson('phase2_lesson10_5');

        expect(lesson10_1.id, 'phase2_lesson10_1');
        expect(lesson10_1.unitId, 'phase2_unit10');
        expect(lesson10_1.title, 'Be-Verb Questions');

        expect(lesson10_2.id, 'phase2_lesson10_2');
        expect(lesson10_2.unitId, 'phase2_unit10');
        expect(lesson10_2.title, 'Do/Does/Did Questions');

        expect(lesson10_3.id, 'phase2_lesson10_3');
        expect(lesson10_3.unitId, 'phase2_unit10');
        expect(lesson10_3.title, 'WH-Questions');

        expect(lesson10_4.id, 'phase2_lesson10_4');
        expect(lesson10_4.unitId, 'phase2_unit10');
        expect(lesson10_4.title, 'Negatives');

        expect(lesson10_5.id, 'phase2_lesson10_5');
        expect(lesson10_5.unitId, 'phase2_unit10');
        expect(lesson10_5.title, 'Real Q&A Practice');
      });

      test('Loads all Unit 11 lessons correctly', () async {
        final lesson11_1 = await repository.loadLesson('phase2_lesson11_1');
        final lesson11_2 = await repository.loadLesson('phase2_lesson11_2');
        final lesson11_3 = await repository.loadLesson('phase2_lesson11_3');
        final lesson11_4 = await repository.loadLesson('phase2_lesson11_4');
        final lesson11_5 = await repository.loadLesson('phase2_lesson11_5');

        expect(lesson11_1.id, 'phase2_lesson11_1');
        expect(lesson11_1.unitId, 'phase2_unit11');
        expect(lesson11_1.title, 'Possessive Pronouns & Adjectives');

        expect(lesson11_2.id, 'phase2_lesson11_2');
        expect(lesson11_2.unitId, 'phase2_unit11');
        expect(lesson11_2.title, 'Reflexive Pronouns');

        expect(lesson11_3.id, 'phase2_lesson11_3');
        expect(lesson11_3.unitId, 'phase2_unit11');
        expect(lesson11_3.title, 'Demonstrative Pronouns');

        expect(lesson11_4.id, 'phase2_lesson11_4');
        expect(lesson11_4.unitId, 'phase2_unit11');
        expect(lesson11_4.title, 'Common Adjectives');

        expect(lesson11_5.id, 'phase2_lesson11_5');
        expect(lesson11_5.unitId, 'phase2_unit11');
        expect(lesson11_5.title, 'Common Adverbs');
      });
    });

    group('Asset Path Mapping', () {
      test('Maps all Phase 2 lesson IDs to correct file paths', () async {
        // Test a sample from each unit to verify path mapping
        final testCases = {
          'phase2_lesson7_1': 'lesson7_1_time_prepositions.json',
          'phase2_lesson8_2': 'lesson8_2_past_continuous.json',
          'phase2_lesson9_3': 'lesson9_3_future_perfect.json',
          'phase2_lesson10_4': 'lesson10_4_negatives.json',
          'phase2_lesson11_5': 'lesson11_5_adverbs.json',
        };

        for (final entry in testCases.entries) {
          final lesson = await repository.loadLesson(entry.key);
          expect(lesson, isNotNull);
          expect(lesson.id, entry.key);
        }
      });

      test('Throws exception for invalid Phase 2 lesson ID', () async {
        expect(
          () => repository.loadLesson('phase2_lesson99_1'),
          throwsA(isA<LessonLoadException>()),
        );
      });

      test('Throws exception for malformed Phase 2 lesson ID', () async {
        expect(
          () => repository.loadLesson('phase2_invalid'),
          throwsA(isA<LessonLoadException>()),
        );
      });
    });

    group('loadUnitLessons for Phase 2 Units', () {
      test('Loads Unit 7 lessons with correct count and order', () async {
        final lessons = await repository.loadUnitLessons('phase2_unit7');

        expect(lessons.length, 3);
        expect(lessons[0].id, 'phase2_lesson7_1');
        expect(lessons[1].id, 'phase2_lesson7_2');
        expect(lessons[2].id, 'phase2_lesson7_3');
        
        // Verify lessons are sorted by order
        expect(lessons[0].order, lessThan(lessons[1].order));
        expect(lessons[1].order, lessThan(lessons[2].order));
      });

      test('Loads Unit 8 lessons with correct count and order', () async {
        final lessons = await repository.loadUnitLessons('phase2_unit8');

        expect(lessons.length, 4);
        expect(lessons[0].id, 'phase2_lesson8_1');
        expect(lessons[1].id, 'phase2_lesson8_2');
        expect(lessons[2].id, 'phase2_lesson8_3');
        expect(lessons[3].id, 'phase2_lesson8_4');
        
        // Verify lessons are sorted by order
        for (int i = 0; i < lessons.length - 1; i++) {
          expect(lessons[i].order, lessThan(lessons[i + 1].order));
        }
      });

      test('Loads Unit 9 lessons with correct count and order', () async {
        final lessons = await repository.loadUnitLessons('phase2_unit9');

        expect(lessons.length, 5);
        expect(lessons[0].id, 'phase2_lesson9_1');
        expect(lessons[1].id, 'phase2_lesson9_2');
        expect(lessons[2].id, 'phase2_lesson9_3');
        expect(lessons[3].id, 'phase2_lesson9_4');
        expect(lessons[4].id, 'phase2_lesson9_5');
        
        // Verify lessons are sorted by order
        for (int i = 0; i < lessons.length - 1; i++) {
          expect(lessons[i].order, lessThan(lessons[i + 1].order));
        }
      });

      test('Loads Unit 10 lessons with correct count and order', () async {
        final lessons = await repository.loadUnitLessons('phase2_unit10');

        expect(lessons.length, 5);
        expect(lessons[0].id, 'phase2_lesson10_1');
        expect(lessons[1].id, 'phase2_lesson10_2');
        expect(lessons[2].id, 'phase2_lesson10_3');
        expect(lessons[3].id, 'phase2_lesson10_4');
        expect(lessons[4].id, 'phase2_lesson10_5');
        
        // Verify lessons are sorted by order
        for (int i = 0; i < lessons.length - 1; i++) {
          expect(lessons[i].order, lessThan(lessons[i + 1].order));
        }
      });

      test('Loads Unit 11 lessons with correct count and order', () async {
        final lessons = await repository.loadUnitLessons('phase2_unit11');

        expect(lessons.length, 5);
        expect(lessons[0].id, 'phase2_lesson11_1');
        expect(lessons[1].id, 'phase2_lesson11_2');
        expect(lessons[2].id, 'phase2_lesson11_3');
        expect(lessons[3].id, 'phase2_lesson11_4');
        expect(lessons[4].id, 'phase2_lesson11_5');
        
        // Verify lessons are sorted by order
        for (int i = 0; i < lessons.length - 1; i++) {
          expect(lessons[i].order, lessThan(lessons[i + 1].order));
        }
      });

      test('Throws exception for unknown Phase 2 unit', () async {
        expect(
          () => repository.loadUnitLessons('phase2_unit99'),
          throwsA(isA<LessonLoadException>()),
        );
      });
    });

    group('Error Handling for Missing Assets', () {
      test('Throws LessonLoadException for non-existent Phase 2 lesson', () async {
        expect(
          () => repository.loadLesson('phase2_lesson7_99'),
          throwsA(isA<LessonLoadException>()),
        );
      });

      test('LessonLoadException contains helpful error message', () async {
        try {
          await repository.loadLesson('phase2_lesson7_99');
          fail('Should have thrown LessonLoadException');
        } catch (e) {
          expect(e, isA<LessonLoadException>());
          expect(e.toString(), contains('phase2_lesson7_99'));
        }
      });

      test('Handles invalid unit ID gracefully', () async {
        expect(
          () => repository.loadUnitLessons('invalid_unit'),
          throwsA(isA<LessonLoadException>()),
        );
      });
    });

    group('Lesson Caching for Phase 2', () {
      test('Caches Phase 2 lessons after first load', () async {
        expect(repository.isCached('phase2_lesson7_1'), false);

        await repository.loadLesson('phase2_lesson7_1');

        expect(repository.isCached('phase2_lesson7_1'), true);
      });

      test('Returns cached Phase 2 lesson on subsequent loads', () async {
        final lesson1 = await repository.loadLesson('phase2_lesson8_1');
        final lesson2 = await repository.loadLesson('phase2_lesson8_1');

        // Should be the same instance from cache
        expect(identical(lesson1, lesson2), true);
      });

      test('Caches multiple Phase 2 lessons independently', () async {
        await repository.loadLesson('phase2_lesson7_1');
        await repository.loadLesson('phase2_lesson8_1');
        await repository.loadLesson('phase2_lesson9_1');

        expect(repository.cachedLessonCount, greaterThanOrEqualTo(3));
        expect(repository.isCached('phase2_lesson7_1'), true);
        expect(repository.isCached('phase2_lesson8_1'), true);
        expect(repository.isCached('phase2_lesson9_1'), true);
      });

      test('clearCache removes all Phase 2 cached lessons', () async {
        await repository.loadLesson('phase2_lesson7_1');
        await repository.loadLesson('phase2_lesson8_1');

        expect(repository.cachedLessonCount, greaterThan(0));

        repository.clearCache();

        expect(repository.cachedLessonCount, 0);
        expect(repository.isCached('phase2_lesson7_1'), false);
        expect(repository.isCached('phase2_lesson8_1'), false);
      });

      test('Caches lessons loaded via loadUnitLessons', () async {
        await repository.loadUnitLessons('phase2_unit7');

        expect(repository.isCached('phase2_lesson7_1'), true);
        expect(repository.isCached('phase2_lesson7_2'), true);
        expect(repository.isCached('phase2_lesson7_3'), true);
      });

      test('Cache works across Phase 1 and Phase 2 lessons', () async {
        await repository.loadLesson('phase1_lesson1');
        await repository.loadLesson('phase2_lesson7_1');

        expect(repository.isCached('phase1_lesson1'), true);
        expect(repository.isCached('phase2_lesson7_1'), true);
        expect(repository.cachedLessonCount, greaterThanOrEqualTo(2));
      });
    });

    group('Phase 2 Lesson Content Validation', () {
      test('Phase 2 lessons have required fields', () async {
        final lesson = await repository.loadLesson('phase2_lesson7_1');

        expect(lesson.id, isNotEmpty);
        expect(lesson.unitId, isNotEmpty);
        expect(lesson.title, isNotEmpty);
        expect(lesson.description, isNotEmpty);
        expect(lesson.level, isNotEmpty);
        expect(lesson.explain, isNotNull);
        expect(lesson.examples, isNotEmpty);
      });

      test('Phase 2 lessons have Tamil and English explanations', () async {
        final lesson = await repository.loadLesson('phase2_lesson8_1');

        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
      });

      test('Phase 2 lessons have practice and mastery questions', () async {
        final lesson = await repository.loadLesson('phase2_lesson9_1');

        expect(lesson.practiceQuestions, isNotEmpty);
        expect(lesson.masteryQuestions, isNotEmpty);
      });
    });
  });
}
