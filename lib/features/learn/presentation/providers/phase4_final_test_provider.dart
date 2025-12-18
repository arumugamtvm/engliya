import 'package:flutter/foundation.dart';
import '../../data/models/phase4_final_test_question.dart';
import '../../data/models/phase4_test_result.dart';
import '../../services/phase4_final_test_service.dart';
import '../../services/gating_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';

/// Provider for managing Phase 4 Final Test state
/// Handles test initialization, question navigation, answer selection, and result submission
/// 
/// Phase 4 covers Units 18-21:
/// - Unit 18: Pronunciation & Sound (6 pronunciation MCQs)
/// - Unit 19: Fluency Techniques (4 speaking tasks)
/// - Unit 20: Real-Life Conversations (6 dialogue MCQs, 4 listening MCQs)
/// - Unit 21: Discussion & Opinion Skills (dialogue MCQs)
/// 
/// Test composition:
/// - 6 Pronunciation MCQs (1 point each = 6 points max)
/// - 6 Dialogue Response MCQs (1 point each = 6 points max)
/// - 4 Listening MCQs (1 point each = 4 points max)
/// - 4 Speaking Tasks (0-3 points each = 12 points max)
/// Total: 20 questions, 24 points max, 18 points (75%) to pass
/// 
/// Requirements: 1.4, 12.1
class Phase4FinalTestProvider extends ChangeNotifier {
  final Phase4FinalTestService _testService;
  final GatingService? _gatingService;

  Phase4FinalTestProvider({
    required Phase4FinalTestService testService,
    GatingService? gatingService,
  }) : _testService = testService,
       _gatingService = gatingService;

  // State properties
  List<Phase4FinalTestQuestion> _questions = [];
  
  /// Answers list - stores int? for MCQ questions and SpeakingResult for speaking tasks
  /// For MCQ: int? representing selected option index (null if not answered)
  /// For Speaking: SpeakingResult containing recognized text and score
  List<dynamic> _answers = [];
  
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  Phase4TestResult? _testResult;

  // Getters
  List<Phase4FinalTestQuestion> get questions => _questions;
  List<dynamic> get answers => _answers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Phase4TestResult? get testResult => _testResult;

  /// Get the current question being displayed
  Phase4FinalTestQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  /// Get the answer for the current question
  /// Returns int? for MCQ questions, SpeakingResult? for speaking tasks
  dynamic get currentAnswer {
    if (_answers.isEmpty || _currentQuestionIndex >= _answers.length) {
      return null;
    }
    return _answers[_currentQuestionIndex];
  }

  /// Get the selected MCQ answer index for the current question
  /// Returns null if current question is not an MCQ or not answered
  int? get selectedMcqAnswer {
    final answer = currentAnswer;
    if (answer is int) return answer;
    return null;
  }

  /// Get the speaking result for the current question
  /// Returns null if current question is not a speaking task or not recorded
  SpeakingResult? get currentSpeakingResult {
    final answer = currentAnswer;
    if (answer is SpeakingResult) return answer;
    return null;
  }

  /// Get total number of questions in the test (always 20)
  int get totalQuestions => Phase4FinalTestService.totalQuestions;

