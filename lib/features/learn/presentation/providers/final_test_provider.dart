import 'package:flutter/foundation.dart';
import '../../data/models/final_test_question.dart';
import '../../data/models/test_result.dart';
import '../../services/phase1_final_test_service.dart';
import '../../services/gating_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';

/// Provider for managing Phase 1 Final Test state
/// Handles test initialization, question navigation, answer selection, and result submission
class FinalTestProvider extends ChangeNotifier {
  final Phase1FinalTestService _testService;
  final GatingService? _gatingService;

  FinalTestProvider({
    required Phase1FinalTestService testService,
    GatingService? gatingService,
  }) : _testService = testService,
       _gatingService = gatingService;

  // State properties
  List<FinalTestQuestion> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  TestResult? _testResult;

  // Getters
  List<FinalTestQuestion> get questions => _questions;
  List<int?> get selectedAnswers => _selectedAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TestResult? get testResult => _testResult;

  /// Get the current question being displayed
  FinalTestQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  /// Get the selected answer for the current question
  int? get selectedAnswer {
    if (_selectedAnswers.isEmpty || _currentQuestionIndex >= _selectedAnswers.length) {
      return null;
    }
    return _selectedAnswers[_currentQuestionIndex];
  }

  /// Get total number of questions in the test
  int get totalQuestions => _questions.length;

  /// Calculate progress as a percentage (0.0 to 1.0)
  double get progress {
    if (totalQuestions == 0) return 0.0;
    return (_currentQuestionIndex + 1) / totalQuestions;
  }

  /// Check if current question is the last question
  bool get isLastQuestion {
    return _currentQuestionIndex == totalQuestions - 1;
  }

  /// Check if user can proceed to next question (answer must be selected)
  bool get canProceed {
    return selectedAnswer != null;
  }

  /// Initialize and generate a new test
  /// Loads questions from all Phase 1 lessons and prepares the test
  /// Supports retry mechanism for failed test generation
  Future<void> startTest({int retryCount = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generate test questions
      _questions = await _testService.generateTest();

      // Validate we got questions
      if (_questions.isEmpty) {
        throw Exception('No questions were generated');
      }

      // Initialize selected answers list with nulls
      _selectedAnswers = List<int?>.filled(_questions.length, null);

      // Reset current question index
      _currentQuestionIndex = 0;

      // Clear any previous test result
      _testResult = null;

      _isLoading = false;
      notifyListeners();
      
      print('Test started successfully with ${_questions.length} questions');
    } catch (e, stackTrace) {
      ErrorHandler.logError('FinalTestProvider.startTest', e, stackTrace);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Retry test generation after a failure
  /// Clears error state and attempts to start test again
  Future<void> retryStartTest() async {
    clearError();
    await startTest();
  }

  /// Select an answer for the current question
  /// Updates the selected answer at the current question index
  void selectAnswer(int index) {
    if (_currentQuestionIndex < _selectedAnswers.length) {
      _selectedAnswers[_currentQuestionIndex] = index;
      notifyListeners();
    }
  }

  /// Move to the next question
  /// Does nothing if already on the last question
  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Move to the previous question
  /// Does nothing if already on the first question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Submit the test and calculate results
  /// Validates all answers, calculates score, and saves results to storage
  /// Continues even if storage fails, allowing user to see results
  Future<void> submitTest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate we have questions and answers
      if (_questions.isEmpty) {
        throw Exception('No questions available to submit');
      }

      if (_selectedAnswers.length != _questions.length) {
        throw Exception('Answer count mismatch');
      }

      // Calculate test result
      _testResult = _testService.calculateResult(_questions, _selectedAnswers);

      if (_testResult == null) {
        throw Exception('Failed to calculate test result');
      }

      // Try to save result to storage
      try {
        await _testService.saveTestResult(_testResult!);
        print('Test result saved successfully');
      } catch (storageError) {
        // Log error but don't fail the submission
        ErrorHandler.logError('FinalTestProvider.submitTest - Storage', storageError);
        print('Warning: Test result calculated but not saved to storage');
        // Set a warning message but don't throw
        _error = 'Results calculated but may not be saved. You can still view your score.';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('FinalTestProvider.submitTest', e, stackTrace);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load previous test result from storage
  /// Useful for displaying past results
  /// Returns silently if no previous result exists
  Future<void> loadPreviousResult() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _testResult = await _testService.loadTestResult();
      
      if (_testResult == null) {
        print('No previous test result found');
      } else {
        print('Loaded previous test result: ${_testResult!.correctAnswers}/${_testResult!.totalQuestions}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('FinalTestProvider.loadPreviousResult', e, stackTrace);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
      // Don't rethrow - this is not critical
    }
  }

  /// Reset test state for retry
  /// Clears all test data and prepares for a new test attempt
  void resetTest() {
    _questions = [];
    _selectedAnswers = [];
    _currentQuestionIndex = 0;
    _testResult = null;
    _error = null;
    notifyListeners();
  }

  /// Check if the test has been passed before
  /// Returns true if student has previously passed the test
  Future<bool> hasPassedBefore() async {
    try {
      return await _testService.hasPassedTest();
    } catch (e) {
      ErrorHandler.logError('FinalTestProvider.hasPassedBefore', e);
      return false;
    }
  }

  /// Check if all Phase 1 lessons are mastered
  /// Required before taking the final test
  /// Uses GatingService for centralized access control with debug mode bypass
  /// In development mode, always returns true
  /// 
  /// Requirements: 12.3, 12.6, 12.7
  Future<bool> canTakeTest() async {
    // Development mode: always allow test access
    if (AppConfig.isDevelopmentMode) return true;
    
    // Use GatingService if available (includes debug mode bypass)
    if (_gatingService != null) {
      try {
        return await _gatingService.isFinalTestAccessible(1);
      } catch (e) {
        print('Warning: GatingService error: $e');
        // For Phase 1, default to true since it's the first phase
        return true;
      }
    }
    
    // Phase 1 is always accessible (first phase)
    return true;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
