import 'dart:math';
import '../data/models/phase2_final_test_question.dart';
import '../data/models/phase2_test_result.dart';
import '../data/models/unit_performance.dart';
import '../data/models/incorrect_answer.dart';
import '../data/models/lesson.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../../../services/local_storage/storage_service.dart';
import 'test_exceptions.dart';

/// Service for managing Phase 2 Final Test operations
/// Handles test generation, answer validation, result calculation, and persistence
class Phase2FinalTestService {
  final LessonRepository _lessonRepository;
  final StorageService _storageService;
  final ProgressRepository _progressRepository;

  // Storage keys
  static const String _keyTestPassed = 'phase2_final_test_passed';
  static const String _keyTestScore = 'phase2_final_test_score';
  static const String _keyTestDate = 'phase2_final_test_taken_at';
  static const String _keyTestResult = 'phase2_final_test_result';
  static const String _keyPhase3Unlocked = 'phase3_unlocked';

  // Question distribution by unit (5-6-5-5-4 = 25 total)
  static const Map<String, int> _unitDistribution = {
    'unit7': 5,   // Time & Place Prepositions
    'unit8': 6,   // Continuous Tenses
    'unit9': 5,   // Perfect Tenses
    'unit10': 5,  // Questions & Negatives
    'unit11': 4,  // Advanced Pronouns, Adjectives & Adverbs
  };

  // Unit names for display
  static const Map<String, String> _unitNames = {
    'unit7': 'Time & Place',
    'unit8': 'Continuous Tenses',
    'unit9': 'Perfect Tenses',
    'unit10': 'Questions/Neg',
    'unit11': 'Adj/Adv/Pronouns',
  };

  // Lesson-to-unit mapping for all Phase 2 lessons
  static const Map<String, String> _lessonToUnit = {
    // Unit 7 - Time & Place Language
    'phase2_lesson7_1': 'unit7',
    'phase2_lesson7_2': 'unit7',
    'phase2_lesson7_3': 'unit7',
    
    // Unit 8 - Continuous Tenses
    'phase2_lesson8_1': 'unit8',
    'phase2_lesson8_2': 'unit8',
    'phase2_lesson8_3': 'unit8',
    'phase2_lesson8_4': 'unit8',
    
    // Unit 9 - Perfect & Perfect Continuous
    'phase2_lesson9_1': 'unit9',
    'phase2_lesson9_2': 'unit9',
    'phase2_lesson9_3': 'unit9',
    'phase2_lesson9_4': 'unit9',
    'phase2_lesson9_5': 'unit9',
    
    // Unit 10 - Questions & Negatives
    'phase2_lesson10_1': 'unit10',
    'phase2_lesson10_2': 'unit10',
    'phase2_lesson10_3': 'unit10',
    'phase2_lesson10_4': 'unit10',
    'phase2_lesson10_5': 'unit10',
    
    // Unit 11 - Advanced Pronouns, Adjectives & Adverbs
    'phase2_lesson11_1': 'unit11',
    'phase2_lesson11_2': 'unit11',
    'phase2_lesson11_3': 'unit11',
    'phase2_lesson11_4': 'unit11',
    'phase2_lesson11_5': 'unit11',
  };

  static const int _passingScore = 20;
  static const int _totalQuestions = 25;

  Phase2FinalTestService({
    required LessonRepository lessonRepository,
    required StorageService storageService,
    required ProgressRepository progressRepository,
  })  : _lessonRepository = lessonRepository,
        _storageService = storageService,
        _progressRepository = progressRepository;