  /// Calculate progress as a percentage (0.0 to 1.0)
  double get progress {
    if (_questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / totalQuestions;
  }

  /// Check if current question is the last question
  bool get isLastQuestion {
    return _currentQuestionIndex == totalQuestions - 1;
  }

  /// Check if user can proceed to next question
  /// For MCQ: answer must be selected
  /// For Speaking: speaking result must be recorded
  bool get canProceed {
    final question = currentQuestion;
    if (question == null) return false;
    
    if (question.isSpeakingTask) {
      return currentSpeakingResult != null;
    } else {
      return selectedMcqAnswer != null;
    }
  }

  /// Check if current question is a speaking task
  bool get isCurrentQuestionSpeaking {
    return currentQuestion?.isSpeakingTask ?? false;
  }

  /// Check if current question is an MCQ
  bool get isCurrentQuestionMcq {
    return currentQuestion?.isMcq ?? false;
  }


  /// Initialize and generate a new test
  /// Loads questions from all Phase 4 lessons and prepares the test
  /// Supports retry mechanism for failed test generation
  /// 
  /// Requirements: 12.4
  /// Throws exceptions for critical failures but sets error state for UI display
  Future<void> startTest({int retryCount = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate prerequisites before generating test
      // Uses GatingService for centralized access control with debug mode bypass
      final canTake = await canTakeTest();
      if (!canTake) {
        _error = 'Please master all Phase 4 lessons before taking the Final Test';
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

      // Validate minimum question count (20 questions required)
      if (_questions.length < totalQuestions) {
        _error = 'Insufficient questions available (${_questions.length}/$totalQuestions). Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      // Initialize answers list with nulls
      // MCQ questions will have int? values, speaking tasks will have SpeakingResult? values
      _answers = List<dynamic>.filled(_questions.length, null);

      // Reset current question index
      _currentQuestionIndex = 0;

      // Clear any previous test result
      _testResult = null;

      _isLoading = false;
      notifyListeners();
      
      print('Phase 4 test started successfully with ${_questions.length} questions');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase4FinalTestProvider.startTest', e, stackTrace);
      
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

  /// Select an MCQ answer for the current question
  /// Updates the answer at the current question index
  /// Only works for MCQ questions (pronunciation, dialogue, listening)
  /// 
  /// Requirements: 12.4
  void selectMcqAnswer(int index) {
    final question = currentQuestion;
    if (question == null || !question.isMcq) {
      print('Warning: Cannot select MCQ answer for non-MCQ question');
      return;
    }
    
    if (_currentQuestionIndex < _answers.length) {
      _answers[_currentQuestionIndex] = index;
      notifyListeners();
    }
  }

  /// Record a speaking result for the current question
  /// Updates the answer at the current question index with the SpeakingResult
  /// Only works for speaking task questions
  /// 
  /// Requirements: 12.4
  void recordSpeakingResult(SpeakingResult result) {
    final question = currentQuestion;
    if (question == null || !question.isSpeakingTask) {
      print('Warning: Cannot record speaking result for non-speaking question');
      return;
    }
    
    if (_currentQuestionIndex < _answers.length) {
      _answers[_currentQuestionIndex] = result;
      notifyListeners();
    }
  }

  /// Move to the next question
  /// Does nothing if already on the last question
  /// 
  /// Requirements: 12.4
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

  /// Skip current question (leave as null)
  /// Allows advancing without selecting an answer or recording speech
  /// 
  /// Requirements: 12.4
  void skipQuestion() {
    if (_currentQuestionIndex < _answers.length) {
      _answers[_currentQuestionIndex] = null;
      notifyListeners();
    }
  }

  /// Submit the test and calculate results
  /// Validates all answers, calculates score, and saves results to storage
  /// Continues even if storage fails, allowing user to see results
  /// 
  /// Requirements: 12.4
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

      if (_answers.length != _questions.length) {
        _error = 'Answer count mismatch. Please restart the test.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      // Separate MCQ answers and speaking results
      final mcqAnswers = <String, int>{};
      final speakingResults = <SpeakingResult>[];
      
      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final answer = _answers[i];
        
        if (question.isMcq) {
          // MCQ question - store selected index
          if (answer is int) {
            mcqAnswers[question.id] = answer;
          }
          // If null, question was skipped - don't add to mcqAnswers
        } else if (question.isSpeakingTask) {
          // Speaking task - store result or create empty result for skipped
          if (answer is SpeakingResult) {
            speakingResults.add(answer);
          } else {
            // Create empty result for skipped speaking task
            speakingResults.add(SpeakingResult(
              taskId: question.id,
              prompt: question.prompt,
              recognizedText: null,
              wordCount: 0,
              score: 0,
              feedback: 'No speech recorded.',
            ));
          }
        }
      }

      // Calculate test result
      try {
        _testResult = _testService.calculateResult(
          questions: _questions,
          mcqAnswers: mcqAnswers,
          speakingResults: speakingResults,
        );
      } catch (e) {
        ErrorHandler.logError('Phase4FinalTestProvider.submitTest - Calculation', e);
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

      print('Test result calculated: ${_testResult!.totalScore}/${_testResult!.maxScore}');

      // Try to save result to storage (non-critical - allow viewing results even if save fails)
      try {
        await _testService.saveTestResult(_testResult!);
        print('Phase 4 test result saved successfully');
        // Clear any previous error since save succeeded
        _error = null;
      } catch (storageError) {
        // Log error but don't fail the submission
        ErrorHandler.logError('Phase4FinalTestProvider.submitTest - Storage', storageError);
        print('Warning: Test result calculated but not fully saved to storage');
        
        // Set a warning message but don't throw - user can still see results
        _error = 'Results calculated but may not be fully saved. You can still view your score.';
        
        // Don't rethrow - allow user to see results even if storage failed
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase4FinalTestProvider.submitTest', e, stackTrace);
      
      // Set user-friendly error message if not already set
      if (_error == null) {
        _error = ErrorHandler.getUserMessage(e);
      }
      
      _isLoading = false;
      notifyListeners();
      rethrow;
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
        ErrorHandler.logError('Phase4FinalTestProvider.retrySubmitTest', e);
        _error = 'Still unable to save results. You can continue anyway.';
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // No results yet, need to recalculate and submit
      await submitTest();
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
      final score = await _testService.getLastTestScore();
      final passed = await _testService.hasPassedTest();
      
      if (score != null) {
        print('Loaded previous Phase 4 test result: score=$score, passed=$passed');
      } else {
        print('No previous Phase 4 test result found');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase4FinalTestProvider.loadPreviousResult', e, stackTrace);
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
    _answers = [];
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
      ErrorHandler.logError('Phase4FinalTestProvider.hasPassedBefore', e);
      return false;
    }
  }

  /// Check if the test has been passed (alias for hasPassedBefore)
  /// Returns true if student has previously passed the test
  Future<bool> hasPassedTest() async {
    return hasPassedBefore();
  }

  /// Check if all Phase 4 lessons are mastered
  /// Required before taking the final test
  /// Uses GatingService for centralized access control with debug mode bypass
  /// In development mode, always returns true
  Future<bool> canTakeTest() async {
    // Development mode: always allow test access
    if (AppConfig.isDevelopmentMode) return true;
    
    // Use GatingService if available (includes debug mode bypass)
    if (_gatingService != null) {
      try {
        return await _gatingService.isFinalTestAccessible(4);
      } catch (e) {
        print('Warning: GatingService error, falling back to direct check: $e');
      }
    }
    
    // Fallback to direct service check
    try {
      return await _testService.canTakeTest();
    } catch (e) {
      ErrorHandler.logError('Phase4FinalTestProvider.canTakeTest', e);
      return false;
    }
  }

  /// Get the last test score
  /// Returns null if no test has been taken
  Future<int?> getLastTestScore() async {
    try {
      return await _testService.getLastTestScore();
    } catch (e) {
      ErrorHandler.logError('Phase4FinalTestProvider.getLastTestScore', e);
      return null;
    }
  }

  /// Get incorrect MCQ answers for review
  /// Returns only MCQ questions where the user selected an incorrect answer
  /// Speaking tasks are excluded from review
  List<Phase4IncorrectAnswer> getIncorrectMcqAnswers() {
    if (_testResult == null) return [];
    return _testService.getIncorrectMcqAnswers(_testResult!);
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
