import 'dart:math';
import '../data/models/phase3_final_test_question.dart';
import '../data/models/phase3_test_result.dart';
import '../data/models/unit_performance.dart';
import '../data/models/incorrect_answer.dart';
import '../data/models/lesson.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../../../services/local_storage/storage_service.dart';
import 'test_exceptions.dart';

/// Service for managing Phase 3 Final Test operations
/// Handles test generation, answer validation, result calculation, and persistence
/// 
/// Phase 3 covers Units 12-17:
/// - Unit 12: Story Listening & Retelling (6 questions)
/// - Unit 13: Complex Sentences & Connectors (7 questions)
/// - Unit 14: Passive Voice (5 questions)
/// - Unit 15: Reported Speech (5 questions)
/// - Unit 16: Functional English (4 questions)
/// - Unit 17: Speaking & Writing Projects (3 questions)
class Phase3FinalTestService {
  final LessonRepository _lessonRepository;
  final StorageService _storageService;
  final ProgressRepository _progressRepository;

  // Storage keys for Phase 3 test data
  static const String _keyTestPassed = 'phase3_final_test_passed';
  static const String _keyTestScore = 'phase3_final_test_score';
  static const String _keyTestDate = 'phase3_final_test_taken_at';
  static const String _keyTestResult = 'phase3_final_test_result';
  static const String _keyPhase4Unlocked = 'phase4_unlocked';

  // Question distribution by unit (6-7-5-5-4-3 = 30 total)
  static const Map<String, int> _unitDistribution = {
    'unit12': 6,   // Story Listening & Retelling
    'unit13': 7,   // Complex Sentences & Connectors
    'unit14': 5,   // Passive Voice
    'unit15': 5,   // Reported Speech
    'unit16': 4,   // Functional English
    'unit17': 3,   // Speaking & Writing Projects
  };

  // Unit names for display
  static const Map<String, String> _unitNames = {
    'unit12': 'Stories & Retelling',
    'unit13': 'Connectors & Complex Sent.',
    'unit14': 'Passive Voice',
    'unit15': 'Reported Speech',
    'unit16': 'Functional English',
    'unit17': 'Projects & General Use',
  };

  // Lesson-to-unit mapping for all Phase 3 lessons
  static const Map<String, String> _lessonToUnit = {
    // Unit 12 - Story Listening & Retelling
    'phase3_lesson12_1': 'unit12',
    'phase3_lesson12_2': 'unit12',
    'phase3_lesson12_3': 'unit12',
    'phase3_lesson12_4': 'unit12',
    
    // Unit 13 - Complex Sentences & Connectors
    'phase3_lesson13_1': 'unit13',
    'phase3_lesson13_2': 'unit13',
    'phase3_lesson13_3': 'unit13',
    'phase3_lesson13_4': 'unit13',
    'phase3_lesson13_5': 'unit13',
    
    // Unit 14 - Passive Voice
    'phase3_lesson14_1': 'unit14',
    'phase3_lesson14_2': 'unit14',
    'phase3_lesson14_3': 'unit14',
    'phase3_lesson14_4': 'unit14',
    
    // Unit 15 - Reported Speech
    'phase3_lesson15_1': 'unit15',
    'phase3_lesson15_2': 'unit15',
    'phase3_lesson15_3': 'unit15',
    'phase3_lesson15_4': 'unit15',
    
    // Unit 16 - Functional English
    'phase3_lesson16_1': 'unit16',
    'phase3_lesson16_2': 'unit16',
    'phase3_lesson16_3': 'unit16',
    'phase3_lesson16_4': 'unit16',
    'phase3_lesson16_5': 'unit16',
    
    // Unit 17 - Speaking & Writing Projects
    'phase3_lesson17_1': 'unit17',
    'phase3_lesson17_2': 'unit17',
    'phase3_lesson17_3': 'unit17',
    'phase3_lesson17_4': 'unit17',
    'phase3_lesson17_5': 'unit17',
  };

  // Required lessons for test access (Units 12-16, Unit 17 is optional)
  static const List<String> _requiredLessonIds = [
    // Unit 12
    'phase3_lesson12_1', 'phase3_lesson12_2', 'phase3_lesson12_3', 'phase3_lesson12_4',
    // Unit 13
    'phase3_lesson13_1', 'phase3_lesson13_2', 'phase3_lesson13_3', 'phase3_lesson13_4', 'phase3_lesson13_5',
    // Unit 14
    'phase3_lesson14_1', 'phase3_lesson14_2', 'phase3_lesson14_3', 'phase3_lesson14_4',
    // Unit 15
    'phase3_lesson15_1', 'phase3_lesson15_2', 'phase3_lesson15_3', 'phase3_lesson15_4',
    // Unit 16
    'phase3_lesson16_1', 'phase3_lesson16_2', 'phase3_lesson16_3', 'phase3_lesson16_4', 'phase3_lesson16_5',
  ];

  static const int _passingScore = 24;
  static const int _totalQuestions = 30;

  Phase3FinalTestService({
    required LessonRepository lessonRepository,
    required StorageService storageService,
    required ProgressRepository progressRepository,
  })  : _lessonRepository = lessonRepository,
        _storageService = storageService,
        _progressRepository = progressRepository;


