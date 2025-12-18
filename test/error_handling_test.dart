import 'package:flutter_test/flutter_test.dart';
import 'package:engliya/core/utils/error_handler.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/services/local_storage/storage_service.dart';

void main() {
  group('ErrorHandler', () {
    test('getUserMessage returns correct message for LessonLoadException', () {
      final error = LessonLoadException('Test error');
      final message = ErrorHandler.getUserMessage(error);
      expect(message, 'Unable to load lesson. Please restart the app.');
    });

    test('getUserMessage returns correct message for ProgressLoadException', () {
      final error = ProgressLoadException('Test error');
      final message = ErrorHandler.getUserMessage(error);
      expect(message, 'Unable to load your progress. Please try again.');
    });

    test('getUserMessage returns correct message for ProgressSaveException', () {
      final error = ProgressSaveException('Test error');
      final message = ErrorHandler.getUserMessage(error);
      expect(message, 'Progress not saved. Please try again.');
    });

    test('getUserMessage returns correct message for StorageException', () {
      final error = StorageException('Test error');
      final message = ErrorHandler.getUserMessage(error);
      expect(message, 'Storage error occurred. Please try again.');
    });

    test('getUserMessage returns correct message for TtsException', () {
      final error = TtsException('Test error');
      final message = ErrorHandler.getUserMessage(error);
      expect(message, 'Audio playback is currently unavailable.');
    });

    test('getUserMessage returns generic message for unknown error', () {
      final error = Exception('Unknown error');
      final message = ErrorHandler.getUserMessage(error);
      expect(message, 'An unexpected error occurred. Please try again.');
    });
  });

  group('Custom Exceptions', () {
    test('LessonLoadException has correct message', () {
      final exception = LessonLoadException('Test message');
      expect(exception.message, 'Test message');
      expect(exception.toString(), 'LessonLoadException: Test message');
    });

    test('ProgressLoadException has correct message', () {
      final exception = ProgressLoadException('Test message');
      expect(exception.message, 'Test message');
      expect(exception.toString(), 'ProgressLoadException: Test message');
    });

    test('ProgressSaveException has correct message', () {
      final exception = ProgressSaveException('Test message');
      expect(exception.message, 'Test message');
      expect(exception.toString(), 'ProgressSaveException: Test message');
    });

    test('StorageException has correct message', () {
      final exception = StorageException('Test message');
      expect(exception.message, 'Test message');
      expect(exception.toString(), 'StorageException: Test message');
    });

    test('TtsException has correct message', () {
      final exception = TtsException('Test message');
      expect(exception.message, 'Test message');
      expect(exception.toString(), 'TtsException: Test message');
    });
  });
}
