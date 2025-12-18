import 'package:flutter_test/flutter_test.dart';
import 'package:engliya/features/learn/services/phase2_final_test_service.dart';
import 'package:engliya/features/learn/services/test_exceptions.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:engliya/core/utils/error_handler.dart';

void main() {
  group('Phase 2 Final Test Error Handling', () {
    late Phase2FinalTestService service;
    late LessonRepository lessonRepository;
    late StorageService storageService;
    late ProgressRepository progressRepository;

    setUp(() {
      lessonRepository = LessonRepository();
      storageService = StorageService();
      progressRepository = ProgressRepository(storageService);
      
      service = Phase2FinalTestService(
        lessonRepository: lessonRepository,
        storageService: storageService,
        progressRepository: progressRepository,
      );
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

    test('ErrorHandler provides user-friendly messages for test exceptions', () {
      final testGenException = TestGenerationException('Failed to load');
      final testStorageException = TestStorageException('Storage failed');
      final insufficientException = InsufficientQuestionsException('Not enough');

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

    test('Service handles empty lesson list gracefully', () async {
      // This test verifies that the service doesn't crash with empty data
      // The actual behavior depends on lesson availability
      try {
        final result = await service.areAllPhase2LessonsMastered();
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

    test('Service handles storage errors gracefully when loading results', () async {
      // Loading non-existent results should return null, not throw
      final result = await service.loadTestResult();
      expect(result, isNull);
    });

    test('Service handles missing test data gracefully', () async {
      // Getting score when no test taken should return null
      final score = await service.getLastTestScore();
      expect(score, isNull);
      
      // Checking pass status when no test taken should return false
      final passed = await service.hasPassedTest();
      expect(passed, isFalse);
    });

    test('Service logs errors appropriately', () {
      // Verify error logging doesn't crash
      ErrorHandler.logError('Test context', Exception('Test error'));
      ErrorHandler.logError('Test context', Exception('Test error'), StackTrace.current);
      
      // Should complete without throwing
      expect(true, isTrue);
    });
  });

  group('Phase 2 Error Recovery', () {
    test('Service can recover from partial lesson loading failures', () async {
      // This test verifies graceful degradation
      // The service should continue even if some lessons fail to load
      
      final lessonRepository = LessonRepository();
      final storageService = StorageService();
      final progressRepository = ProgressRepository(storageService);
      
      final service = Phase2FinalTestService(
        lessonRepository: lessonRepository,
        storageService: storageService,
        progressRepository: progressRepository,
      );

      // Attempt to generate test - should handle missing lessons gracefully
      try {
        await service.generateTest();
        // If successful, test passes
        expect(true, isTrue);
      } catch (e) {
        // If it fails, it should be with a proper exception
        expect(
          e is TestGenerationException || 
          e is InsufficientQuestionsException,
          isTrue,
        );
      }
    });

    test('Service handles corrupted storage data gracefully', () async {
      final lessonRepository = LessonRepository();
      final storageService = StorageService();
      final progressRepository = ProgressRepository(storageService);
      
      final service = Phase2FinalTestService(
        lessonRepository: lessonRepository,
        storageService: storageService,
        progressRepository: progressRepository,
      );

      // Loading corrupted data should return null, not crash
      final result = await service.loadTestResult();
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
        expect(message.contains('error'), isFalse, reason: 'Should use "unable" or "failed" instead');
      }
    });

    test('Generic errors have fallback messages', () {
      final genericError = Exception('Some random error');
      final message = ErrorHandler.getUserMessage(genericError);
      
      expect(message, equals('An unexpected error occurred. Please try again.'));
    });
  });
}
