import 'dart:math';

import '../../domain/entities/phase_config.dart';
import '../../domain/entities/test_question.dart';
import '../../domain/entities/test_result.dart';
import '../../domain/repositories/test_repository.dart';
import '../models/test_question_model.dart';
import '../models/test_result_model.dart';
import '../models/lesson.dart';
import '../../../../services/local_storage/storage_service.dart';
import 'lesson_repository.dart';

/// Custom exception for test generation errors
class TestGenerationException implements Exception {
  final String message;
  final dynamic originalError;

  TestGenerationException(this.message, {this.originalError});

  @override
  String toString() => 'TestGenerationException: $message';
}

/// Custom exception for insufficient questions
class InsufficientQuestionsException implements Exception {
  final String message;
  final int available;
  final int required;

  InsufficientQuestionsException(
    this.message, {
    required this.available,
    required this.required,
  });

  @override
  String toString() =>
      'InsufficientQuestionsException: $message (available: $available, required: $required)';
}

/// Implementation of TestRepository that handles all phases
/// Uses PhaseConfig to determine phase-specific behavior
class TestRepositoryImpl implements TestRepository {
  final LessonRepository _lessonRepository;
  final StorageService _storageService;
  final Random _random;

  TestRepositoryImpl({
    required LessonRepository lessonRepository,
    required StorageService storageService,
    Random? random,
  })  : _lessonRepository = lessonRepository,
        _storageService = storageService,
        _random = random ?? Random();

  @override
  Future<List<TestQuestion>> generateTest(PhaseConfig config) async {
    final questions = <TestQuestionModel>[];

    // Load questions based on phase configuration
    if (config.hasUnits) {
      // For phases with units (Phase 2-5), load by unit
      await _loadQuestionsForUnits(config, questions);
    } else {
      // For Phase 1, load by lesson
      await _loadQuestionsForLessons(config, questions);
    }

    // Validate we have enough questions
    final minimumRequired = (config.totalQuestions * 0.8).ceil();
    if (questions.length < minimumRequired) {
      throw InsufficientQuestionsException(
        'Not enough questions available for ${config.name}',
        available: questions.length,
        required: minimumRequired,
      );
    }

    // Shuffle and limit to total questions
    questions.shuffle(_random);
    final selectedQuestions = questions.take(config.totalQuestions).toList();

    // Convert to domain entities
    return selectedQuestions.map((m) => m.toEntity()).toList();
  }


  /// Load questions for phases with unit-based organization (Phase 2-5)
  Future<void> _loadQuestionsForUnits(
    PhaseConfig config,
    List<TestQuestionModel> questions,
  ) async {
    for (final entry in config.questionDistribution.entries) {
      final unitId = entry.key;
      final targetCount = entry.value;

      try {
        final unitQuestions = await _loadUnitQuestions(config, unitId, targetCount);
        questions.addAll(unitQuestions);
      } catch (e) {
        // Log error but continue loading other units
        print('Warning: Failed to load questions for unit $unitId: $e');
      }
    }
  }

  /// Load questions for phases without units (Phase 1)
  Future<void> _loadQuestionsForLessons(
    PhaseConfig config,
    List<TestQuestionModel> questions,
  ) async {
    for (final entry in config.questionDistribution.entries) {
      final lessonId = entry.key;
      final targetCount = entry.value;

      try {
        final lessonQuestions = await _loadLessonQuestions(
          config,
          lessonId,
          targetCount,
        );
        questions.addAll(lessonQuestions);
      } catch (e) {
        // Log error but continue loading other lessons
        print('Warning: Failed to load questions for lesson $lessonId: $e');
      }
    }
  }