  /// Generate a randomized test with 25 questions
  /// Distribution: Unit7(5), Unit8(6), Unit9(5), Unit10(5), Unit11(4)
  /// Questions are randomly selected from practiceQuestions and masteryQuestions
  /// Returns shuffled list of Phase2FinalTestQuestion objects
  /// 
  /// Throws:
  /// - [TestGenerationException] if insufficient questions are available
  /// - [LessonLoadException] if lesson files cannot be loaded
  Future<List<Phase2FinalTestQuestion>> generateTest() async {
    try {
      final questionsByUnit = <String, List<Phase2FinalTestQuestion>>{};
      final failedUnits = <String>[];

      // Load questions for each unit according to distribution
      for (final entry in _unitDistribution.entries) {
        try {
          final unitQuestions = await _loadUnitQuestions(
            entry.key,
            entry.value,
          );
          
          if (unitQuestions.isEmpty) {
            print('Warning: No questions loaded for ${entry.key}');
            failedUnits.add(entry.key);
          } else {
            questionsByUnit[entry.key] = unitQuestions;
            print('Loaded ${unitQuestions.length} questions for ${entry.key}');
          }
        } catch (e) {
          print('Error: Failed to load ${entry.key}: $e');
          failedUnits.add(entry.key);
          // Continue with other units to maximize question availability
        }
      }

      // Log failed units for debugging
      if (failedUnits.isNotEmpty) {
        print('Warning: Failed to load questions from units: ${failedUnits.join(", ")}');
      }

      // Combine all questions
      final allQuestions = questionsByUnit.values
          .expand((list) => list)
          .toList();

      // Ensure we have enough questions (minimum 20 out of 25)
      if (allQuestions.isEmpty) {
        throw TestGenerationException(
          'No questions could be loaded. Please check your lesson files and try again.',
        );
      }
      
      if (allQuestions.length < 20) {
        throw InsufficientQuestionsException(
          'Only ${allQuestions.length} questions available. At least 20 questions are required. Please complete more Phase 2 lessons.',
        );
      }

      // Log successful generation
      print('Successfully generated test with ${allQuestions.length} questions');

      // Shuffle the final list for randomization
      allQuestions.shuffle(Random());

      return allQuestions;
    } catch (e) {
      // Preserve specific exception types
      if (e is TestGenerationException || e is InsufficientQuestionsException) {
        rethrow;
      }
      
      // Wrap unexpected errors
      print('Unexpected error during test generation: $e');
      throw TestGenerationException('Failed to generate test. Please try again later.');
    }
  }

  /// Load questions from all lessons in a specific unit
  /// Randomly selects the required count of questions
  /// 
  /// Gracefully handles individual lesson failures by continuing with other lessons
  /// Returns as many questions as possible, up to the requested count
  Future<List<Phase2FinalTestQuestion>> _loadUnitQuestions(
    String unitId,
    int count,
  ) async {
    try {
      // Get all lesson IDs for this unit
      final lessonIds = _lessonToUnit.entries
          .where((entry) => entry.value == unitId)
          .map((entry) => entry.key)
          .toList();

      if (lessonIds.isEmpty) {
        print('Warning: No lessons mapped to unit $unitId');
        return [];
      }

      // Collect all questions from unit's lessons
      final allUnitQuestions = <Phase2FinalTestQuestion>[];
      int successfulLessons = 0;
      int failedLessons = 0;

      for (final lessonId in lessonIds) {
        try {
          final lesson = await _lessonRepository.loadLesson(lessonId);
          final questions = _extractQuestionsFromLesson(lesson, unitId);
          
          if (questions.isNotEmpty) {
            allUnitQuestions.addAll(questions);
            successfulLessons++;
          } else {
            print('Warning: No questions extracted from lesson $lessonId');
          }
        } catch (e) {
          print('Error: Failed to load lesson $lessonId: $e');
          failedLessons++;
          // Continue with other lessons to maximize question availability
        }
      }

      // Log loading summary
      print('Unit $unitId: Loaded $successfulLessons lessons, failed $failedLessons lessons, total ${allUnitQuestions.length} questions');

      // Check if we have any questions
      if (allUnitQuestions.isEmpty) {
        print('Warning: No questions found for unit $unitId after processing ${lessonIds.length} lessons');
        return [];
      }

      // Shuffle and select required count
      allUnitQuestions.shuffle(Random());
      
      // Take up to 'count' questions, or all available if less
      final selectedCount = allUnitQuestions.length < count 
          ? allUnitQuestions.length 
          : count;
      
      if (selectedCount < count) {
        print('Warning: Unit $unitId has only $selectedCount questions available, needed $count');
      }

      return allUnitQuestions.take(selectedCount).toList();
    } catch (e) {
      print('Error: Failed to load questions for unit $unitId: $e');
      return []; // Return empty list to allow other units to load
    }
  }

  /// Extract questions from lesson JSON
  /// Combines practiceQuestions and masteryQuestions
  /// Tags each question with unitId for result breakdown
  List<Phase2FinalTestQuestion> _extractQuestionsFromLesson(
    Lesson lesson,
    String unitId,
  ) {
    final questions = <Phase2FinalTestQuestion>[];

    // Extract from practice questions
    for (final quizQuestion in lesson.practiceQuestions) {
      try {
        final question = Phase2FinalTestQuestion.fromLessonQuestion(
          quizQuestion.toJson(),
          lesson.id,
          lesson.title,
          unitId,
        );
        questions.add(question);
      } catch (e) {
        print('Warning: Failed to parse practice question from ${lesson.id}: $e');
      }
    }

    // Extract from mastery questions
    for (final quizQuestion in lesson.masteryQuestions) {
      try {
        final question = Phase2FinalTestQuestion.fromLessonQuestion(
          quizQuestion.toJson(),
          lesson.id,
          lesson.title,
          unitId,
        );
        questions.add(question);
      } catch (e) {
        print('Warning: Failed to parse mastery question from ${lesson.id}: $e');
      }
    }

    return questions;
  }

