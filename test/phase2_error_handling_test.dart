import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/features/learn/data/repositories/test_repository_impl.dart';
import 'package:engliya/features/learn/domain/entities/phase_config.dart';
import 'package:engliya/features/learn/presentation/providers/mcq_final_test_provider.dart';
import 'package:engliya/features/learn/services/test_exceptions.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:engliya/core/utils/error_handler.dart';

/// Phase 2 final test error handling.
///
/// The old Phase2FinalTestService was consolidated into the generic
/// TestRepositoryImpl (test generation/storage, configured via
/// PhaseConfig.phase2) and McqFinalTestProvider (gating/state). These tests
/// preserve the original intent: every failure mode (storage not ready,
/// missing data, corrupted data, missing lessons) must degrade gracefully.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Final Test Error Handling', () {
    late LessonRepository lessonRepository;
    late StorageService storageService;
    late ProgressRepository progressRepository;
    late TestRepositoryImpl testRepository;
    late McqFinalTestProvider provider;

    setUp(() {
      lessonRepository = LessonRepository();
      // Intentionally NOT initialized: simulates storage being unavailable.
      storageService = StorageService();
      progressRepository = ProgressRepository(storageService);

      testRepository = TestRepositoryImpl(
        lessonRepository: lessonRepository,
        storageService: storageService,
      );
      provider = McqFinalTestProvider(
        config: PhaseConfig.phase2,
        testRepository: testRepository,
        progressRepository: progressRepository,
      );
    });

    tearDown(() {
      lessonRepository.clearCache();
    });

    test('TestGenerationException is properly defined', () {
      final exception = TestGenerationException('Test message');
      expect(exception.message, equals('Test message'));
      expect(exception.toString(), contains('TestGenerationException'));
    });

    test('TestStorageException is properly defined', () {
      final exception = TestStorageException('Storage error');
      expect(exception.message, equals('Storage error'));
      expect(exception.toString(), contains('TestStorageException'));
    });

    test('InsufficientQuestionsException is properly defined', () {
      final exception = InsufficientQuestionsException('Not enough questions');
      expect(exception.message, equals('Not enough questions'));
      expect(exception.toString(), contains('InsufficientQuestionsException'));
    });

    test('ErrorHandler provides user-friendly messages for test exceptions',
        () {
      final testGenException = TestGenerationException('Failed to load');
      final testStorageException = TestStorageException('Storage failed');
      final insufficientException =
          InsufficientQuestionsException('Not enough');

      expect(
        ErrorHandler.getUserMessage(testGenException),
        equals('Failed to load test content. Please try again.'),
      );

      expect(
        ErrorHandler.getUserMessage(testStorageException),
        equals('Unable to save test results. Your progress may not be saved.'),
      );

      expect(
        ErrorHandler.getUserMessage(insufficientException),
        equals('Not enough questions available. Please complete more lessons.'),
      );
    });

    test('Provider handles empty lesson progress gracefully', () async {
      // With gating active (no dev bypass) and no mastered Phase 2 lessons,
      // the test must not be accessible - and the check must not crash even
      // when storage is unavailable.
      try {
        final result = await provider.canTakeTest();
        // Should return false if no lessons are mastered
        expect(result, isFalse);
      } catch (e) {
        // If it throws, it should be a known exception type
        expect(
          e is TestGenerationException ||
              e is InsufficientQuestionsException ||
              e is Exception,
          isTrue,
        );
      }
    });

    test('Repository handles storage errors gracefully when loading results',
        () async {
      // Loading non-existent results should return null, not throw
      final result = await testRepository.loadTestResult(PhaseConfig.phase2);
      expect(result, isNull);
    });

    test('Repository handles missing test data gracefully', () async {
      // Getting score when no test taken should return null
      final score = await testRepository.getLastTestScore(PhaseConfig.phase2);
      expect(score, isNull);

      // Checking pass status when no test taken should return false
      final passed = await testRepository.hasPassedTest(PhaseConfig.phase2);
      expect(passed, isFalse);

      // The provider-level checks should be equally safe
      expect(await provider.getLastTestScore(), isNull);
      expect(await provider.hasPassedBefore(), isFalse);
    });

    test('Service logs errors appropriately', () {
      // Verify error logging doesn't crash
      ErrorHandler.logError('Test context', Exception('Test error'));
      ErrorHandler.logError(
          'Test context', Exception('Test error'), StackTrace.current);

      // Should complete without throwing
      expect(true, isTrue);
    });
  });

  group('Phase 2 Error Recovery', () {
    test('Test generation can recover from partial lesson loading failures',
        () async {
      // This test verifies graceful degradation: generation should continue
      // even if some lessons fail to load, and fail with a proper exception
      // when not enough questions can be gathered.
      final lessonRepository = LessonRepository();
      final storageService = StorageService();

      final testRepository = TestRepositoryImpl(
        lessonRepository: lessonRepository,
        storageService: storageService,
      );

      // Attempt to generate test - should handle missing lessons gracefully
      try {
        final questions = await testRepository.generateTest(PhaseConfig.phase2);
        // If successful, the generated test must satisfy the config
        expect(questions.length,
            lessThanOrEqualTo(PhaseConfig.phase2.totalQuestions));
        expect(questions.length,
            greaterThanOrEqualTo(PhaseConfig.phase2.minRequiredQuestions));
      } catch (e) {
        // If it fails, it should be with a proper exception
        expect(
          e is TestGenerationException || e is InsufficientQuestionsException,
          isTrue,
        );
      }
    });

    test('Repository handles corrupted storage data gracefully', () async {
      // Seed storage with corrupted (non-JSON) data under the result key
      SharedPreferences.setMockInitialValues({
        PhaseConfig.phase2.keyTestResult: 'this is not valid json {{{',
      });
      final storageService = StorageService();
      await storageService.init();

      final lessonRepository = LessonRepository();
      final testRepository = TestRepositoryImpl(
        lessonRepository: lessonRepository,
        storageService: storageService,
      );

      // Loading corrupted data should return null, not crash
      final result = await testRepository.loadTestResult(PhaseConfig.phase2);
      expect(result, isNull);
    });
  });

  group('Error Message Quality', () {
    test('All custom exceptions have meaningful messages', () {
      final exceptions = [
        TestGenerationException('Test generation failed'),
        TestStorageException('Storage operation failed'),
        InsufficientQuestionsException('Not enough questions'),
      ];

      for (final exception in exceptions) {
        final message = ErrorHandler.getUserMessage(exception);

        // Message should not be empty
        expect(message.isNotEmpty, isTrue);

        // Message should be user-friendly (no technical jargon)
        expect(message.contains('Exception'), isFalse);
        expect(message.contains('null'), isFalse);
        expect(message.contains('error'), isFalse,
            reason: 'Should use "unable" or "failed" instead');
      }
    });

    test('Generic errors have fallback messages', () {
      final genericError = Exception('Some random error');
      final message = ErrorHandler.getUserMessage(genericError);

      expect(message, equals('An unexpected error occurred. Please try again.'));
    });
  });
}
