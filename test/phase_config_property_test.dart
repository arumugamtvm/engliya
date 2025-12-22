import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:engliya/features/learn/domain/entities/phase_config.dart';

void main() {
  group('PhaseConfig Property Tests', () {
    // **Feature: clean-architecture-refactor, Property 2: Phase Configuration Validity**
    // **Validates: Requirements 8.1, 8.2, 8.3**
    // *For any* PhaseType value, the corresponding PhaseConfig should contain:
    // - A non-empty id and name
    // - A valid asset path following the pattern `assets/lessons/phase{n}/`
    // - A positive passingScore that is less than or equal to maxScore
    // - A non-empty questionDistribution map
    // - Valid storage key prefixes that are unique per phase
    property('Property 2: Phase configuration validity - all phases have valid configurations', () {
      // Test all 5 phase types
      forAll(
        integer(min: 0, max: 4), // PhaseType index (0-4 for 5 phases)
        (phaseIndex) {
          final phaseType = PhaseType.values[phaseIndex];
          final config = PhaseConfig.fromType(phaseType);

          // Verify non-empty id and name
          expect(config.id.isNotEmpty, true,
              reason: '${phaseType.name} should have non-empty id');
          expect(config.name.isNotEmpty, true,
              reason: '${phaseType.name} should have non-empty name');

          // Verify valid asset path pattern
          expect(config.assetPath.startsWith('assets/lessons/'),
              true,
              reason: '${phaseType.name} asset path should start with assets/lessons/');
          expect(config.assetPath.endsWith('/'), true,
              reason: '${phaseType.name} asset path should end with /');

          // Verify passing score is positive and <= maxScore
          expect(config.passingScore > 0, true,
              reason: '${phaseType.name} passingScore should be positive');
          expect(config.passingScore <= config.maxScore, true,
              reason: '${phaseType.name} passingScore should be <= maxScore');

          // Verify totalQuestions is positive
          expect(config.totalQuestions > 0, true,
              reason: '${phaseType.name} totalQuestions should be positive');

          // Verify maxScore is positive
          expect(config.maxScore > 0, true,
              reason: '${phaseType.name} maxScore should be positive');

          // Verify non-empty questionDistribution
          expect(config.questionDistribution.isNotEmpty, true,
              reason: '${phaseType.name} should have non-empty questionDistribution');

          // Verify all distribution values are positive
          for (final entry in config.questionDistribution.entries) {
            expect(entry.value > 0, true,
                reason: '${phaseType.name} questionDistribution[${entry.key}] should be positive');
          }

          // Verify non-empty lessonToUnitMapping
          expect(config.lessonToUnitMapping.isNotEmpty, true,
              reason: '${phaseType.name} should have non-empty lessonToUnitMapping');

          // Verify non-empty requiredLessonIds
          expect(config.requiredLessonIds.isNotEmpty, true,
              reason: '${phaseType.name} should have non-empty requiredLessonIds');

          // Verify storage key prefix is non-empty
          expect(config.storageKeyPrefix.isNotEmpty, true,
              reason: '${phaseType.name} should have non-empty storageKeyPrefix');

          // Verify derived storage keys are non-empty
          expect(config.keyTestPassed.isNotEmpty, true,
              reason: '${phaseType.name} keyTestPassed should be non-empty');
          expect(config.keyTestScore.isNotEmpty, true,
              reason: '${phaseType.name} keyTestScore should be non-empty');
          expect(config.keyTestDate.isNotEmpty, true,
              reason: '${phaseType.name} keyTestDate should be non-empty');
          expect(config.keyTestResult.isNotEmpty, true,
              reason: '${phaseType.name} keyTestResult should be non-empty');
          expect(config.keyNextPhaseUnlocked.isNotEmpty, true,
              reason: '${phaseType.name} keyNextPhaseUnlocked should be non-empty');
        },
      );
    });

    // Property 2b: Storage keys are unique per phase
    property('Property 2b: Storage keys uniqueness - each phase has unique storage keys', () {
      // Collect all storage keys from all phases
      final allKeyTestPassed = <String>{};
      final allKeyTestScore = <String>{};
      final allKeyTestDate = <String>{};
      final allKeyTestResult = <String>{};

      for (final phaseType in PhaseType.values) {
        final config = PhaseConfig.fromType(phaseType);

        // Verify keyTestPassed is unique
        expect(allKeyTestPassed.contains(config.keyTestPassed), false,
            reason: '${phaseType.name} keyTestPassed should be unique');
        allKeyTestPassed.add(config.keyTestPassed);

        // Verify keyTestScore is unique
        expect(allKeyTestScore.contains(config.keyTestScore), false,
            reason: '${phaseType.name} keyTestScore should be unique');
        allKeyTestScore.add(config.keyTestScore);

        // Verify keyTestDate is unique
        expect(allKeyTestDate.contains(config.keyTestDate), false,
            reason: '${phaseType.name} keyTestDate should be unique');
        allKeyTestDate.add(config.keyTestDate);

        // Verify keyTestResult is unique
        expect(allKeyTestResult.contains(config.keyTestResult), false,
            reason: '${phaseType.name} keyTestResult should be unique');
        allKeyTestResult.add(config.keyTestResult);
      }

      // Verify we have 5 unique keys for each type
      expect(allKeyTestPassed.length, 5,
          reason: 'Should have 5 unique keyTestPassed values');
      expect(allKeyTestScore.length, 5,
          reason: 'Should have 5 unique keyTestScore values');
      expect(allKeyTestDate.length, 5,
          reason: 'Should have 5 unique keyTestDate values');
      expect(allKeyTestResult.length, 5,
          reason: 'Should have 5 unique keyTestResult values');
    });

    // Property 2c: PhaseConfig.fromType returns correct config for each type
    property('Property 2c: fromType consistency - fromType returns matching config', () {
      forAll(
        integer(min: 0, max: 4),
        (phaseIndex) {
          final phaseType = PhaseType.values[phaseIndex];
          final config = PhaseConfig.fromType(phaseType);

          // Verify the config type matches the requested type
          expect(config.type, phaseType,
              reason: 'Config type should match requested PhaseType');

          // Verify the id contains the phase number
          final expectedPhaseNumber = phaseIndex + 1;
          expect(config.id.contains('$expectedPhaseNumber') || config.id.contains('phase$expectedPhaseNumber'),
              true,
              reason: 'Config id should contain phase number $expectedPhaseNumber');
        },
      );
    });

    // Property 2d: Lesson-to-unit mapping consistency
    property('Property 2d: Lesson mapping consistency - all required lessons are in mapping', () {
      forAll(
        integer(min: 0, max: 4),
        (phaseIndex) {
          final phaseType = PhaseType.values[phaseIndex];
          final config = PhaseConfig.fromType(phaseType);

          // Verify all required lesson IDs are in the lessonToUnitMapping
          for (final lessonId in config.requiredLessonIds) {
            expect(config.lessonToUnitMapping.containsKey(lessonId), true,
                reason: '${phaseType.name} required lesson $lessonId should be in lessonToUnitMapping');
          }
        },
      );
    });

    // Property 2e: Unit helper methods work correctly
    property('Property 2e: Unit helper methods - getUnitForLesson and getLessonsForUnit work correctly', () {
      forAll(
        integer(min: 0, max: 4),
        (phaseIndex) {
          final phaseType = PhaseType.values[phaseIndex];
          final config = PhaseConfig.fromType(phaseType);

          // Test getUnitForLesson for each lesson in the mapping
          for (final entry in config.lessonToUnitMapping.entries) {
            final lessonId = entry.key;
            final expectedUnitId = entry.value;

            final actualUnitId = config.getUnitForLesson(lessonId);
            expect(actualUnitId, expectedUnitId,
                reason: 'getUnitForLesson($lessonId) should return $expectedUnitId');
          }

          // Test getLessonsForUnit for each unit
          final unitIds = config.lessonToUnitMapping.values.toSet();
          for (final unitId in unitIds) {
            final lessons = config.getLessonsForUnit(unitId);
            expect(lessons.isNotEmpty, true,
                reason: 'getLessonsForUnit($unitId) should return non-empty list');

            // Verify all returned lessons map back to this unit
            for (final lessonId in lessons) {
              expect(config.getUnitForLesson(lessonId), unitId,
                  reason: 'Lesson $lessonId should map to unit $unitId');
            }
          }
        },
      );
    });

    // Property 2f: hasUnits correctly identifies phases with unit organization
    property('Property 2f: hasUnits flag - correctly identifies phases with units', () {
      forAll(
        integer(min: 0, max: 4),
        (phaseIndex) {
          final phaseType = PhaseType.values[phaseIndex];
          final config = PhaseConfig.fromType(phaseType);

          // hasUnits should be true if unitNames is not empty
          expect(config.hasUnits, config.unitNames.isNotEmpty,
              reason: '${phaseType.name} hasUnits should match unitNames.isNotEmpty');
        },
      );
    });
  });
}