  /// Validate an answer and return if correct
  bool validateAnswer(Phase2FinalTestQuestion question, int selectedIndex) {
    return selectedIndex == question.correctIndex;
  }

  /// Calculate test result from answers with unit breakdown
  /// Computes score, accuracy, pass/fail status, and per-unit performance
  Phase2TestResult calculateResult(
    List<Phase2FinalTestQuestion> questions,
    List<int?> selectedAnswers,
  ) {
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    final incorrectQuestionDetails = <IncorrectAnswer>[];

    // Calculate overall score and collect incorrect answers
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedIndex = selectedAnswers[i];

      if (selectedIndex != null && selectedIndex == question.correctIndex) {
        correctAnswers++;
      } else {
        incorrectAnswers++;
        
        // Create incorrect answer detail
        final incorrectAnswer = IncorrectAnswer(
          question: question,
          selectedIndex: selectedIndex ?? -1,
          selectedAnswer: selectedIndex != null && selectedIndex >= 0 && selectedIndex < question.options.length
              ? question.options[selectedIndex]
              : 'No answer selected',
          correctAnswer: question.options[question.correctIndex],
        );
        incorrectQuestionDetails.add(incorrectAnswer);
      }
    }

    // Calculate unit breakdown
    final unitBreakdown = <String, UnitPerformance>{};
    for (final unitId in _unitDistribution.keys) {
      final unitPerformance = _calculateUnitPerformance(
        unitId,
        questions,
        selectedAnswers,
      );
      unitBreakdown[unitId] = unitPerformance;
    }

    // Calculate overall accuracy
    final accuracy = (correctAnswers / questions.length) * 100;

    // Determine pass/fail
    final passed = correctAnswers >= _passingScore;

