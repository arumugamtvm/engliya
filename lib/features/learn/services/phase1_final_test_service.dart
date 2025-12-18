import 'dart:math';
import '../data/models/final_test_question.dart';
import '../data/models/test_result.dart';
import '../data/models/incorrect_answer.dart';
import '../data/models/lesson.dart';
import '../data/repositories/lesson_repository.dart';
import '../../../services/local_storage/storage_service.dart';

/// Service for managing Phase 1 Final Test operations
/// Handles test generation, answer validation, result calculation, and persistence
class Phase1FinalTestService {
  final LessonRepository _lessonRepository;
  final StorageService _storageService;

  // Storage keys for test data persistence
  static const String _keyTestPassed = 'phase1_final_test_passed';
  static const String _keyTestScore = 'phase1_final_test_score';
  static const String _keyTestDate = 'phase1_final_test_date';
  static const String _keyTestResult = 'phase1_final_test_result';

  // Question distribution map: lesson ID -> number of questions
  static const Map<String, int> _questionDistribution = {
    'phase1_lesson1': 4, // Pronouns
    'phase1_lesson2': 4, // Be Verb
    'phase1_lesson3': 4, // Nouns & Articles
    'phase1_lesson4': 3, // Object Pronouns
    'phase1_lesson5': 3, // Action Verbs
    'phase1_lesson6': 2, // Simple Present
  };

  // Passing threshold
  static const int _passingScore = 16;
  static const int _totalQuestions = 20;

  Phase1FinalTestService({
    required LessonRepository lessonRepository,
    required StorageService storageService,
  })  : _lessonRepository = lessonRepository,
        _storageService = storageService;


  /// Generate a randomized test with 20 questions from all Phase 1 lessons
  /// Distribution: L1(4), L2(4), L3(4), L4(3), L5(3), L6(2)
  /// Returns a shuffled list of FinalTestQuestion objects
  /// Throws [TestGenerationException] if test cannot be generated
  /// Throws [InsufficientQuestionsException] if not enough questions available
  Future<List<FinalTestQuestion>> generateTest() async {
    final questions = <FinalTestQuestion>[];
    final failedLessons = <String>[];
    final criticalLessons = ['phase1_lesson1', 'phase1_lesson2'];

    try {
      // Load questions from each lesson according to distribution
      for (final entry in _questionDistribution.entries) {
        try {
          final lessonQuestions = await _loadLessonQuestionsWithRetry(
            entry.key,
            entry.value,
            maxRetries: 2,
          );
          
          if (lessonQuestions.isEmpty) {
            print('Warning: No questions loaded from ${entry.key}');
            failedLessons.add(entry.key);
            
            // If critical lesson fails, throw immediately
            if (criticalLessons.contains(entry.key)) {
              throw TestGenerationException(
                'Critical lesson ${entry.key} failed to load. Cannot generate test.',
              );
            }
          } else {
            questions.addAll(lessonQuestions);
            print('Successfully loaded ${lessonQuestions.length} questions from ${entry.key}');
          }
        } catch (e) {
          print('Error loading ${entry.key}: $e');
          failedLessons.add(entry.key);
          
          // If critical lessons (1 or 2) fail, rethrow
          if (criticalLessons.contains(entry.key)) {
            if (e is TestGenerationException) {
              rethrow;
            }
            throw TestGenerationException(
              'Failed to load critical lesson ${entry.key}: $e',
            );
          }
        }
      }

      // Log failed lessons
      if (failedLessons.isNotEmpty) {
        print('Failed to load lessons: ${failedLessons.join(", ")}');
      }

      // Validate we have enough questions (minimum 15 out of 20)
      if (questions.length < 15) {
        throw InsufficientQuestionsException(
          'Not enough questions available: ${questions.length}/$_totalQuestions. '
          'Failed lessons: ${failedLessons.join(", ")}',
        );
      }

      // Warn if we don't have exactly 20 questions
      if (questions.length < _totalQuestions) {
        print('Warning: Generated test with ${questions.length} questions instead of $_totalQuestions');
      }

      // Shuffle the questions to randomize order
      questions.shuffle(Random());

      print('Successfully generated test with ${questions.length} questions');
      return questions;
    } catch (e) {
      // Log detailed error information
      print('Test generation failed: $e');
      print('Questions loaded: ${questions.length}');
      print('Failed lessons: ${failedLessons.join(", ")}');
      
      if (e is TestGenerationException || e is InsufficientQuestionsException) {
        rethrow;
      }
      throw TestGenerationException('Failed to generate test: $e');
    }
  }

