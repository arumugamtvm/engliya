import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:engliya/features/learn/domain/entities/phase_config.dart';
import 'package:engliya/features/learn/domain/entities/test_question.dart';
import 'package:engliya/features/learn/domain/entities/test_result.dart';
import 'package:engliya/features/learn/data/repositories/test_repository_impl.dart';

/// Helper to generate a list of test questions
List<TestQuestion> generateTestQuestions({
  required int count,
  String? unitId,
  String lessonIdPrefix = 'lesson',
}) {
  return List.generate(
    count,
    (i) => TestQuestion(
      id: 'q$i',
      lessonId: '${lessonIdPrefix}_$i',
      lessonTitle: 'Lesson $i',
      unitId: unitId,
      promptEn: 'Question $i: What is the answer?',
      options: const ['Option A', 'Option B', 'Option C', 'Option D'],
      correctIndex: i % 4, // Correct answer cycles through 0, 1, 2, 3
    ),
  );
}

/// Helper to generate selected answers with a specific number of correct answers
List<int?> generateAnswers({
  required List<TestQuestion> questions,
  required int correctCount,
  bool includeNulls = false,
}) {
  final answers = <int?>[];
  int correctRemaining = correctCount;

  for (int i = 0; i < questions.length; i++) {
    if (correctRemaining > 0 && (questions.length - i) <= correctRemaining) {
      // Must answer correctly to meet the target
      answers.add(questions[i].correctIndex);
      correctRemaining--;
    } else if (correctRemaining > 0 && i % 2 == 0) {
      // Answer correctly on even indices until we reach the target
      answers.add(questions[i].correctIndex);
      correctRemaining--;
    } else if (includeNulls && i % 5 == 0) {
      // Add some null answers (skipped questions)
      answers.add(null);
    } else {
      // Answer incorrectly
      answers.add((questions[i].correctIndex + 1) % 4);
    }
  }

  return answers;
}

