import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:engliya/features/learn/data/models/test_question_model.dart';
import 'package:engliya/features/learn/data/models/test_result_model.dart';
import 'package:engliya/features/learn/data/models/unit_model.dart';
import 'package:engliya/features/learn/domain/entities/phase_config.dart';
import 'package:engliya/features/learn/domain/entities/test_question.dart';
import 'package:engliya/features/learn/domain/entities/test_result.dart';

void main() {
  group('Model Serialization Property Tests', () {
    // **Feature: clean-architecture-refactor, Property 1: Model Serialization Round-Trip (TestQuestion)**
    // **Validates: Requirements 3.4, 3.5**
    // *For any* valid TestQuestion model instance, serializing to JSON via `toJson()`
    // and then deserializing via `fromJson()` should produce an object that is equivalent to the original.
    property(
        'Property 1: TestQuestionModel round-trip serialization preserves all fields',
        () {
      forAll(
        combine5(
          string(minLength: 1, maxLength: 50), // id
          string(minLength: 1, maxLength: 50), // lessonId
          string(minLength: 1, maxLength: 100), // lessonTitle
          string(minLength: 1, maxLength: 200), // promptEn
          integer(min: 0, max: 3), // correctIndex (0-3 for 4 options)
        ),
        (values) {
          final id = values.$1;
          final lessonId = values.$2;
          final lessonTitle = values.$3;
          final promptEn = values.$4;
          final correctIndex = values.$5;

          // Create a valid TestQuestionModel with 4 options
          final original = TestQuestionModel(
            id: id,
            lessonId: lessonId,
            lessonTitle: lessonTitle,
            unitId: 'unit1',
            promptEn: promptEn,
            promptTa: 'Tamil prompt',
            options: const ['Option A', 'Option B', 'Option C', 'Option D'],
            correctIndex: correctIndex,
            questionType: 'mcq',
          );

          // Serialize to JSON
          final json = original.toJson();

          // Deserialize from JSON
          final restored = TestQuestionModel.fromJson(json);

          // Verify all fields are preserved
          expect(restored.id, original.id, reason: 'id should be preserved');
          expect(restored.lessonId, original.lessonId,
              reason: 'lessonId should be preserved');
          expect(restored.lessonTitle, original.lessonTitle,
              reason: 'lessonTitle should be preserved');
          expect(restored.unitId, original.unitId,
              reason: 'unitId should be preserved');
          expect(restored.promptEn, original.promptEn,
              reason: 'promptEn should be preserved');
          expect(restored.promptTa, original.promptTa,
              reason: 'promptTa should be preserved');
          expect(restored.options, original.options,
              reason: 'options should be preserved');
          expect(restored.correctIndex, original.correctIndex,
              reason: 'correctIndex should be preserved');
          expect(restored.questionType, original.questionType,
              reason: 'questionType should be preserved');
        },
      );
    });

    // Test round-trip with null optional fields
    property(
        'Property 1b: TestQuestionModel round-trip with null optional fields',
        () {
      forAll(
        combine4(
          string(minLength: 1, maxLength: 50), // id
          string(minLength: 1, maxLength: 50), // lessonId
          string(minLength: 1, maxLength: 100), // lessonTitle
          string(minLength: 1, maxLength: 200), // promptEn
        ),
        (values) {
          final id = values.$1;
          final lessonId = values.$2;
          final lessonTitle = values.$3;
          final promptEn = values.$4;

          // Create a TestQuestionModel without optional fields
          final original = TestQuestionModel(
            id: id,
            lessonId: lessonId,
            lessonTitle: lessonTitle,
            unitId: null, // null unitId
            promptEn: promptEn,
            promptTa: null, // null promptTa
            options: const ['Yes', 'No'],
            correctIndex: 0,
            questionType: 'mcq',
          );

          // Serialize to JSON
          final json = original.toJson();

          // Deserialize from JSON
          final restored = TestQuestionModel.fromJson(json);

          // Verify null fields are preserved as null
          expect(restored.unitId, isNull, reason: 'unitId should remain null');
          expect(restored.promptTa, isNull,
              reason: 'promptTa should remain null');
          expect(restored.id, original.id, reason: 'id should be preserved');
          expect(restored.lessonId, original.lessonId,
              reason: 'lessonId should be preserved');
        },
      );
    });

    // Test toEntity conversion
    property('Property 1c: TestQuestionModel toEntity preserves all fields',
        () {
      forAll(
        combine3(
          string(minLength: 1, maxLength: 50), // id
          string(minLength: 1, maxLength: 50), // lessonId
          string(minLength: 1, maxLength: 200), // promptEn
        ),
        (values) {
          final id = values.$1;
          final lessonId = values.$2;
          final promptEn = values.$3;

          final model = TestQuestionModel(
            id: id,
            lessonId: lessonId,
            lessonTitle: 'Test Lesson',
            unitId: 'unit1',
            promptEn: promptEn,
            promptTa: 'Tamil',
            options: const ['A', 'B', 'C'],
            correctIndex: 1,
            questionType: 'mcq',
          );

          final entity = model.toEntity();

          expect(entity.id, model.id);
          expect(entity.lessonId, model.lessonId);
          expect(entity.lessonTitle, model.lessonTitle);
          expect(entity.unitId, model.unitId);
          expect(entity.promptEn, model.promptEn);
          expect(entity.promptTa, model.promptTa);
          expect(entity.options, model.options);
          expect(entity.correctIndex, model.correctIndex);
          expect(entity.questionType, model.questionType);
        },
      );
    });
  });

  group('TestResultModel Serialization Property Tests', () {
    // **Feature: clean-architecture-refactor, Property 1: Model Serialization Round-Trip (TestResult)**
    // **Validates: Requirements 3.4, 3.5**
    // *For any* valid TestResult model instance, serializing to JSON via `toJson()`
    // and then deserializing via `fromJson()` should produce an object that is equivalent to the original.
    property(
        'Property 1: TestResultModel round-trip serialization preserves all fields',
        () {
      forAll(
        combine4(
          integer(min: 1, max: 50), // totalQuestions
          integer(min: 0, max: 50), // correctAnswers (will be clamped)
          boolean(), // passed
          integer(min: 2020, max: 2025), // year for completedAt
        ),
        (values) {
          final totalQuestions = values.$1;
          // Ensure correctAnswers doesn't exceed totalQuestions
          final correctAnswers = values.$2 > totalQuestions ? totalQuestions : values.$2;
          final incorrectAnswers = totalQuestions - correctAnswers;
          final accuracy = totalQuestions > 0
              ? (correctAnswers / totalQuestions) * 100
              : 0.0;
          final passed = values.$3;
          final year = values.$4;

          final completedAt = DateTime(year, 6, 15, 10, 30, 0);

          // Create a valid TestResultModel without unit breakdown
          final original = TestResultModel(
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            accuracy: accuracy,
            passed: passed,
            completedAt: completedAt,
            unitBreakdown: null,
            incorrectQuestionDetails: const [],
          );

          // Serialize to JSON
          final json = original.toJson();

          // Deserialize from JSON
          final restored = TestResultModel.fromJson(json);

          // Verify all fields are preserved
          expect(restored.totalQuestions, original.totalQuestions,
              reason: 'totalQuestions should be preserved');
          expect(restored.correctAnswers, original.correctAnswers,
              reason: 'correctAnswers should be preserved');
          expect(restored.incorrectAnswers, original.incorrectAnswers,
              reason: 'incorrectAnswers should be preserved');
          expect(restored.accuracy, closeTo(original.accuracy, 0.001),
              reason: 'accuracy should be preserved');
          expect(restored.passed, original.passed,
              reason: 'passed should be preserved');
          expect(restored.completedAt, original.completedAt,
              reason: 'completedAt should be preserved');
          expect(restored.unitBreakdown, isNull,
              reason: 'unitBreakdown should remain null');
          expect(restored.incorrectQuestionDetails, isEmpty,
              reason: 'incorrectQuestionDetails should be empty');
        },
      );
    });

    // Test round-trip with unit breakdown
    property(
        'Property 1b: TestResultModel round-trip with unit breakdown preserves all fields',
        () {
      forAll(
        combine3(
          integer(min: 5, max: 30), // totalQuestions
          integer(min: 0, max: 30), // correctAnswers (will be clamped)
          integer(min: 1, max: 5), // number of units
        ),
        (values) {
          final totalQuestions = values.$1;
          final correctAnswers = values.$2 > totalQuestions ? totalQuestions : values.$2;
          final incorrectAnswers = totalQuestions - correctAnswers;
          final accuracy = totalQuestions > 0
              ? (correctAnswers / totalQuestions) * 100
              : 0.0;
          final numUnits = values.$3;

          final completedAt = DateTime(2024, 6, 15, 10, 30, 0);

          // Create unit breakdown
          final unitBreakdown = <String, UnitPerformance>{};
          for (int i = 0; i < numUnits; i++) {
            unitBreakdown['unit$i'] = UnitPerformance(
              unitId: 'unit$i',
              unitName: 'Unit $i',
              totalQuestions: 5,
              correctAnswers: 3,
            );
          }

          final original = TestResultModel(
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            accuracy: accuracy,
            passed: correctAnswers >= (totalQuestions * 0.8).round(),
            completedAt: completedAt,
            unitBreakdown: unitBreakdown,
            incorrectQuestionDetails: const [],
          );

          // Serialize to JSON
          final json = original.toJson();

          // Deserialize from JSON
          final restored = TestResultModel.fromJson(json);

          // Verify unit breakdown is preserved
          expect(restored.unitBreakdown, isNotNull,
              reason: 'unitBreakdown should not be null');
          expect(restored.unitBreakdown!.length, original.unitBreakdown!.length,
              reason: 'unitBreakdown length should be preserved');

          for (final entry in original.unitBreakdown!.entries) {
            final restoredUnit = restored.unitBreakdown![entry.key];
            expect(restoredUnit, isNotNull,
                reason: 'Unit ${entry.key} should exist');
            expect(restoredUnit!.unitId, entry.value.unitId,
                reason: 'unitId should be preserved');
            expect(restoredUnit.unitName, entry.value.unitName,
                reason: 'unitName should be preserved');
            expect(restoredUnit.totalQuestions, entry.value.totalQuestions,
                reason: 'totalQuestions should be preserved');
            expect(restoredUnit.correctAnswers, entry.value.correctAnswers,
                reason: 'correctAnswers should be preserved');
          }
        },
      );
    });

    // Test round-trip with incorrect question details
    property(
        'Property 1c: TestResultModel round-trip with incorrect answers preserves all fields',
        () {
      forAll(
        combine2(
          integer(min: 1, max: 10), // number of incorrect answers
          string(minLength: 1, maxLength: 50), // base prompt
        ),
        (values) {
          final numIncorrect = values.$1;
          final basePrompt = values.$2;

          final completedAt = DateTime(2024, 6, 15, 10, 30, 0);

          // Create incorrect answer details
          final incorrectDetails = <IncorrectAnswer>[];
          for (int i = 0; i < numIncorrect; i++) {
            final question = TestQuestion(
              id: 'q$i',
              lessonId: 'lesson$i',
              lessonTitle: 'Lesson $i',
              unitId: 'unit1',
              promptEn: '$basePrompt $i',
              options: const ['A', 'B', 'C', 'D'],
              correctIndex: 0,
            );
            incorrectDetails.add(IncorrectAnswer(
              question: question,
              selectedIndex: 1,
              selectedAnswer: 'B',
              correctAnswer: 'A',
            ));
          }

          final original = TestResultModel(
            totalQuestions: 20,
            correctAnswers: 20 - numIncorrect,
            incorrectAnswers: numIncorrect,
            accuracy: ((20 - numIncorrect) / 20) * 100,
            passed: (20 - numIncorrect) >= 16,
            completedAt: completedAt,
            unitBreakdown: null,
            incorrectQuestionDetails: incorrectDetails,
          );

          // Serialize to JSON
          final json = original.toJson();

          // Deserialize from JSON
          final restored = TestResultModel.fromJson(json);

          // Verify incorrect question details are preserved
          expect(restored.incorrectQuestionDetails.length,
              original.incorrectQuestionDetails.length,
              reason: 'incorrectQuestionDetails length should be preserved');

          for (int i = 0; i < original.incorrectQuestionDetails.length; i++) {
            final originalDetail = original.incorrectQuestionDetails[i];
            final restoredDetail = restored.incorrectQuestionDetails[i];

            expect(restoredDetail.selectedIndex, originalDetail.selectedIndex,
                reason: 'selectedIndex should be preserved');
            expect(restoredDetail.selectedAnswer, originalDetail.selectedAnswer,
                reason: 'selectedAnswer should be preserved');
            expect(restoredDetail.correctAnswer, originalDetail.correctAnswer,
                reason: 'correctAnswer should be preserved');
            expect(restoredDetail.question.id, originalDetail.question.id,
                reason: 'question.id should be preserved');
            expect(restoredDetail.question.promptEn,
                originalDetail.question.promptEn,
                reason: 'question.promptEn should be preserved');
          }
        },
      );
    });
  });

  group('UnitModel Serialization Property Tests', () {
    // **Feature: clean-architecture-refactor, Property 1: Model Serialization Round-Trip (Unit)**
    // **Validates: Requirements 3.4, 3.5**
    // *For any* valid Unit model instance, serializing to JSON via `toJson()`
    // and then deserializing via `fromJson()` should produce an object that is equivalent to the original.
    property(
        'Property 1: UnitModel round-trip serialization preserves all fields',
        () {
      forAll(
        combine5(
          string(minLength: 1, maxLength: 30), // id
          integer(min: 1, max: 25), // order
          string(minLength: 1, maxLength: 100), // title
          integer(min: 1, max: 20), // lessonCount
          integer(min: 0, max: 20), // masteredCount (will be clamped)
        ),
        (values) {
          final id = values.$1;
          final order = values.$2;
          final title = values.$3;
          final lessonCount = values.$4;
          // Ensure masteredCount doesn't exceed lessonCount
          final masteredCount =
              values.$5 > lessonCount ? lessonCount : values.$5;

          final original = UnitModel(
            id: id,
            order: order,
            title: title,
            description: 'Unit $order: $title',
            lessonCount: lessonCount,
            masteredCount: masteredCount,
          );

          // Serialize to JSON
          final json = original.toJson();

          // Deserialize from JSON
          final restored = UnitModel.fromJson(json);

          // Verify all fields are preserved
          expect(restored.id, original.id, reason: 'id should be preserved');
          expect(restored.order, original.order,
              reason: 'order should be preserved');
          expect(restored.title, original.title,
              reason: 'title should be preserved');
          expect(restored.description, original.description,
              reason: 'description should be preserved');
          expect(restored.lessonCount, original.lessonCount,
              reason: 'lessonCount should be preserved');
          expect(restored.masteredCount, original.masteredCount,
              reason: 'masteredCount should be preserved');
        },
      );
    });

    // Test toEntity conversion
    property('Property 1b: UnitModel toEntity preserves all fields', () {
      forAll(
        combine4(
          string(minLength: 1, maxLength: 30), // id
          integer(min: 1, max: 25), // order
          string(minLength: 1, maxLength: 100), // title
          integer(min: 1, max: 20), // lessonCount
        ),
        (values) {
          final id = values.$1;
          final order = values.$2;
          final title = values.$3;
          final lessonCount = values.$4;

          final model = UnitModel(
            id: id,
            order: order,
            title: title,
            description: 'Test description',
            lessonCount: lessonCount,
            masteredCount: 5,
          );

          final entity = model.toEntity();

          expect(entity.id, model.id);
          expect(entity.order, model.order);
          expect(entity.title, model.title);
          expect(entity.description, model.description);
          expect(entity.lessonCount, model.lessonCount);
          expect(entity.masteredCount, model.masteredCount);
        },
      );
    });

    // Test fromConfig factory
    property('Property 1c: UnitModel fromConfig creates valid units', () {
      forAll(
        combine2(
          integer(min: 0, max: 4), // phaseIndex
          integer(min: 0, max: 10), // masteredCount
        ),
        (values) {
          final phaseIndex = values.$1;
          final masteredCount = values.$2;

          final phaseType = PhaseType.values[phaseIndex];
          final config = PhaseConfig.fromType(phaseType);

          // Skip if phase has no units
          if (!config.hasUnits) return;

          // Get first unit ID from the config
          final unitId = config.unitNames.keys.first;

          final model = UnitModel.fromConfig(unitId, config, masteredCount);

          // Verify the model has valid data
          expect(model.id, unitId, reason: 'id should match unitId');
          expect(model.title, config.unitNames[unitId],
              reason: 'title should match config unitName');
          expect(model.lessonCount, greaterThan(0),
              reason: 'lessonCount should be positive');
          expect(model.masteredCount, masteredCount,
              reason: 'masteredCount should match input');
          expect(model.order, greaterThan(0),
              reason: 'order should be positive');
        },
      );
    });

    // Test withMasteredCount method
    property('Property 1d: UnitModel withMasteredCount updates correctly', () {
      forAll(
        combine3(
          integer(min: 1, max: 20), // lessonCount
          integer(min: 0, max: 20), // original masteredCount
          integer(min: 0, max: 20), // new masteredCount
        ),
        (values) {
          final lessonCount = values.$1;
          final originalMastered =
              values.$2 > lessonCount ? lessonCount : values.$2;
          final newMastered = values.$3 > lessonCount ? lessonCount : values.$3;

          final original = UnitModel(
            id: 'unit1',
            order: 1,
            title: 'Test Unit',
            description: 'Test description',
            lessonCount: lessonCount,
            masteredCount: originalMastered,
          );

          final updated = original.withMasteredCount(newMastered);

          // Verify only masteredCount changed
          expect(updated.id, original.id);
          expect(updated.order, original.order);
          expect(updated.title, original.title);
          expect(updated.description, original.description);
          expect(updated.lessonCount, original.lessonCount);
          expect(updated.masteredCount, newMastered,
              reason: 'masteredCount should be updated');
        },
      );
    });
  });
}