  /// Load questions from a specific lesson with retry mechanism
  /// Retries up to [maxRetries] times on failure
  Future<List<FinalTestQuestion>> _loadLessonQuestionsWithRetry(
    String lessonId,
    int count, {
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    Exception? lastError;

    while (attempts <= maxRetries) {
      try {
        return await _loadLessonQuestions(lessonId, count);
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        attempts++;
        
        if (attempts <= maxRetries) {
          print('Retry attempt $attempts for $lessonId after error: $e');
          // Wait briefly before retrying
          await Future.delayed(Duration(milliseconds: 100 * attempts));
        }
      }
    }

    // All retries failed
    throw TestGenerationException(
      'Failed to load $lessonId after $maxRetries retries: $lastError',
    );
  }

  /// Load questions from a specific lesson
  /// Returns a list of randomly selected FinalTestQuestion objects
  /// Throws [TestGenerationException] if lesson cannot be loaded
  Future<List<FinalTestQuestion>> _loadLessonQuestions(
    String lessonId,
    int count,
  ) async {
    try {
      // Load the lesson from repository
      final lesson = await _lessonRepository.loadLesson(lessonId);

      // Extract and randomly select questions
      final questions = _extractQuestionsFromLesson(lesson, count);

      if (questions.isEmpty) {
        print('Warning: No questions extracted from $lessonId');
      }

      return questions;
    } on LessonLoadException catch (e) {
      // Specific handling for lesson loading errors
      throw TestGenerationException(
        'Failed to load lesson $lessonId: ${e.message}',
      );
    } catch (e) {
      // Generic error handling
      throw TestGenerationException(
        'Failed to load questions from $lessonId: $e',
      );
    }
  }

  /// Extract questions from lesson's practiceQuestions and masteryQuestions
  /// Randomly selects the specified count of questions
  /// Returns all available questions if count exceeds available questions
  List<FinalTestQuestion> _extractQuestionsFromLesson(
    Lesson lesson,
    int count,
  ) {
    try {
      // Combine practice and mastery questions
      final allQuestions = <FinalTestQuestion>[];

      // Convert practice questions to FinalTestQuestion
      if (lesson.practiceQuestions.isNotEmpty) {
        for (final question in lesson.practiceQuestions) {
          try {
            allQuestions.add(
              FinalTestQuestion.fromLessonQuestion(
                question.toJson(),
                lesson.id,
                lesson.title,
              ),
            );
          } catch (e) {
            print('Warning: Failed to convert practice question in ${lesson.id}: $e');
            // Continue with other questions
          }
        }
      }

      // Convert mastery questions to FinalTestQuestion
      if (lesson.masteryQuestions.isNotEmpty) {
        for (final question in lesson.masteryQuestions) {
          try {
            allQuestions.add(
              FinalTestQuestion.fromLessonQuestion(
                question.toJson(),
                lesson.id,
                lesson.title,
              ),
            );
          } catch (e) {
            print('Warning: Failed to convert mastery question in ${lesson.id}: $e');
            // Continue with other questions
          }
        }
      }

      // Check if we have any questions at all
      if (allQuestions.isEmpty) {
        print('Error: Lesson ${lesson.id} has no valid questions');
        return [];
      }

      // Check if we have enough questions
      if (allQuestions.length < count) {
        print(
          'Warning: Lesson ${lesson.id} has only ${allQuestions.length} questions, '
          'but $count were requested. Using all available questions.',
        );
        return allQuestions;
      }

      // Shuffle and select the required count
      allQuestions.shuffle(Random());
      return allQuestions.take(count).toList();
    } catch (e) {
      print('Error extracting questions from ${lesson.id}: $e');
      return [];
    }
  }


  /// Validate if the selected answer is correct
  /// Returns true if selectedIndex matches the question's correctIndex
  /// Handles edge cases and validates input bounds
  bool validateAnswer(FinalTestQuestion question, int selectedIndex) {
    // Validate inputs
    if (selectedIndex < 0) {
      print('Warning: Negative answer index: $selectedIndex');
      return false;
    }

    if (selectedIndex >= question.options.length) {
      print('Warning: Answer index $selectedIndex out of bounds (max: ${question.options.length - 1})');
      return false;
    }

    if (question.correctIndex < 0 || question.correctIndex >= question.options.length) {
      print('Error: Invalid correct index ${question.correctIndex} for question');
      return false;
    }

    return selectedIndex == question.correctIndex;
  }

  /// Calculate test result from questions and selected answers
  /// Computes score, accuracy, pass/fail status, and incorrect answer details
  /// Returns a TestResult object with all calculated data
  /// Validates input data and handles edge cases
  TestResult calculateResult(
    List<FinalTestQuestion> questions,
    List<int?> selectedAnswers,
  ) {
    // Validate inputs
    if (questions.isEmpty) {
      throw ArgumentError('Cannot calculate result: questions list is empty');
    }

    if (selectedAnswers.isEmpty) {
      throw ArgumentError('Cannot calculate result: selectedAnswers list is empty');
    }

    if (questions.length != selectedAnswers.length) {
      print('Warning: Question count (${questions.length}) does not match answer count (${selectedAnswers.length})');
    }

    int correctCount = 0;
    int incorrectCount = 0;
    final incorrectDetails = <IncorrectAnswer>[];

    // Validate each answer
    final minLength = questions.length < selectedAnswers.length 
        ? questions.length 
        : selectedAnswers.length;

    for (int i = 0; i < minLength; i++) {
      try {
        final question = questions[i];
        final selectedIndex = selectedAnswers[i];

        // Skip if no answer was selected (shouldn't happen in normal flow)
        if (selectedIndex == null) {
          incorrectCount++;
          print('Warning: No answer selected for question ${i + 1}');
          continue;
        }

        // Validate selected index is within bounds
        if (selectedIndex < 0 || selectedIndex >= question.options.length) {
          print('Warning: Invalid answer index $selectedIndex for question ${i + 1}');
          incorrectCount++;
          continue;
        }

        // Check if answer is correct
        if (validateAnswer(question, selectedIndex)) {
          correctCount++;
        } else {
          incorrectCount++;

          // Create incorrect answer detail for review
          try {
            incorrectDetails.add(
              IncorrectAnswer(
                question: question,
                selectedIndex: selectedIndex,
                selectedAnswer: question.options[selectedIndex],
                correctAnswer: question.options[question.correctIndex],
              ),
            );
          } catch (e) {
            print('Warning: Failed to create incorrect answer detail for question ${i + 1}: $e');
          }
        }
      } catch (e) {
        print('Error processing question ${i + 1}: $e');
        incorrectCount++;
      }
    }

    // Calculate accuracy percentage (handle division by zero)
    final accuracy = questions.isNotEmpty 
        ? (correctCount / questions.length) * 100 
        : 0.0;

    // Determine pass/fail status
    final passed = correctCount >= _passingScore;

    print('Test result calculated: $correctCount correct, $incorrectCount incorrect, ${accuracy.toStringAsFixed(1)}% accuracy');

    // Create and return test result
    return TestResult(
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      incorrectAnswers: incorrectCount,
      accuracy: accuracy,
      passed: passed,
      completedAt: DateTime.now(),
      incorrectQuestionDetails: incorrectDetails,
    );
  }


  /// Save test result to local storage
  /// Persists test passed status, score, date, and full result object
  /// Throws [TestStorageException] if critical data cannot be saved
  Future<void> saveTestResult(TestResult result) async {
    final savedKeys = <String>[];
    final failedKeys = <String>[];

    try {
      // Save pass/fail status (critical)
      try {
        await _storageService.setBool(_keyTestPassed, result.passed);
        savedKeys.add(_keyTestPassed);
      } catch (e) {
        print('Error saving test passed status: $e');
        failedKeys.add(_keyTestPassed);
      }

      // Save score (critical)
      try {
        await _storageService.setInt(_keyTestScore, result.correctAnswers);
        savedKeys.add(_keyTestScore);
      } catch (e) {
        print('Error saving test score: $e');
        failedKeys.add(_keyTestScore);
      }

      // Save completion date (non-critical)
      try {
        await _storageService.setString(
          _keyTestDate,
          result.completedAt.toIso8601String(),
        );
        savedKeys.add(_keyTestDate);
      } catch (e) {
        print('Warning: Failed to save test date: $e');
        // Non-critical, continue
      }

      // Save full result object as JSON (non-critical)
      try {
        await _storageService.setJson(_keyTestResult, result.toJson());
        savedKeys.add(_keyTestResult);
      } catch (e) {
        print('Warning: Failed to save full test result: $e');
        // Non-critical, continue
      }

      // If critical data failed to save, throw exception
      if (failedKeys.contains(_keyTestPassed) || failedKeys.contains(_keyTestScore)) {
        throw TestStorageException(
          'Failed to save critical test data. Saved: ${savedKeys.join(", ")}. '
          'Failed: ${failedKeys.join(", ")}',
        );
      }

      print('Test result saved successfully. Saved keys: ${savedKeys.join(", ")}');
    } catch (e) {
      if (e is TestStorageException) {
        rethrow;
      }
      throw TestStorageException('Failed to save test result: $e');
    }
  }

  /// Load previous test result from storage
  /// Returns TestResult object if found, null otherwise
  /// Falls back to reconstructing from individual keys if full result is unavailable
  Future<TestResult?> loadTestResult() async {
    try {
      // Try to load full result object first
      final resultJson = _storageService.getJson(_keyTestResult);

      if (resultJson != null) {
        try {
          return TestResult.fromJson(resultJson);
        } catch (e) {
          print('Warning: Failed to parse stored test result JSON: $e');
          // Fall through to reconstruction attempt
        }
      }

      // Fallback: Try to reconstruct from individual keys
      final passed = _storageService.getBool(_keyTestPassed);
      final score = _storageService.getInt(_keyTestScore);
      final dateStr = _storageService.getString(_keyTestDate);

      // If we have at least the score, reconstruct a basic result
      if (score != null) {
        print('Reconstructing test result from individual storage keys');
        
        final completedAt = dateStr != null
            ? DateTime.tryParse(dateStr) ?? DateTime.now()
            : DateTime.now();

        return TestResult(
          totalQuestions: _totalQuestions,
          correctAnswers: score,
          incorrectAnswers: _totalQuestions - score,
          accuracy: (score / _totalQuestions) * 100,
          passed: passed ?? (score >= _passingScore),
          completedAt: completedAt,
          incorrectQuestionDetails: [], // Cannot reconstruct details
        );
      }

      // No data available
      return null;
    } catch (e) {
      print('Error loading test result: $e');
      return null;
    }
  }

  /// Check if student has passed the test
  /// Returns true if test was passed, false otherwise
  Future<bool> hasPassedTest() async {
    try {
      final passed = _storageService.getBool(_keyTestPassed);
      return passed ?? false;
    } catch (e) {
      print('Warning: Failed to check test pass status: $e');
      return false;
    }
  }

  /// Get the last test score
  /// Returns score (0-20) if available, null otherwise
  Future<int?> getLastTestScore() async {
    try {
      return _storageService.getInt(_keyTestScore);
    } catch (e) {
      print('Warning: Failed to get last test score: $e');
      return null;
    }
  }

  /// Clear test data for retry functionality
  /// Removes all stored test-related data
  /// Continues even if some keys fail to delete
  Future<void> clearTestData() async {
    final clearedKeys = <String>[];
    final failedKeys = <String>[];

    // Try to remove each key individually
    final keysToRemove = [
      _keyTestPassed,
      _keyTestScore,
      _keyTestDate,
      _keyTestResult,
    ];

    for (final key in keysToRemove) {
      try {
        await _storageService.remove(key);
        clearedKeys.add(key);
      } catch (e) {
        print('Warning: Failed to remove $key: $e');
        failedKeys.add(key);
      }
    }

    print('Cleared test data. Success: ${clearedKeys.length}, Failed: ${failedKeys.length}');

    // Only throw if all keys failed to clear
    if (failedKeys.length == keysToRemove.length) {
      throw TestStorageException(
        'Failed to clear any test data. All ${keysToRemove.length} keys failed.',
      );
    }

    // Warn if some keys failed but continue
    if (failedKeys.isNotEmpty) {
      print('Warning: Some test data may remain. Failed keys: ${failedKeys.join(", ")}');
    }
  }
}

/// Custom exception for test generation errors
class TestGenerationException implements Exception {
  final String message;

  TestGenerationException(this.message);

  @override
  String toString() => 'TestGenerationException: $message';
}

/// Custom exception for test storage errors
class TestStorageException implements Exception {
  final String message;

  TestStorageException(this.message);

  @override
  String toString() => 'TestStorageException: $message';
}

/// Custom exception for insufficient questions
class InsufficientQuestionsException implements Exception {
  final String message;

  InsufficientQuestionsException(this.message);

  @override
  String toString() => 'InsufficientQuestionsException: $message';
}