void main() {
  group('Test Result Calculation Property Tests', () {
    // **Feature: clean-architecture-refactor, Property 3: Test Result Calculation Correctness**
    // **Validates: Requirements 2.3**
    // *For any* PhaseConfig, list of TestQuestions, and list of selected answers:
    // - The calculated correctAnswers + incorrectAnswers should equal totalQuestions
    // - The accuracy should equal (correctAnswers / totalQuestions) * 100
    // - The passed status should be true if and only if correctAnswers >= config.passingScore
    // - The incorrectQuestionDetails list should have exactly incorrectAnswers items

    property(
      'Property 3a: correctAnswers + incorrectAnswers equals totalQuestions',
      () {
        forAll(
          combine2(
            integer(min: 5, max: 50), // totalQuestions
            integer(min: 0, max: 50), // correctCount (will be clamped)
          ),
          (values) {
            final totalQuestions = values.$1;
            final correctCount = values.$2 > totalQuestions ? totalQuestions : values.$2;

            final questions = generateTestQuestions(count: totalQuestions);
            final answers = generateAnswers(
              questions: questions,
              correctCount: correctCount,
            );

            final result = TestResult.calculate(
              questions: questions,
              selectedAnswers: answers,
              passingScore: 16,
              completedAt: DateTime.now(),
            );

            expect(
              result.correctAnswers + result.incorrectAnswers,
              result.totalQuestions,
              reason:
                  'correctAnswers (${result.correctAnswers}) + incorrectAnswers (${result.incorrectAnswers}) '
                  'should equal totalQuestions (${result.totalQuestions})',
            );
          },
        );
      },
    );

    property(
      'Property 3b: accuracy equals (correctAnswers / totalQuestions) * 100',
      () {
        forAll(
          combine2(
            integer(min: 1, max: 50), // totalQuestions (min 1 to avoid division by zero)
            integer(min: 0, max: 50), // correctCount (will be clamped)
          ),
          (values) {
            final totalQuestions = values.$1;
            final correctCount = values.$2 > totalQuestions ? totalQuestions : values.$2;

            final questions = generateTestQuestions(count: totalQuestions);
            final answers = generateAnswers(
              questions: questions,
              correctCount: correctCount,
            );

            final result = TestResult.calculate(
              questions: questions,
              selectedAnswers: answers,
              passingScore: 16,
              completedAt: DateTime.now(),
            );

            final expectedAccuracy =
                (result.correctAnswers / result.totalQuestions) * 100;

            expect(
              result.accuracy,
              closeTo(expectedAccuracy, 0.001),
              reason:
                  'accuracy (${result.accuracy}) should equal (${result.correctAnswers} / ${result.totalQuestions}) * 100 = $expectedAccuracy',
            );
          },
        );
      },
    );


    property(
      'Property 3c: passed is true iff correctAnswers >= passingScore',
      () {
        forAll(
          combine3(
            integer(min: 10, max: 50), // totalQuestions
            integer(min: 0, max: 50), // correctCount (will be clamped)
            integer(min: 1, max: 50), // passingScore (will be clamped)
          ),
          (values) {
            final totalQuestions = values.$1;
            final correctCount = values.$2 > totalQuestions ? totalQuestions : values.$2;
            final passingScore = values.$3 > totalQuestions ? totalQuestions : values.$3;

            final questions = generateTestQuestions(count: totalQuestions);
            final answers = generateAnswers(
              questions: questions,
              correctCount: correctCount,
            );

            final result = TestResult.calculate(
              questions: questions,
              selectedAnswers: answers,
              passingScore: passingScore,
              completedAt: DateTime.now(),
            );

            final expectedPassed = result.correctAnswers >= passingScore;

            expect(
              result.passed,
              expectedPassed,
              reason:
                  'passed (${result.passed}) should be ${result.correctAnswers} >= $passingScore = $expectedPassed',
            );
          },
        );
      },
    );

    property(
      'Property 3d: incorrectQuestionDetails has exactly incorrectAnswers items',
      () {
        forAll(
          combine2(
            integer(min: 5, max: 50), // totalQuestions
            integer(min: 0, max: 50), // correctCount (will be clamped)
          ),
          (values) {
            final totalQuestions = values.$1;
            final correctCount = values.$2 > totalQuestions ? totalQuestions : values.$2;

            final questions = generateTestQuestions(count: totalQuestions);
            final answers = generateAnswers(
              questions: questions,
              correctCount: correctCount,
            );

            final result = TestResult.calculate(
              questions: questions,
              selectedAnswers: answers,
              passingScore: 16,
              completedAt: DateTime.now(),
            );

            expect(
              result.incorrectQuestionDetails.length,
              result.incorrectAnswers,
              reason:
                  'incorrectQuestionDetails.length (${result.incorrectQuestionDetails.length}) '
                  'should equal incorrectAnswers (${result.incorrectAnswers})',
            );
          },
        );
      },
    );

    // Additional property: Unit breakdown is correctly calculated for phases with units
    property(
      'Property 3e: Unit breakdown correctly tracks per-unit performance',
      () {
        forAll(
          combine3(
            integer(min: 2, max: 5), // number of units
            integer(min: 2, max: 10), // questions per unit
            integer(min: 0, max: 10), // correct per unit (will be clamped)
          ),
          (values) {
            final numUnits = values.$1;
            final questionsPerUnit = values.$2;
            final correctPerUnit = values.$3 > questionsPerUnit ? questionsPerUnit : values.$3;

            // Generate questions with unit IDs
            final questions = <TestQuestion>[];
            for (int u = 0; u < numUnits; u++) {
              for (int q = 0; q < questionsPerUnit; q++) {
                questions.add(TestQuestion(
                  id: 'unit${u}_q$q',
                  lessonId: 'lesson_unit$u',
                  lessonTitle: 'Lesson Unit $u',
                  unitId: 'unit$u',
                  promptEn: 'Unit $u Question $q',
                  options: const ['A', 'B', 'C', 'D'],
                  correctIndex: q % 4,
                ));
              }
            }

            // Generate answers with specific correct count per unit
            final answers = <int?>[];
            for (int u = 0; u < numUnits; u++) {
              for (int q = 0; q < questionsPerUnit; q++) {
                final questionIndex = u * questionsPerUnit + q;
                if (q < correctPerUnit) {
                  answers.add(questions[questionIndex].correctIndex);
                } else {
                  answers.add((questions[questionIndex].correctIndex + 1) % 4);
                }
              }
            }

            final unitNames = <String, String>{};
            for (int u = 0; u < numUnits; u++) {
              unitNames['unit$u'] = 'Unit $u Name';
            }

            final result = TestResult.calculate(
              questions: questions,
              selectedAnswers: answers,
              passingScore: 1,
              completedAt: DateTime.now(),
              unitNames: unitNames,
            );

            // Verify unit breakdown exists
            expect(result.unitBreakdown, isNotNull);
            expect(result.unitBreakdown!.length, numUnits);

            // Verify each unit has correct stats
            for (int u = 0; u < numUnits; u++) {
              final unitPerf = result.unitBreakdown!['unit$u'];
              expect(unitPerf, isNotNull, reason: 'Unit $u should exist in breakdown');
              expect(unitPerf!.totalQuestions, questionsPerUnit,
                  reason: 'Unit $u should have $questionsPerUnit questions');
              expect(unitPerf.correctAnswers, correctPerUnit,
                  reason: 'Unit $u should have $correctPerUnit correct answers');
            }
          },
        );
      },
    );

    // Property: Null answers (skipped questions) are counted as incorrect
    property(
      'Property 3f: Null answers are counted as incorrect',
      () {
        forAll(
          combine2(
            integer(min: 5, max: 30), // totalQuestions
            integer(min: 1, max: 10), // number of null answers (will be clamped)
          ),
          (values) {
            final totalQuestions = values.$1;
            final nullCount = values.$2 > totalQuestions ? totalQuestions : values.$2;

            final questions = generateTestQuestions(count: totalQuestions);

            // Generate answers with some nulls
            final answers = <int?>[];
            for (int i = 0; i < totalQuestions; i++) {
              if (i < nullCount) {
                answers.add(null); // Skipped
              } else {
                answers.add(questions[i].correctIndex); // Correct
              }
            }

            final result = TestResult.calculate(
              questions: questions,
              selectedAnswers: answers,
              passingScore: 1,
              completedAt: DateTime.now(),
            );

            // Null answers should be counted as incorrect
            expect(
              result.incorrectAnswers,
              greaterThanOrEqualTo(nullCount),
              reason:
                  'At least $nullCount null answers should be counted as incorrect',
            );

            // Verify skipped questions are in incorrectQuestionDetails
            final skippedDetails = result.incorrectQuestionDetails
                .where((d) => d.wasSkipped)
                .toList();
            expect(
              skippedDetails.length,
              nullCount,
              reason: 'Should have $nullCount skipped question details',
            );
          },
        );
      },
    );

    // Property: Using TestResultCalculator helper produces same results
    property(
      'Property 3g: TestResultCalculator produces consistent results',
      () {
        forAll(
          combine2(
            integer(min: 0, max: 2), // phaseIndex (phases 1-3)
            integer(min: 0, max: 20), // correctCount (will be clamped)
          ),
          (values) {
            final phaseIndex = values.$1;
            final config = PhaseConfig.fromType(PhaseType.values[phaseIndex]);
            final correctCount = values.$2 > config.totalQuestions
                ? config.totalQuestions
                : values.$2;

            final questions = generateTestQuestions(count: config.totalQuestions);
            final answers = generateAnswers(
              questions: questions,
              correctCount: correctCount,
            );
            final completedAt = DateTime.now();

            // Calculate using TestResult.calculate directly
            final directResult = TestResult.calculate(
              questions: questions,
              selectedAnswers: answers,
              passingScore: config.passingScore,
              completedAt: completedAt,
              unitNames: config.unitNames,
            );

            // Calculate using TestResultCalculator helper
            final helperResult = TestResultCalculator.calculate(
              config: config,
              questions: questions,
              selectedAnswers: answers,
              completedAt: completedAt,
            );

            // Results should be identical
            expect(helperResult.totalQuestions, directResult.totalQuestions);
            expect(helperResult.correctAnswers, directResult.correctAnswers);
            expect(helperResult.incorrectAnswers, directResult.incorrectAnswers);
            expect(helperResult.accuracy, directResult.accuracy);
            expect(helperResult.passed, directResult.passed);
          },
        );
      },
    );
  });
}
