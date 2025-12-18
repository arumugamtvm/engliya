import 'package:flutter_test/flutter_test.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Lesson Content Display Tests', () {
    late LessonRepository repository;

    setUp(() {
      repository = LessonRepository();
    });

    tearDown(() {
      repository.clearCache();
    });

    group('Unit 7 Lesson Content Validation', () {
      test('Lesson 7.1 has all required tabs content', () async {
        final lesson = await repository.loadLesson('phase2_lesson7_1');

        // Verify Explain tab content
        expect(lesson.explain, isNotNull);
        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.explain.ta, contains('காலத்தை'));
        expect(lesson.explain.en, contains('prepositions'));

        // Verify Examples tab content
        expect(lesson.examples, isNotEmpty);
        expect(lesson.examples.length, greaterThanOrEqualTo(3));
        for (final example in lesson.examples) {
          expect(example.en, isNotEmpty);
          expect(example.ta, isNotEmpty);
          expect(example.audioId, isNotEmpty);
        }

        // Verify Listen tab content
        expect(lesson.listeningQuestions, isNotEmpty);
        expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));
        for (final question in lesson.listeningQuestions) {
          expect(question.audioText, isNotEmpty);
          expect(question.options, hasLength(greaterThanOrEqualTo(2)));
          expect(question.correctIndex, greaterThanOrEqualTo(0));
          expect(question.correctIndex, lessThan(question.options.length));
        }

        // Verify Speak tab content
        expect(lesson.speakSentences, isNotEmpty);
        expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));
        for (final sentence in lesson.speakSentences) {
          expect(sentence.en, isNotEmpty);
          expect(sentence.ta, isNotEmpty);
        }

        // Verify Practice tab content
        expect(lesson.practiceQuestions, isNotEmpty);
        expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(3));
        for (final question in lesson.practiceQuestions) {
          expect(question.promptEn, isNotEmpty);
          expect(question.promptTa, isNotEmpty);
          expect(question.options, hasLength(greaterThanOrEqualTo(2)));
          expect(question.correctIndex, greaterThanOrEqualTo(0));
          expect(question.correctIndex, lessThan(question.options.length));
        }

        // Verify Mastery tab content
        expect(lesson.masteryQuestions, isNotEmpty);
        expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(3));
        for (final question in lesson.masteryQuestions) {
          expect(question.promptEn, isNotEmpty);
          expect(question.promptTa, isNotEmpty);
          expect(question.options, hasLength(greaterThanOrEqualTo(2)));
          expect(question.correctIndex, greaterThanOrEqualTo(0));
          expect(question.correctIndex, lessThan(question.options.length));
        }
      });

      test('Lesson 7.2 has all required tabs content', () async {
        final lesson = await repository.loadLesson('phase2_lesson7_2');

        // Verify all tabs have content
        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.examples.length, greaterThanOrEqualTo(3));
        expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));
        expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));
        expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(3));
        expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(3));
      });

      test('Lesson 7.3 has all required tabs content', () async {
        final lesson = await repository.loadLesson('phase2_lesson7_3');

        // Verify all tabs have content
        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.examples.length, greaterThanOrEqualTo(3));
        expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));
        expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));
        expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(3));
        expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(3));
      });
    });

    group('Unit 8 Lesson Content Validation', () {
      test('Lesson 8.1 has all required tabs content', () async {
        final lesson = await repository.loadLesson('phase2_lesson8_1');

        // Verify Explain tab content
        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.explain.en.toLowerCase(), contains('continuous'));

        // Verify Examples tab content (Unit 8 requires 5+ examples)
        expect(lesson.examples.length, greaterThanOrEqualTo(5));
        for (final example in lesson.examples) {
          expect(example.en, isNotEmpty);
          expect(example.ta, isNotEmpty);
          expect(example.audioId, isNotEmpty);
        }

        // Verify Listen tab content
        expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));

        // Verify Speak tab content
        expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));

        // Verify Practice tab content (Unit 8 requires 5+ questions)
        expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(5));

        // Verify Mastery tab content (Unit 8 requires 5+ questions)
        expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(5));
      });

      test('Lesson 8.2 has all required tabs content', () async {
        final lesson = await repository.loadLesson('phase2_lesson8_2');

        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.examples.length, greaterThanOrEqualTo(5));
        expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));
        expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));
        expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(5));
        expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(5));
      });

      test('Lesson 8.3 has all required tabs content', () async {
        final lesson = await repository.loadLesson('phase2_lesson8_3');

        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.examples.length, greaterThanOrEqualTo(5));
        expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));
        expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));
        expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(5));
        expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(5));
      });

      test('Lesson 8.4 has all required tabs content', () async {
        final lesson = await repository.loadLesson('phase2_lesson8_4');

        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.examples.length, greaterThanOrEqualTo(5));
        expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));
        expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));
        expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(5));
        expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(5));
      });
    });

    group('Tamil and English Text Display', () {
      test('All Unit 7 lessons have proper Tamil translations', () async {
        final lessonIds = [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson7_3',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          // Check Tamil explanation contains Tamil script
          expect(lesson.explain.ta, matches(RegExp(r'[\u0B80-\u0BFF]')));

          // Check all examples have Tamil translations
          for (final example in lesson.examples) {
            expect(example.ta, isNotEmpty);
            expect(example.ta, matches(RegExp(r'[\u0B80-\u0BFF]')));
          }

          // Check all practice questions have Tamil prompts
          for (final question in lesson.practiceQuestions) {
            expect(question.promptTa, isNotEmpty);
            expect(question.promptTa, matches(RegExp(r'[\u0B80-\u0BFF]')));
          }

          // Check all mastery questions have Tamil prompts
          for (final question in lesson.masteryQuestions) {
            expect(question.promptTa, isNotEmpty);
            expect(question.promptTa, matches(RegExp(r'[\u0B80-\u0BFF]')));
          }
        }
      });

      test('All Unit 8 lessons have proper Tamil translations', () async {
        final lessonIds = [
          'phase2_lesson8_1',
          'phase2_lesson8_2',
          'phase2_lesson8_3',
          'phase2_lesson8_4',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          // Check Tamil explanation contains Tamil script
          expect(lesson.explain.ta, matches(RegExp(r'[\u0B80-\u0BFF]')));

          // Check all examples have Tamil translations
          for (final example in lesson.examples) {
            expect(example.ta, isNotEmpty);
            expect(example.ta, matches(RegExp(r'[\u0B80-\u0BFF]')));
          }

          // Check all practice questions have Tamil prompts
          for (final question in lesson.practiceQuestions) {
            expect(question.promptTa, isNotEmpty);
            expect(question.promptTa, matches(RegExp(r'[\u0B80-\u0BFF]')));
          }
        }
      });

      test('All lessons have proper English text', () async {
        final lessonIds = [
          'phase2_lesson7_1',
          'phase2_lesson8_1',
          'phase2_lesson9_1',
          'phase2_lesson10_1',
          'phase2_lesson11_1',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          // Check English explanation is in English
          expect(lesson.explain.en, isNotEmpty);
          expect(lesson.explain.en, matches(RegExp(r'[a-zA-Z]')));

          // Check all examples have English text
          for (final example in lesson.examples) {
            expect(example.en, isNotEmpty);
            expect(example.en, matches(RegExp(r'[a-zA-Z]')));
          }

          // Check all practice questions have English prompts
          for (final question in lesson.practiceQuestions) {
            expect(question.promptEn, isNotEmpty);
            expect(question.promptEn, matches(RegExp(r'[a-zA-Z]')));
          }
        }
      });
    });

    group('TTS Audio IDs for Phase 2', () {
      test('All Unit 7 examples have unique audio IDs', () async {
        final lesson7_1 = await repository.loadLesson('phase2_lesson7_1');
        final lesson7_2 = await repository.loadLesson('phase2_lesson7_2');
        final lesson7_3 = await repository.loadLesson('phase2_lesson7_3');

        final allAudioIds = <String>{};

        // Collect all audio IDs from Unit 7
        for (final lesson in [lesson7_1, lesson7_2, lesson7_3]) {
          for (final example in lesson.examples) {
            expect(example.audioId, isNotEmpty);
            expect(example.audioId, startsWith('phase2_'));
            allAudioIds.add(example.audioId);
          }
        }

        // Verify all audio IDs are unique
        final totalExamples = lesson7_1.examples.length +
            lesson7_2.examples.length +
            lesson7_3.examples.length;
        expect(allAudioIds.length, totalExamples);
      });

      test('All Unit 8 examples have unique audio IDs', () async {
        final lesson8_1 = await repository.loadLesson('phase2_lesson8_1');
        final lesson8_2 = await repository.loadLesson('phase2_lesson8_2');
        final lesson8_3 = await repository.loadLesson('phase2_lesson8_3');
        final lesson8_4 = await repository.loadLesson('phase2_lesson8_4');

        final allAudioIds = <String>{};

        // Collect all audio IDs from Unit 8
        for (final lesson in [lesson8_1, lesson8_2, lesson8_3, lesson8_4]) {
          for (final example in lesson.examples) {
            expect(example.audioId, isNotEmpty);
            expect(example.audioId, startsWith('phase2_'));
            allAudioIds.add(example.audioId);
          }
        }

        // Verify all audio IDs are unique
        final totalExamples = lesson8_1.examples.length +
            lesson8_2.examples.length +
            lesson8_3.examples.length +
            lesson8_4.examples.length;
        expect(allAudioIds.length, totalExamples);
      });

      test('Listening questions have audio text for TTS', () async {
        final lesson = await repository.loadLesson('phase2_lesson7_1');

        for (final question in lesson.listeningQuestions) {
          expect(question.audioText, isNotEmpty);
          expect(question.audioText, matches(RegExp(r'[a-zA-Z]')));
        }
      });
    });

    group('Quiz and Mastery Scoring Validation', () {
      test('Practice questions have valid correct answers', () async {
        final lessonIds = [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson7_3',
          'phase2_lesson8_1',
          'phase2_lesson8_2',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          for (final question in lesson.practiceQuestions) {
            // Verify correct index is within bounds
            expect(question.correctIndex, greaterThanOrEqualTo(0));
            expect(question.correctIndex, lessThan(question.options.length));

            // Verify all options are non-empty
            for (final option in question.options) {
              expect(option, isNotEmpty);
            }

            // Verify options are unique
            final uniqueOptions = question.options.toSet();
            expect(uniqueOptions.length, question.options.length);
          }
        }
      });

      test('Mastery questions have valid correct answers', () async {
        final lessonIds = [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson7_3',
          'phase2_lesson8_1',
          'phase2_lesson8_2',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          for (final question in lesson.masteryQuestions) {
            // Verify correct index is within bounds
            expect(question.correctIndex, greaterThanOrEqualTo(0));
            expect(question.correctIndex, lessThan(question.options.length));

            // Verify all options are non-empty
            for (final option in question.options) {
              expect(option, isNotEmpty);
            }

            // Verify options are unique
            final uniqueOptions = question.options.toSet();
            expect(uniqueOptions.length, question.options.length);
          }
        }
      });

      test('Practice questions have 4 options each', () async {
        final lesson = await repository.loadLesson('phase2_lesson7_1');

        for (final question in lesson.practiceQuestions) {
          expect(question.options.length, 4);
        }
      });

      test('Mastery questions have 4 options each', () async {
        final lesson = await repository.loadLesson('phase2_lesson8_1');

        for (final question in lesson.masteryQuestions) {
          expect(question.options.length, 4);
        }
      });

      test('Listening questions have valid multiple choice options', () async {
        final lesson = await repository.loadLesson('phase2_lesson7_1');

        for (final question in lesson.listeningQuestions) {
          // Verify correct index is within bounds
          expect(question.correctIndex, greaterThanOrEqualTo(0));
          expect(question.correctIndex, lessThan(question.options.length));

          // Verify all options are non-empty
          for (final option in question.options) {
            expect(option, isNotEmpty);
          }

          // Verify at least 2 options
          expect(question.options.length, greaterThanOrEqualTo(2));
        }
      });
    });

    group('Content Completeness Requirements', () {
      test('Unit 7 lessons meet content requirements (Req 13.1-13.6)', () async {
        final lessonIds = [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson7_3',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          // Req 13.1: At least 1 Tamil and 1 English explanation
          expect(lesson.explain.ta, isNotEmpty);
          expect(lesson.explain.en, isNotEmpty);

          // Req 13.2: At least 3 example sentences with Tamil translations
          expect(lesson.examples.length, greaterThanOrEqualTo(3));
          for (final example in lesson.examples) {
            expect(example.en, isNotEmpty);
            expect(example.ta, isNotEmpty);
          }

          // Req 13.3: At least 2 listening questions
          expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));

          // Req 13.4: At least 3 speak sentences
          expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));

          // Req 13.5: At least 3 practice questions
          expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(3));

          // Req 13.6: At least 3 mastery questions
          expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(3));
        }
      });

      test('Unit 8 lessons meet content requirements (Req 13.7-13.12)', () async {
        final lessonIds = [
          'phase2_lesson8_1',
          'phase2_lesson8_2',
          'phase2_lesson8_3',
          'phase2_lesson8_4',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          // Req 13.7: At least 1 Tamil and 1 English explanation
          expect(lesson.explain.ta, isNotEmpty);
          expect(lesson.explain.en, isNotEmpty);

          // Req 13.8: At least 5 example sentences with Tamil translations
          expect(lesson.examples.length, greaterThanOrEqualTo(5));
          for (final example in lesson.examples) {
            expect(example.en, isNotEmpty);
            expect(example.ta, isNotEmpty);
          }

          // Req 13.9: At least 2 listening questions
          expect(lesson.listeningQuestions.length, greaterThanOrEqualTo(2));

          // Req 13.10: At least 3 speak sentences
          expect(lesson.speakSentences.length, greaterThanOrEqualTo(3));

          // Req 13.11: At least 5 practice questions
          expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(5));

          // Req 13.12: At least 5 mastery questions
          expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(5));
        }
      });

      test('Units 9, 10, 11 lessons meet lighter content requirements (Req 14.1-14.4)', () async {
        final lessonIds = [
          'phase2_lesson9_1',
          'phase2_lesson10_1',
          'phase2_lesson11_1',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          // Req 14.1: At least 1 explanation in Tamil and English
          expect(lesson.explain.ta, isNotEmpty);
          expect(lesson.explain.en, isNotEmpty);

          // Req 14.2: At least 2 example sentences with Tamil translations
          expect(lesson.examples.length, greaterThanOrEqualTo(2));
          for (final example in lesson.examples) {
            expect(example.en, isNotEmpty);
            expect(example.ta, isNotEmpty);
          }

          // Req 14.3: At least 2 practice questions
          expect(lesson.practiceQuestions.length, greaterThanOrEqualTo(2));

          // Req 14.4: At least 2 mastery questions
          expect(lesson.masteryQuestions.length, greaterThanOrEqualTo(2));
        }
      });
    });

    group('Lesson Structure Consistency (Req 6.1-6.5, 17.1-17.5)', () {
      test('Phase 2 lessons use same structure as Phase 1', () async {
        final phase1Lesson = await repository.loadLesson('phase1_lesson1');
        final phase2Lesson = await repository.loadLesson('phase2_lesson7_1');

        // Both should have the same structure
        expect(phase2Lesson.id, isNotEmpty);
        expect(phase2Lesson.unitId, isNotEmpty);
        expect(phase2Lesson.title, isNotEmpty);
        expect(phase2Lesson.description, isNotEmpty);
        expect(phase2Lesson.level, isNotEmpty);
        expect(phase2Lesson.explain, isNotNull);
        expect(phase2Lesson.examples, isNotEmpty);
        expect(phase2Lesson.listeningQuestions, isNotEmpty);
        expect(phase2Lesson.speakSentences, isNotEmpty);
        expect(phase2Lesson.practiceQuestions, isNotEmpty);
        expect(phase2Lesson.masteryQuestions, isNotEmpty);

        // Same fields as Phase 1
        expect(phase2Lesson.runtimeType, phase1Lesson.runtimeType);
      });

      test('All Phase 2 lessons have consistent field structure', () async {
        final lessonIds = [
          'phase2_lesson7_1',
          'phase2_lesson8_1',
          'phase2_lesson9_1',
          'phase2_lesson10_1',
          'phase2_lesson11_1',
        ];

        for (final lessonId in lessonIds) {
          final lesson = await repository.loadLesson(lessonId);

          // Verify all required fields exist
          expect(lesson.id, isNotEmpty);
          expect(lesson.unitId, isNotEmpty);
          expect(lesson.title, isNotEmpty);
          expect(lesson.description, isNotEmpty);
          expect(lesson.level, isNotEmpty);
          expect(lesson.order, greaterThan(0));
          expect(lesson.explain, isNotNull);
          expect(lesson.examples, isNotEmpty);
          expect(lesson.practiceQuestions, isNotEmpty);
          expect(lesson.masteryQuestions, isNotEmpty);
        }
      });
    });
  });
}