    return Phase2TestResult(
      totalQuestions: questions.length,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      accuracy: accuracy,
      passed: passed,
      completedAt: DateTime.now(),
      unitBreakdown: unitBreakdown,
      incorrectQuestionDetails: incorrectQuestionDetails,
    );
  }

  /// Calculate performance for a specific unit
  UnitPerformance _calculateUnitPerformance(
    String unitId,
    List<Phase2FinalTestQuestion> questions,
    List<int?> selectedAnswers,
  ) {
    // Filter questions for this unit
    final unitQuestions = <int>[];
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].unitId == unitId) {
        unitQuestions.add(i);
      }
    }

    // Count correct answers for this unit
    int correctAnswers = 0;
    for (final index in unitQuestions) {
      final question = questions[index];
      final selectedIndex = selectedAnswers[index];
      
      if (selectedIndex != null && selectedIndex == question.correctIndex) {
        correctAnswers++;
      }
    }

    final unitName = _unitNames[unitId] ?? unitId;

    return UnitPerformance(
      unitId: unitId,
      unitName: unitName,
      totalQuestions: unitQuestions.length,
      correctAnswers: correctAnswers,
    );
  }

  /// Save test result to local storage
  /// Unlocks Phase 3 if test is passed
  /// 
  /// Uses a fallback strategy: attempts to save all data, but continues
  /// even if some operations fail to ensure critical data is saved
  Future<void> saveTestResult(Phase2TestResult result) async {
    final errors = <String>[];
    
    try {
      // Save test passed status (critical)
      try {
        await _storageService.setBool(_keyTestPassed, result.passed);
      } catch (e) {
        errors.add('passed status');
        print('Error: Failed to save test passed status: $e');
      }

      // Save test score (critical)
      try {
        await _storageService.setInt(_keyTestScore, result.correctAnswers);
      } catch (e) {
        errors.add('score');
        print('Error: Failed to save test score: $e');
      }

      // Save test date (non-critical)
      try {
        await _storageService.setString(
          _keyTestDate,
          result.completedAt.toIso8601String(),
        );
      } catch (e) {
        errors.add('date');
        print('Warning: Failed to save test date: $e');
      }

      // Save full test result as JSON (non-critical but useful)
      try {
        await _storageService.setJson(_keyTestResult, result.toJson());
      } catch (e) {
        errors.add('detailed results');
        print('Warning: Failed to save full test result: $e');
      }

      // Unlock Phase 3 if test is passed (critical)
      if (result.passed) {
        try {
          await _storageService.setBool(_keyPhase3Unlocked, true);
          print('Phase 3 unlocked successfully');
        } catch (e) {
          errors.add('Phase 3 unlock');
          print('Error: Failed to unlock Phase 3: $e');
        }
      }

      // If critical operations failed, throw exception
      if (errors.isNotEmpty) {
        final failedItems = errors.join(', ');
        throw TestStorageException(
          'Some data could not be saved: $failedItems. Your results may not be fully preserved.',
        );
      }
      
      print('Test result saved successfully');
    } catch (e) {
      if (e is TestStorageException) {
        rethrow;
      }
      print('Error: Unexpected error saving test result: $e');
      throw TestStorageException('Failed to save test result. Please try again.');
    }
  }

  /// Load previous test result from storage
  /// Returns null if no test result exists or if loading fails
  /// 
  /// Gracefully handles corrupted data by returning null
  Future<Phase2TestResult?> loadTestResult() async {
    try {
      final resultJson = _storageService.getJson(_keyTestResult);
      
      if (resultJson == null) {
        print('No previous test result found in storage');
        return null;
      }

      // Validate JSON structure before parsing
      if (resultJson is! Map<String, dynamic>) {
        print('Warning: Invalid test result format in storage');
        return null;
      }

      final result = Phase2TestResult.fromJson(resultJson);
      print('Loaded previous test result: ${result.correctAnswers}/${result.totalQuestions}');
      return result;
    } catch (e) {
      print('Error: Failed to load test result: $e');
      // Return null instead of throwing to allow app to continue
      return null;
    }
  }

  /// Check if student has passed the test
  Future<bool> hasPassedTest() async {
    try {
      return _storageService.getBool(_keyTestPassed) ?? false;
    } catch (e) {
      print('Warning: Failed to check test pass status: $e');
      return false;
    }
  }

  /// Get the last test score
  /// Returns null if no test has been taken
  Future<int?> getLastTestScore() async {
    try {
      return _storageService.getInt(_keyTestScore);
    } catch (e) {
      print('Warning: Failed to get last test score: $e');
      return null;
    }
  }

  /// Check if all Phase 2 lessons are mastered
  /// Required before taking the final test
  /// 
  /// Returns false on error to prevent test access when mastery cannot be verified
  Future<bool> areAllPhase2LessonsMastered() async {
    try {
      final allProgress = await _progressRepository.loadAllProgress();

      // Get all Phase 2 lesson IDs
      final phase2LessonIds = _lessonToUnit.keys.toList();
      
      if (phase2LessonIds.isEmpty) {
        print('Warning: No Phase 2 lessons found in mapping');
        return false;
      }

      int masteredCount = 0;
      int totalCount = phase2LessonIds.length;

      // Check if all Phase 2 lessons are mastered
      for (final lessonId in phase2LessonIds) {
        final progress = allProgress[lessonId];
        
        // If lesson has no progress or is not mastered, return false
        if (progress == null || !progress.isMastered) {
          print('Lesson $lessonId is not mastered');
          return false;
        }
        
        masteredCount++;
      }

      print('All Phase 2 lessons mastered: $masteredCount/$totalCount');
      return true;
    } catch (e) {
      print('Error: Failed to check Phase 2 lesson mastery: $e');
      // Return false to prevent test access when verification fails
      return false;
    }
  }

  /// Clear test data (for retesting)
  /// Does not clear Phase 3 unlock status to preserve progress
  /// 
  /// Uses best-effort approach: attempts to clear all data but doesn't fail
  /// if some operations are unsuccessful
  Future<void> clearTestData() async {
    final errors = <String>[];
    
    try {
      // Attempt to remove each key individually
      try {
        await _storageService.remove(_keyTestPassed);
      } catch (e) {
        errors.add('passed status');
        print('Warning: Failed to clear test passed status: $e');
      }
      
      try {
        await _storageService.remove(_keyTestScore);
      } catch (e) {
        errors.add('score');
        print('Warning: Failed to clear test score: $e');
      }
      
      try {
        await _storageService.remove(_keyTestDate);
      } catch (e) {
        errors.add('date');
        print('Warning: Failed to clear test date: $e');
      }
      
      try {
        await _storageService.remove(_keyTestResult);
      } catch (e) {
        errors.add('results');
        print('Warning: Failed to clear test result: $e');
      }
      
      // Note: We don't clear _keyPhase3Unlocked to preserve unlock status
      
      if (errors.isEmpty) {
        print('Test data cleared successfully');
      } else {
        print('Test data partially cleared. Failed to clear: ${errors.join(", ")}');
        throw TestStorageException(
          'Could not fully clear test data: ${errors.join(", ")}',
        );
      }
    } catch (e) {
      if (e is TestStorageException) {
        rethrow;
      }
      print('Error: Unexpected error clearing test data: $e');
      throw TestStorageException('Failed to clear test data. Please try again.');
    }
  }
}


