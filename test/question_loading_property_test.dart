import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:engliya/features/learn/domain/entities/phase_config.dart';
import 'package:engliya/features/learn/domain/entities/test_question.dart';
import 'package:engliya/features/learn/domain/entities/test_result.dart';
import 'package:engliya/features/learn/domain/repositories/test_repository.dart';
import 'package:engliya/features/learn/data/repositories/test_repository_impl.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/models/lesson.dart';
import 'package:engliya/features/learn/data/models/lesson_explain.dart';
import 'package:engliya/features/learn/data/models/quiz_question.dart';
import 'package:engliya/services/local_storage/storage_service.dart';

/// Mock LessonRepository that returns lessons with questions
/// for testing question loading phase consistency
class MockLessonRepository extends LessonRepository {
  final Map<String, Lesson> _lessons = {};

  void addLesson(Lesson lesson) {
    _lessons[lesson.id] = lesson;
  }

  @override
  Future<Lesson> loadLesson(String lessonId) async {
    if (_lessons.containsKey(lessonId)) {
      return _lessons[lessonId]!;
    }
    throw LessonLoadException('Lesson not found: $lessonId');
  }
}

/// Mock StorageService for testing
class MockStorageService extends StorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> setBool(String key, bool value) async {
    _storage[key] = value;
  }

  @override
  bool? getBool(String key) => _storage[key] as bool?;

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  int? getInt(String key) => _storage[key] as int?;

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  String? getString(String key) => _storage[key] as String?;

  @override
  Future<void> setJson(String key, Map<String, dynamic> json) async {
    _storage[key] = json;
  }

  @override
  Map<String, dynamic>? getJson(String key) =>
      _storage[key] as Map<String, dynamic>?;

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

/// Helper to create a mock lesson with questions
Lesson createMockLesson({
  required String id,
  required String unitId,
  required String title,
  int practiceQuestionCount = 5,
  int masteryQuestionCount = 5,
}) {
  final practiceQuestions = List.generate(
    practiceQuestionCount,
    (i) => QuizQuestion(
      type: 'mcq',
      promptEn: 'Practice question $i for $id',
      promptTa: 'Tamil practice $i',
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      correctIndex: i % 4,
    ),
  );

  final masteryQuestions = List.generate(
    masteryQuestionCount,
    (i) => QuizQuestion(
      type: 'mcq',
      promptEn: 'Mastery question $i for $id',
      promptTa: 'Tamil mastery $i',
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      correctIndex: i % 4,
    ),
  );

  return Lesson(
    id: id,
    order: 1,
    unitId: unitId,
    title: title,
    description: 'Test lesson description',
    level: 'beginner',
    explain: LessonExplain(
      ta: 'Tamil explanation',
      en: 'English explanation',
    ),
    examples: [],
    listeningQuestions: [],
    speakSentences: [],
    practiceQuestions: practiceQuestions,
    masteryQuestions: masteryQuestions,
  );
}

/// Setup mock repository with lessons for a specific phase
MockLessonRepository setupMockRepositoryForPhase(PhaseConfig config) {
  final mockRepo = MockLessonRepository();

  // Add lessons for all lesson IDs in the phase config
  for (final lessonId in config.lessonToUnitMapping.keys) {
    final unitId = config.lessonToUnitMapping[lessonId];
    mockRepo.addLesson(createMockLesson(
      id: lessonId,
      unitId: unitId ?? 'default',
      title: 'Lesson $lessonId',
    ));
  }

  return mockRepo;
}

