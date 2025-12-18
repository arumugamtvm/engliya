import 'package:flutter/foundation.dart';
import '../../data/models/phase2_final_test_question.dart';
import '../../data/models/phase2_test_result.dart';
import '../../services/phase2_final_test_service.dart';
import '../../services/gating_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';

/// Provider for managing Phase 2 Final Test state
/// Handles test initialization, question navigation, answer selection, and result submission
class Phase2FinalTestProvider extends ChangeNotifier {
  final Phase2FinalTestService _testService;
  final GatingService? _gatingService;

  Phase2FinalTestProvider({
    required Phase2FinalTestService testService,
    GatingService? gatingService,
  }) : _testService = testService,
       _gatingService = gatingService;

  // State properties
  List<Phase2FinalTestQuestion> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  Phase2TestResult? _testResult;

  // Getters
  List<Phase2FinalTestQuestion> get questions => _questions;
  List<int?> get selectedAnswers => _selectedAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Phase2TestResult? get testResult => _testResult;

  /// Get the current question being displayed
  Phase2FinalTestQuestion? get currentQuestion {
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
  /// Loads questions from all Phase 2 lessons and prepares the test
  /// Supports retry mechanism for failed test generation
  /// 
  /// Throws exceptions for critical failures but sets error state for UI display
  Future<void> startTest({int retryCount = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate prerequisites before generating test
      // Uses GatingService for centralized access control with debug mode bypass
      // Requirements: 12.3, 12.6, 12.7
      final canTake = await canTakeTest();
      if (!canTake) {
        _error = 'Please master all Phase 2 lessons before taking the final test';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      // Generate test questions
      _questions = await _testService.generateTest();

      // Validate we got questions
      if (_questions.isEmpty) {
        _error = 'No questions were generated. Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      // Validate minimum question count
      if (_questions.length < 20) {
        _error = 'Insufficient questions available (${_questions.length}/25). Please complete more lessons.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      // Initialize selected answers list with nulls
      _selectedAnswers = List<int?>.filled(_questions.length, null);

      // Reset current question index
      _currentQuestionIndex = 0;

      // Clear any previous test result
      _testResult = null;

      _isLoading = false;
      notifyListeners();
      
      print('Phase 2 test started successfully with ${_questions.length} questions');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase2FinalTestProvider.startTest', e, stackTrace);
      
      // Set user-friendly error message if not already set
      if (_error == null) {
        _error = ErrorHandler.getUserMessage(e);
      }
      
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Retry test generation after a failure
  /// Clears error state and attempts to start test again
  /// Implements simple retry logic with delay
  Future<void> retryStartTest() async {
    clearError();
    
    // Add a small delay before retry to allow any transient issues to resolve
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      await startTest();
    } catch (e) {
      // Error is already handled by startTest
      print('Retry failed: $e');
    }
  }

  /// Retry test submission after a failure
  /// Useful when storage fails but calculation succeeded
  Future<void> retrySubmitTest() async {
    if (_testResult != null) {
      // If we already have results, just try to save them again
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      try {
        await _testService.saveTestResult(_testResult!);
        print('Test result saved successfully on retry');
        _error = null;
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        ErrorHandler.logError('Phase2FinalTestProvider.retrySubmitTest', e);
        _error = 'Still unable to save results. You can continue anyway.';
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // No results yet, need to recalculate and submit
      await submitTest();
    }
  }

  /// Select an answer for the current question
  /// Updates the selected answer at the current question index
  void selectAnswer(int index) {
    if (_currentQuestionIndex < _selectedAnswers.length) {
      _selectedAnswers[_currentQuestionIndex] = index;
      notifyListeners();
    }
  }

  /// Skip current question (leave as null)
  /// Allows advancing without selecting an answer
  void skipQuestion() {
    if (_currentQuestionIndex < _selectedAnswers.length) {
      _selectedAnswers[_currentQuestionIndex] = null;
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
  /// Validates all answers, calculates score with unit breakdown, and saves results to storage
  /// Continues even if storage fails, allowing user to see results
  /// 
  /// Uses graceful degradation: prioritizes showing results over storage success
  Future<void> submitTest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate we have questions and answers
      if (_questions.isEmpty) {
        _error = 'No questions available to submit';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      if (_selectedAnswers.length != _questions.length) {
        _error = 'Answer count mismatch. Please restart the test.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      // Calculate test result with unit breakdown
      try {
        _testResult = _testService.calculateResult(_questions, _selectedAnswers);
      } catch (e) {
        ErrorHandler.logError('Phase2FinalTestProvider.submitTest - Calculation', e);
        _error = 'Failed to calculate test results. Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      if (_testResult == null) {
        _error = 'Failed to calculate test result';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      print('Test result calculated: ${_testResult!.correctAnswers}/${_testResult!.totalQuestions}');

      // Try to save result to storage (non-critical - allow viewing results even if save fails)
      try {
        await _testService.saveTestResult(_testResult!);
        print('Phase 2 test result saved successfully');
        // Clear any previous error since save succeeded
        _error = null;
      } catch (storageError) {
        // Log error but don't fail the submission
        ErrorHandler.logError('Phase2FinalTestProvider.submitTest - Storage', storageError);
        print('Warning: Test result calculated but not fully saved to storage');
        
        // Set a warning message but don't throw - user can still see results
        _error = 'Results calculated but may not be fully saved. You can still view your score.';
        
        // Don't rethrow - allow user to see results even if storage failed
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase2FinalTestProvider.submitTest', e, stackTrace);
      
      // Set user-friendly error message if not already set
      if (_error == null) {
        _error = ErrorHandler.getUserMessage(e);
      }
      
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
        print('No previous Phase 2 test result found');
      } else {
        print('Loaded previous Phase 2 test result: ${_testResult!.correctAnswers}/${_testResult!.totalQuestions}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase2FinalTestProvider.loadPreviousResult', e, stackTrace);
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
      ErrorHandler.logError('Phase2FinalTestProvider.hasPassedBefore', e);
      return false;
    }
  }

  /// Check if all Phase 2 lessons are mastered
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
        return await _gatingService.isFinalTestAccessible(2);
      } catch (e) {
        print('Warning: GatingService error, falling back to direct check: $e');
      }
    }
    
    // Fallback to direct service check
    try {
      return await _testService.areAllPhase2LessonsMastered();
    } catch (e) {
      ErrorHandler.logError('Phase2FinalTestProvider.canTakeTest', e);
      return false;
    }
  }

  /// Get the last test score
  /// Returns null if no test has been taken
  Future<int?> getLastTestScore() async {
    try {
      return await _testService.getLastTestScore();
    } catch (e) {
      ErrorHandler.logError('Phase2FinalTestProvider.getLastTestScore', e);
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
