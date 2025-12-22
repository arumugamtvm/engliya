import 'package:flutter/foundation.dart';
import '../../data/models/phase5_final_test_question.dart';
import '../../data/models/phase5_test_result.dart';
import '../../services/phase5_final_test_service.dart';
import '../../services/gating_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';

/// Provider for managing Phase 5 Final Test state
/// Handles test initialization, question navigation, answer selection, and result submission
/// 
/// Phase 5 covers Units 22-25:
/// - Unit 22: Business Communication (8 business English MCQs)
/// - Unit 23: Interview English (7 interview MCQs)
/// - Unit 24: Presentation Skills (6 presentation MCQs)
/// - Unit 25: Advanced Writing (6 writing MCQs, 8 speaking tasks)
/// 
/// Test composition:
/// - 8 Business English MCQs (1 point each = 8 points max)
/// - 7 Interview Response MCQs (1 point each = 7 points max)
/// - 6 Presentation Language MCQs (1 point each = 6 points max)
/// - 6 Writing Logic MCQs (1 point each = 6 points max)
/// - 8 Professional Speaking Tasks (0-4 points each = 32 points max)
/// Total: 35 tasks, 60 points max, 45 points (75%) to pass
/// 
/// Requirements: 1.4, 13.1
class Phase5FinalTestProvider extends ChangeNotifier {
  final Phase5FinalTestService _testService;
  final GatingService? _gatingService;

  Phase5FinalTestProvider({
    required Phase5FinalTestService testService,
    GatingService? gatingService,
  }) : _testService = testService,
       _gatingService = gatingService;

  // State properties
  List<Phase5FinalTestQuestion> _questions = [];
  List<dynamic> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  Phase5TestResult? _testResult;

  // Getters
  List<Phase5FinalTestQuestion> get questions => _questions;
  List<dynamic> get answers => _answers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Phase5TestResult? get testResult => _testResult;

  Phase5FinalTestQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  dynamic get currentAnswer {
    if (_answers.isEmpty || _currentQuestionIndex >= _answers.length) {
      return null;
    }
    return _answers[_currentQuestionIndex];
  }

  int? get selectedMcqAnswer {
    final answer = currentAnswer;
    if (answer is int) return answer;
    return null;
  }

  Phase5SpeakingResult? get currentSpeakingResult {
    final answer = currentAnswer;
    if (answer is Phase5SpeakingResult) return answer;
    return null;
  }

  int get totalQuestions => Phase5FinalTestService.totalQuestions;