  /// Load questions from a specific unit
  Future<List<TestQuestionModel>> _loadUnitQuestions(
    PhaseConfig config,
    String unitId,
    int targetCount,
  ) async {
    final questions = <TestQuestionModel>[];
    final lessonIds = config.getLessonsForUnit(unitId);

    for (final lessonId in lessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);
        final lessonQuestions = _extractQuestionsFromLesson(lesson, unitId);
        questions.addAll(lessonQuestions);
      } catch (e) {
        print('Warning: Failed to load lesson $lessonId: $e');
      }
    }

    // Shuffle and select target count
    questions.shuffle(_random);
    return questions.take(targetCount).toList();
  }

  /// Load questions from a specific lesson (for Phase 1)
  Future<List<TestQuestionModel>> _loadLessonQuestions(
    PhaseConfig config,
    String lessonId,
    int targetCount,
  ) async {
    try {
      final lesson = await _lessonRepository.loadLesson(lessonId);
      final unitId = config.getUnitForLesson(lessonId);
      final questions = _extractQuestionsFromLesson(lesson, unitId);

      // Shuffle and select target count
      questions.shuffle(_random);
      return questions.take(targetCount).toList();
    } catch (e) {
      throw TestGenerationException(
        'Failed to load questions from lesson $lessonId',
        originalError: e,
      );
    }
  }

  /// Extract questions from a lesson and convert to TestQuestionModel
  List<TestQuestionModel> _extractQuestionsFromLesson(
    Lesson lesson,
    String? unitId,
  ) {
    final questions = <TestQuestionModel>[];

    // Extract from practice questions
    for (final q in lesson.practiceQuestions) {
      questions.add(_convertQuizQuestion(q, lesson, unitId));
    }

    // Extract from mastery questions
    for (final q in lesson.masteryQuestions) {
      questions.add(_convertQuizQuestion(q, lesson, unitId));
    }

    return questions;
  }

  /// Convert a QuizQuestion to TestQuestionModel
  TestQuestionModel _convertQuizQuestion(
    dynamic quizQuestion,
    Lesson lesson,
    String? unitId,
  ) {
    final id = '${lesson.id}_${quizQuestion.promptEn.hashCode}';

    return TestQuestionModel(
      id: id,
      lessonId: lesson.id,
      lessonTitle: lesson.title,
      unitId: unitId,
      promptEn: quizQuestion.promptEn,
      promptTa: quizQuestion.promptTa,
      options: List<String>.from(quizQuestion.options),
      correctIndex: quizQuestion.correctIndex,
      questionType: quizQuestion.type,
    );
  }


  @override
  Future<void> saveTestResult(PhaseConfig config, TestResult result) async {
    try {
      // Save basic test data
      await _storageService.setBool(config.keyTestPassed, result.passed);
      await _storageService.setInt(config.keyTestScore, result.correctAnswers);
      await _storageService.setString(
        config.keyTestDate,
        result.completedAt.toIso8601String(),
      );

      // Save full result as JSON
      final resultModel = TestResultModel.fromEntity(result);
      await _storageService.setJson(config.keyTestResult, resultModel.toJson());

      // Unlock next phase if passed
      if (result.passed) {
        await _storageService.setBool(config.keyNextPhaseUnlocked, true);
      }
    } catch (e) {
      throw TestGenerationException(
        'Failed to save test result for ${config.name}',
        originalError: e,
      );
    }
  }

  @override
  Future<TestResult?> loadTestResult(PhaseConfig config) async {
    try {
      final json = _storageService.getJson(config.keyTestResult);
      if (json == null) {
        return null;
      }

      return TestResultModel.fromJson(json).toEntity();
    } catch (e) {
      // Return null if result cannot be loaded
      print('Warning: Failed to load test result for ${config.name}: $e');
      return null;
    }
  }

  @override
  Future<bool> hasPassedTest(PhaseConfig config) async {
    try {
      return _storageService.getBool(config.keyTestPassed) ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int?> getLastTestScore(PhaseConfig config) async {
    try {
      return _storageService.getInt(config.keyTestScore);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearTestData(PhaseConfig config) async {
    try {
      await _storageService.remove(config.keyTestPassed);
      await _storageService.remove(config.keyTestScore);
      await _storageService.remove(config.keyTestDate);
      await _storageService.remove(config.keyTestResult);
    } catch (e) {
      throw TestGenerationException(
        'Failed to clear test data for ${config.name}',
        originalError: e,
      );
    }
  }
}

/// Helper class for calculating test results
class TestResultCalculator {
  /// Calculate test result from questions and answers
  /// This is a static helper that can be used by use cases
  static TestResult calculate({
    required PhaseConfig config,
    required List<TestQuestion> questions,
    required List<int?> selectedAnswers,
    required DateTime completedAt,
  }) {
    return TestResult.calculate(
      questions: questions,
      selectedAnswers: selectedAnswers,
      passingScore: config.passingScore,
      completedAt: completedAt,
      unitNames: config.unitNames,
    );
  }
}
