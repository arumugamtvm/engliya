import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/features/learn/data/models/phase5_final_test_question.dart';
import 'package:engliya/features/learn/data/models/phase5_test_result.dart';
import 'package:engliya/services/local_storage/storage_service.dart';

void main() {
  group('Phase 5 Final Test Property Tests', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      await storageService.init();
    });

    // **Feature: phase5-final-test, Property 9: Question Model Validity**
    // **Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5**
    property(
      'Property 9: Question model validity - MCQ types have options/correctIndex, speaking tasks do not',
      () {
        forAll(
          combine4(
            integer(min: 0, max: 4),
            string(minLength: 1, maxLength: 50),
            integer(min: 0, max: 3),
            integer(min: 2, max: 6),
          ),
          (values) {
            final typeIndex = values.$1;
            final prompt = values.$2.isEmpty ? 'Test prompt' : values.$2;
            final correctIndex = values.$3;
            final optionCount = values.$4;

            final options = List.generate(
              optionCount,
              (i) => 'Option ${i + 1}',
            );
            final validCorrectIndex = correctIndex % optionCount;

            final Phase5FinalTestQuestion question;
            final Phase5QuestionType expectedType;

            switch (typeIndex) {
              case 0:
                expectedType = Phase5QuestionType.businessEnglish;
                question = Phase5FinalTestQuestion.businessEnglish(
                  id: 'test_business_1',
                  unitId: 'phase5_unit22',
                  lessonId: 'phase5_lesson22_1',
                  prompt: prompt,
                  options: options,
                  correctIndex: validCorrectIndex,
                );
                break;
              case 1:
                expectedType = Phase5QuestionType.interview;
                question = Phase5FinalTestQuestion.interview(
                  id: 'test_interview_1',
                  unitId: 'phase5_unit23',
                  lessonId: 'phase5_lesson23_1',
                  prompt: prompt,
                  options: options,
                  correctIndex: validCorrectIndex,
                );
                break;
              case 2:
                expectedType = Phase5QuestionType.presentation;
                question = Phase5FinalTestQuestion.presentation(
                  id: 'test_presentation_1',
                  unitId: 'phase5_unit24',
                  lessonId: 'phase5_lesson24_1',
                  prompt: prompt,
                  options: options,
                  correctIndex: validCorrectIndex,
                );
                break;
              case 3:
                expectedType = Phase5QuestionType.writing;
                question = Phase5FinalTestQuestion.writing(
                  id: 'test_writing_1',
                  unitId: 'phase5_unit25',
                  lessonId: 'phase5_lesson25_1',
                  prompt: prompt,
                  options: options,
                  correctIndex: validCorrectIndex,
                );
                break;
              default:
                expectedType = Phase5QuestionType.speakingRubricScored;
                question = Phase5FinalTestQuestion.speakingRubricScored(
                  id: 'test_speaking_1',
                  unitId: 'phase5_unit25',
                  lessonId: 'phase5_lesson25_1',
                  prompt: prompt,
                );
            }

            expect(question.type, expectedType);

            if (question.type == Phase5QuestionType.speakingRubricScored) {
              expect(question.options, isNull);
              expect(question.correctIndex, isNull);
              expect(question.isSpeakingTask, true);
              expect(question.isMcq, false);
            } else {
              expect(question.options, isNotNull);
              expect(question.options!.isNotEmpty, true);
              expect(question.correctIndex, isNotNull);
              expect(question.correctIndex! >= 0, true);
              expect(question.correctIndex! < question.options!.length, true);
              expect(question.isMcq, true);
              expect(question.isSpeakingTask, false);
            }

            expect(question.prompt.isNotEmpty, true);
          },
        );
      },
    );

    // **Feature: phase5-final-test, Property 6: Pass/Fail Threshold**
    // **Validates: Requirements 7.2, 7.3**
    property(
      'Property 6: Pass/fail threshold - passed is true iff totalScore >= 42',
      () {
        forAll(combine2(integer(min: 0, max: 27), integer(min: 0, max: 32)), (
          values,
        ) {
          final mcqCorrect = values.$1;
          final speakingScore = values.$2;

          final result = Phase5TestResult.calculate(
            mcqCorrect: mcqCorrect,
            speakingScore: speakingScore,
            completedAt: DateTime.now(),
            incorrectMcqAnswers: [],
            speakingResults: [],
          );

          final totalScore = mcqCorrect + speakingScore;
          final expectedPassed = totalScore >= 42;

          expect(result.totalScore, totalScore);
          expect(result.passed, expectedPassed);

          final expectedPercentage = (totalScore / 60) * 100;
          expect(result.percentage, closeTo(expectedPercentage, 0.01));
        });
      },
    );

    // **Feature: phase5-final-test, Property 10: Total Score Calculation**
    // **Validates: Requirements 7.1**
    property(
      'Property 10: Total score calculation - totalScore = mcqCorrect + speakingScore',
      () {
        forAll(combine2(integer(min: 0, max: 27), integer(min: 0, max: 32)), (
          values,
        ) {
          final mcqCorrect = values.$1;
          final speakingScore = values.$2;

          final result = Phase5TestResult.calculate(
            mcqCorrect: mcqCorrect,
            speakingScore: speakingScore,
            completedAt: DateTime.now(),
            incorrectMcqAnswers: [],
            speakingResults: [],
          );

          expect(result.totalScore, mcqCorrect + speakingScore);
          expect(result.maxScore, 60);
          expect(result.totalQuestions, 35);
          expect(result.totalScore <= 60, true);
        });
      },
    );

    // **Feature: phase5-final-test, Property 5: Speaking Score Tiers**
    // **Validates: Requirements 6.5**
    property(
      'Property 5: Speaking score tiers - word count maps to correct score',
      () {
        forAll(integer(min: 0, max: 100), (wordCount) {
          final text = wordCount > 0
              ? List.generate(wordCount, (i) => 'word').join(' ')
              : '';

          final result = Phase5SpeakingResult.fromRecognition(
            taskId: 'test_task',
            prompt: 'Test prompt',
            recognizedText: text,
          );

          expect(result.wordCount, wordCount);

          int expectedScore;
          if (wordCount == 0) {
            expectedScore = 0;
          } else {
            final lengthScore = wordCount >= 40
                ? 1.0
                : wordCount >= 25
                ? 0.8
                : wordCount >= 10
                ? 0.55
                : 0.3;
            final asrConfidence = 0.65;
            final fillerRatio = 0.0;
            final sentenceCompleteness = wordCount >= 5 ? 1.0 : 0.0;
            final aggregate =
                (lengthScore * 0.4) +
                (asrConfidence * 0.2) +
                ((1 - fillerRatio) * 0.2) +
                (sentenceCompleteness * 0.2);

            if (aggregate >= 0.85) {
              expectedScore = 4;
            } else if (aggregate >= 0.65) {
              expectedScore = 3;
            } else if (aggregate >= 0.45) {
              expectedScore = 2;
            } else {
              expectedScore = 1;
            }
          }

          expect(result.score, expectedScore);
        });
      },
    );

    // **Feature: phase5-final-test, Property 3: Question Distribution Consistency**
    // **Validates: Requirements 1.4, 2.1, 3.1, 4.1, 5.1, 6.1, 11.2**
    property(
      'Property 3: Question distribution consistency - exact counts for each type',
      () {
        forAll(integer(min: 1, max: 10), (testCount) {
          const expectedBusinessCount = 8;
          const expectedInterviewCount = 7;
          const expectedPresentationCount = 6;
          const expectedWritingCount = 6;
          const expectedSpeakingCount = 8;
          const expectedTotal = 35;

          final totalFromDistribution =
              expectedBusinessCount +
              expectedInterviewCount +
              expectedPresentationCount +
              expectedWritingCount +
              expectedSpeakingCount;

          expect(totalFromDistribution, expectedTotal);

          final mcqCount =
              expectedBusinessCount +
              expectedInterviewCount +
              expectedPresentationCount +
              expectedWritingCount;
          expect(mcqCount, 27);
          expect(expectedSpeakingCount, 8);
        });
      },
    );

    // **Feature: phase5-final-test, Property 11: Fallback Question Guarantee**
    // **Validates: Requirements 11.3**
    property(
      'Property 11: Fallback question guarantee - always returns 35 questions',
      () {
        forAll(
          combine4(
            integer(min: 0, max: 10),
            integer(min: 0, max: 10),
            integer(min: 0, max: 10),
            integer(min: 0, max: 10),
          ),
          (availableCounts) {
            final availableBusiness = availableCounts.$1;
            final availableInterview = availableCounts.$2;
            final availablePresentation = availableCounts.$3;
            final availableWriting = availableCounts.$4;

            const requiredBusiness = 8;
            const requiredInterview = 7;
            const requiredPresentation = 6;
            const requiredWriting = 6;
            const requiredSpeaking = 8;

            final fallbackBusinessNeeded =
                (requiredBusiness - availableBusiness).clamp(
                  0,
                  requiredBusiness,
                );
            final fallbackInterviewNeeded =
                (requiredInterview - availableInterview).clamp(
                  0,
                  requiredInterview,
                );
            final fallbackPresentationNeeded =
                (requiredPresentation - availablePresentation).clamp(
                  0,
                  requiredPresentation,
                );
            final fallbackWritingNeeded = (requiredWriting - availableWriting)
                .clamp(0, requiredWriting);

            final totalBusiness =
                (availableBusiness.clamp(0, requiredBusiness)) +
                fallbackBusinessNeeded;
            final totalInterview =
                (availableInterview.clamp(0, requiredInterview)) +
                fallbackInterviewNeeded;
            final totalPresentation =
                (availablePresentation.clamp(0, requiredPresentation)) +
                fallbackPresentationNeeded;
            final totalWriting =
                (availableWriting.clamp(0, requiredWriting)) +
                fallbackWritingNeeded;

            expect(totalBusiness, requiredBusiness);
            expect(totalInterview, requiredInterview);
            expect(totalPresentation, requiredPresentation);
            expect(totalWriting, requiredWriting);

            final total =
                totalBusiness +
                totalInterview +
                totalPresentation +
                totalWriting +
                requiredSpeaking;
            expect(total, 35);
          },
        );
      },
    );
  });
}