  double get progress {
    if (_questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / totalQuestions;
  }

  bool get isLastQuestion {
    return _currentQuestionIndex == totalQuestions - 1;
  }

  bool get canProceed {
    final question = currentQuestion;
    if (question == null) return false;
    
    if (question.isSpeakingTask) {
      return currentSpeakingResult != null;
    } else {
      return selectedMcqAnswer != null;
    }
  }

  bool get isCurrentQuestionSpeaking {
    return currentQuestion?.isSpeakingTask ?? false;
  }

  bool get isCurrentQuestionMcq {
    return currentQuestion?.isMcq ?? false;
  }

  Future<void> startTest({int retryCount = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final canTake = await canTakeTest();
      if (!canTake) {
        _error = 'Please master all Phase 5 lessons before taking the Final Test';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      _questions = await _testService.generateTest();

      if (_questions.isEmpty) {
        _error = 'No questions were generated. Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      if (_questions.length < totalQuestions) {
        _error = 'Insufficient questions available (${_questions.length}/$totalQuestions). Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      _answers = List<dynamic>.filled(_questions.length, null);
      _currentQuestionIndex = 0;
      _testResult = null;

      _isLoading = false;
      notifyListeners();
      
      print('Phase 5 test started successfully with ${_questions.length} questions');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase5FinalTestProvider.startTest', e, stackTrace);
      
      if (_error == null) {
        _error = ErrorHandler.getUserMessage(e);
      }
      
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> retryStartTest() async {
    clearError();
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      await startTest();
    } catch (e) {
      print('Retry failed: $e');
    }
  }

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

  void recordSpeakingResult(Phase5SpeakingResult result) {
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

  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void skipQuestion() {
    if (_currentQuestionIndex < _answers.length) {
      _answers[_currentQuestionIndex] = null;
      notifyListeners();
    }
  }

  Future<void> submitTest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      final mcqAnswers = <String, int>{};
      final speakingResults = <Phase5SpeakingResult>[];
      
      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final answer = _answers[i];
        
        if (question.isMcq) {
          if (answer is int) {
            mcqAnswers[question.id] = answer;
          }
        } else if (question.isSpeakingTask) {
          if (answer is Phase5SpeakingResult) {
            speakingResults.add(answer);
          } else {
            speakingResults.add(Phase5SpeakingResult(
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

      try {
        _testResult = _testService.calculateResult(
          questions: _questions,
          mcqAnswers: mcqAnswers,
          speakingResults: speakingResults,
        );
      } catch (e) {
        ErrorHandler.logError('Phase5FinalTestProvider.submitTest - Calculation', e);
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

      try {
        await _testService.saveTestResult(_testResult!);
        print('Phase 5 test result saved successfully');
        _error = null;
      } catch (storageError) {
        ErrorHandler.logError('Phase5FinalTestProvider.submitTest - Storage', storageError);
        print('Warning: Test result calculated but not fully saved to storage');
        _error = 'Results calculated but may not be fully saved. You can still view your score.';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase5FinalTestProvider.submitTest', e, stackTrace);
      
      if (_error == null) {
        _error = ErrorHandler.getUserMessage(e);
      }
      
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> retrySubmitTest() async {
    if (_testResult != null) {
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
        ErrorHandler.logError('Phase5FinalTestProvider.retrySubmitTest', e);
        _error = 'Still unable to save results. You can continue anyway.';
        _isLoading = false;
        notifyListeners();
      }
    } else {
      await submitTest();
    }
  }

  Future<void> loadPreviousResult() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final score = await _testService.getLastTestScore();
      final passed = await _testService.hasPassedTest();
      
      if (score != null) {
        print('Loaded previous Phase 5 test result: score=$score, passed=$passed');
      } else {
        print('No previous Phase 5 test result found');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase5FinalTestProvider.loadPreviousResult', e, stackTrace);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetTest() {
    _questions = [];
    _answers = [];
    _currentQuestionIndex = 0;
    _testResult = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> hasPassedBefore() async {
    try {
      return await _testService.hasPassedTest();
    } catch (e) {
      ErrorHandler.logError('Phase5FinalTestProvider.hasPassedBefore', e);
      return false;
    }
  }

  Future<bool> hasPassedTest() async {
    return hasPassedBefore();
  }

  Future<bool> isEnglishMasteryCompleted() async {
    try {
      return await _testService.isEnglishMasteryCompleted();
    } catch (e) {
      ErrorHandler.logError('Phase5FinalTestProvider.isEnglishMasteryCompleted', e);
      return false;
    }
  }

  Future<bool> canTakeTest() async {
    if (AppConfig.isDevelopmentMode) return true;
    
    if (_gatingService != null) {
      try {
        return await _gatingService.isFinalTestAccessible(5);
      } catch (e) {
        print('Warning: GatingService error, falling back to direct check: $e');
      }
    }
    
    try {
      return await _testService.canTakeTest();
    } catch (e) {
      ErrorHandler.logError('Phase5FinalTestProvider.canTakeTest', e);
      return false;
    }
  }

  Future<int?> getLastTestScore() async {
    try {
      return await _testService.getLastTestScore();
    } catch (e) {
      ErrorHandler.logError('Phase5FinalTestProvider.getLastTestScore', e);
      return null;
    }
  }

  List<Phase5IncorrectAnswer> getIncorrectMcqAnswers() {
    if (_testResult == null) return [];
    return _testResult!.incorrectMcqAnswers;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