void main() {
  group('Question Loading Phase Consistency Property Tests', () {
    // **Feature: clean-architecture-refactor, Property 4: Question Loading Phase Consistency**
    // **Validates: Requirements 2.2**
    // *For any* PhaseConfig, when generating a test, all returned TestQuestion objects
    // should have lessonIds that match the phase's lessonToUnitMapping keys
    // (i.e., questions come from the correct phase's lessons).
    //
    // Note: This test only covers phases 1-3 which have standard lesson-to-unit mappings.
    // Phases 4-5 use category-based question distribution and require different handling.
    property(
      'Property 4: All generated test questions come from the correct phase lessons',
      () {
        forAll(
          integer(min: 0, max: 2), // phaseIndex (0-2 for phases 1-3)
          (phaseIndex) async {
            final phaseType = PhaseType.values[phaseIndex];
            final config = PhaseConfig.fromType(phaseType);

            // Setup mock repository with lessons for this phase
            final mockLessonRepo = setupMockRepositoryForPhase(config);
            final mockStorageService = MockStorageService();

            final repository = TestRepositoryImpl(
              lessonRepository: mockLessonRepo,
              storageService: mockStorageService,
              random: Random(42), // Fixed seed for reproducibility
            );

            // Generate test
            final questions = await repository.generateTest(config);

            // Verify all questions come from the correct phase
            final validLessonIds = config.lessonToUnitMapping.keys.toSet();

            for (final question in questions) {
              expect(
                validLessonIds.contains(question.lessonId),
                isTrue,
                reason:
                    'Question lessonId "${question.lessonId}" should be in phase ${config.id} lesson mapping. '
                    'Valid lesson IDs: $validLessonIds',
              );
            }

            // Verify we got the expected number of questions
            expect(
              questions.length,
              lessThanOrEqualTo(config.totalQuestions),
              reason:
                  'Should not exceed totalQuestions (${config.totalQuestions})',
            );
          },
        );
      },
    );

    // Additional property: Questions should have correct unitId based on phase config
    property(
      'Property 4b: All generated test questions have correct unitId from phase config',
      () {
        forAll(
          integer(min: 0, max: 2), // phaseIndex (0-2 for phases 1-3)
          (phaseIndex) async {
            final phaseType = PhaseType.values[phaseIndex];
            final config = PhaseConfig.fromType(phaseType);

            // Setup mock repository with lessons for this phase
            final mockLessonRepo = setupMockRepositoryForPhase(config);
            final mockStorageService = MockStorageService();

            final repository = TestRepositoryImpl(
              lessonRepository: mockLessonRepo,
              storageService: mockStorageService,
              random: Random(42),
            );

            // Generate test
            final questions = await repository.generateTest(config);

            // Verify unitId matches the phase config mapping
            for (final question in questions) {
              final expectedUnitId =
                  config.lessonToUnitMapping[question.lessonId];

              expect(
                question.unitId,
                expectedUnitId,
                reason:
                    'Question from lesson "${question.lessonId}" should have unitId "$expectedUnitId" '
                    'but has "${question.unitId}"',
              );
            }
          },
        );
      },
    );

    // Property: No cross-phase contamination
    property(
      'Property 4c: Questions from one phase do not appear in another phase test',
      () {
        forAll(
          combine2(
            integer(min: 0, max: 2), // first phase index (0-2 for phases 1-3)
            integer(min: 0, max: 2), // second phase index (0-2 for phases 1-3)
          ),
          (values) async {
            final phaseIndex1 = values.$1;
            final phaseIndex2 = values.$2;

            // Skip if same phase
            if (phaseIndex1 == phaseIndex2) return;

            final config1 = PhaseConfig.fromType(PhaseType.values[phaseIndex1]);
            final config2 = PhaseConfig.fromType(PhaseType.values[phaseIndex2]);

            // Setup mock repository with lessons for phase 1 only
            final mockLessonRepo = setupMockRepositoryForPhase(config1);
            final mockStorageService = MockStorageService();

            final repository = TestRepositoryImpl(
              lessonRepository: mockLessonRepo,
              storageService: mockStorageService,
              random: Random(42),
            );

            // Generate test for phase 1
            final questions = await repository.generateTest(config1);

            // Verify no questions have lessonIds from phase 2
            final phase2LessonIds = config2.lessonToUnitMapping.keys.toSet();

            for (final question in questions) {
              // Only check if the lesson ID patterns are different
              // (e.g., phase1_lesson1 vs phase2_lesson7_1)
              if (question.lessonId.startsWith(config2.id)) {
                fail(
                  'Question from phase ${config1.id} should not have lessonId '
                  'starting with "${config2.id}": ${question.lessonId}',
                );
              }
            }
          },
        );
      },
    );
  });
}