  /// Generate a randomized test with 30 questions
  /// Distribution: Unit12(6), Unit13(7), Unit14(5), Unit15(5), Unit16(4), Unit17(3)
  /// Questions are randomly selected from practiceQuestions and masteryQuestions
  /// Returns shuffled list of Phase3FinalTestQuestion objects
  /// 
  /// Throws:
  /// - [TestGenerationException] if insufficient questions are available
  /// - [LessonLoadException] if lesson files cannot be loaded
  Future<List<Phase3FinalTestQuestion>> generateTest() async {
    try {
      final questionsByUnit = <String, List<Phase3FinalTestQuestion>>{};
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

      // Ensure we have enough questions (minimum 24 out of 30)
      if (allQuestions.isEmpty) {
        throw TestGenerationException(
          'No questions could be loaded. Please check your lesson files and try again.',
        );
      }
      
      if (allQuestions.length < 24) {
        throw InsufficientQuestionsException(
          'Only ${allQuestions.length} questions available. At least 24 questions are required. Please complete more Phase 3 lessons.',
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
  Future<List<Phase3FinalTestQuestion>> _loadUnitQuestions(
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
      final allUnitQuestions = <Phase3FinalTestQuestion>[];
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
      // If insufficient, reuse available questions
      if (allUnitQuestions.length < count) {
        print('Warning: Unit $unitId has only ${allUnitQuestions.length} questions available, needed $count. Reusing questions.');
        // Reuse questions to fill the gap
        final reusedQuestions = <Phase3FinalTestQuestion>[];
        while (reusedQuestions.length < count) {
          for (final q in allUnitQuestions) {
            if (reusedQuestions.length >= count) break;
            reusedQuestions.add(q);
          }
        }
        return reusedQuestions;
      }

      return allUnitQuestions.take(count).toList();
    } catch (e) {
      print('Error: Failed to load questions for unit $unitId: $e');
      return []; // Return empty list to allow other units to load
    }
  }

  /// Extract questions from lesson JSON
  /// Combines practiceQuestions and masteryQuestions
  /// Tags each question with unitId for result breakdown
  List<Phase3FinalTestQuestion> _extractQuestionsFromLesson(
    Lesson lesson,
    String unitId,
  ) {
    final questions = <Phase3FinalTestQuestion>[];

    // Extract from practice questions
    for (final quizQuestion in lesson.practiceQuestions) {
      try {
        final question = Phase3FinalTestQuestion.fromLessonQuestion(
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
        final question = Phase3FinalTestQuestion.fromLessonQuestion(
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
  bool validateAnswer(Phase3FinalTestQuestion question, int selectedIndex) {
    return selectedIndex == question.correctIndex;
  }

  /// Calculate test result from answers with unit breakdown
  /// Computes score, accuracy, pass/fail status (24/30 = 80%), and per-unit performance
  Phase3TestResult calculateResult(
    List<Phase3FinalTestQuestion> questions,
    List<int?> selectedAnswers,
  ) {
    int correctAnswers = 0;
    final incorrectQuestionDetails = <IncorrectAnswer>[];

    // Calculate overall score and collect incorrect answers
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedIndex = selectedAnswers[i];

      if (selectedIndex != null && selectedIndex == question.correctIndex) {
        correctAnswers++;
      } else {
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

    // Use the factory constructor to calculate derived values
    return Phase3TestResult.calculate(
      correctAnswers: correctAnswers,
      completedAt: DateTime.now(),
      unitBreakdown: unitBreakdown,
      incorrectQuestionDetails: incorrectQuestionDetails,
    );
  }

  /// Calculate performance for a specific unit
  UnitPerformance _calculateUnitPerformance(
    String unitId,
    List<Phase3FinalTestQuestion> questions,
    List<int?> selectedAnswers,
  ) {
    // Filter questions for this unit
    final unitQuestionIndices = <int>[];
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].unitId == unitId) {
        unitQuestionIndices.add(i);
      }
    }

    // Count correct answers for this unit
    int correctAnswers = 0;
    for (final index in unitQuestionIndices) {
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
      totalQuestions: unitQuestionIndices.length,
      correctAnswers: correctAnswers,
    );
  }


  /// Save test result to local storage
  /// Unlocks Phase 4 if test is passed (score >= 24)
  /// 
  /// Uses a fallback strategy: attempts to save all data, but continues
  /// even if some operations fail to ensure critical data is saved
  Future<void> saveTestResult(Phase3TestResult result) async {
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

      // Unlock Phase 4 if test is passed (critical)
      if (result.passed) {
        try {
          await _storageService.setBool(_keyPhase4Unlocked, true);
          print('Phase 4 unlocked successfully');
        } catch (e) {
          errors.add('Phase 4 unlock');
          print('Error: Failed to unlock Phase 4: $e');
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
  Future<Phase3TestResult?> loadTestResult() async {
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

      final result = Phase3TestResult.fromJson(resultJson);
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

  /// Check if all required Phase 3 lessons are mastered
  /// Required before taking the final test
  /// Units 12-16 are required, Unit 17 is optional
  /// 
  /// Returns false on error to prevent test access when mastery cannot be verified
  Future<bool> areAllPhase3LessonsMastered() async {
    try {
      final allProgress = await _progressRepository.loadAllProgress();

      int masteredCount = 0;
      int totalRequired = _requiredLessonIds.length;

      // Check if all required Phase 3 lessons (Units 12-16) are mastered
      for (final lessonId in _requiredLessonIds) {
        final progress = allProgress[lessonId];
        
        // If lesson has no progress or is not mastered, return false
        if (progress == null || !progress.isMastered) {
          print('Lesson $lessonId is not mastered');
          return false;
        }
        
        masteredCount++;
      }

      print('All required Phase 3 lessons mastered: $masteredCount/$totalRequired');
      return true;
    } catch (e) {
      print('Error: Failed to check Phase 3 lesson mastery: $e');
      // Return false to prevent test access when verification fails
      return false;
    }
  }

  /// Clear test data (for retesting)
  /// Does not clear Phase 4 unlock status to preserve progress
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
      
      // Note: We don't clear _keyPhase4Unlocked to preserve unlock status
      
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
