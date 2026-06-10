import 'package:flutter/foundation.dart';

import '../../services/final_test_service.dart';
import '../../services/gating_service.dart';
import 'final_test_status_provider.dart';
import 'hybrid_final_test_provider.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/logging/app_logger.dart';

class FinalTestProvider<Q, S, R> extends ChangeNotifier
    implements FinalTestStatusProvider, HybridFinalTestProvider<Q, S, R> {
  final FinalTestService<Q, S, R> _testService;
  final GatingService? _gatingService;

  FinalTestProvider({
    required FinalTestService<Q, S, R> testService,
    GatingService? gatingService,
  }) : _testService = testService,
       _gatingService = gatingService;

  List<Q> _questions = [];
  List<dynamic> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  R? _testResult;

  @override
  List<Q> get questions => _questions;

  @override
  int get currentQuestionIndex => _currentQuestionIndex;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  R? get testResult => _testResult;

  @override
  Q? get currentQuestion {
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

  @override
  int? get selectedMcqAnswer {
    final answer = currentAnswer;
    if (answer is int) return answer;
    return null;
  }

  @override
  S? get currentSpeakingResult {
    final answer = currentAnswer;
    if (answer is S) return answer;
    return null;
  }

  @override
  int get totalQuestions => _testService.totalQuestions;

  @override
  double get progress {
    if (_questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / totalQuestions;
  }

  @override
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;

  @override
  bool get canProceed {
    final question = currentQuestion;
    if (question == null) return false;

    if (_testService.isSpeakingTask(question)) {
      return currentSpeakingResult != null;
    }

    if (_testService.isMcq(question)) {
      return selectedMcqAnswer != null;
    }

    return false;
  }

  @override
  bool get isCurrentQuestionSpeaking {
    final question = currentQuestion;
    if (question == null) return false;
    return _testService.isSpeakingTask(question);
  }

  @override
  bool get isCurrentQuestionMcq {
    final question = currentQuestion;
    if (question == null) return false;
    return _testService.isMcq(question);
  }

  @override
  Future<void> startTest({int retryCount = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final canTake = await canTakeTest();
      if (!canTake) {
        _error =
            'Please master all ${_testService.phaseLabel} lessons before taking the Final Test';
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
        _error =
            'Insufficient questions available (${_questions.length}/$totalQuestions). Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      _answers = List<dynamic>.filled(_questions.length, null);
      _currentQuestionIndex = 0;
      _testResult = null;

      _isLoading = false;
      notifyListeners();

      AppLogger.debug(
        '${_testService.phaseLabel} test started successfully with ${_questions.length} questions',
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        'FinalTestProvider.startTest (${_testService.phaseLabel})',
        e,
        stackTrace,
      );

      _error ??= ErrorHandler.getUserMessage(e);

      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<void> retryStartTest() async {
    clearError();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await startTest();
    } catch (e) {
      AppLogger.debug('Retry failed: $e');
    }
  }

  @override
  void selectMcqAnswer(int index) {
    final question = currentQuestion;
    if (question == null || !_testService.isMcq(question)) {
      AppLogger.warning('Warning: Cannot select MCQ answer for non-MCQ question');
      return;
    }

    if (_currentQuestionIndex < _answers.length) {
      _answers[_currentQuestionIndex] = index;
      notifyListeners();
    }
  }

  @override
  void recordSpeakingResult(S result) {
    final question = currentQuestion;
    if (question == null || !_testService.isSpeakingTask(question)) {
      AppLogger.warning('Warning: Cannot record speaking result for non-speaking question');
      return;
    }

    if (_currentQuestionIndex < _answers.length) {
      _answers[_currentQuestionIndex] = result;
      notifyListeners();
    }
  }

  @override
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

  @override
  void skipQuestion() {
    if (_currentQuestionIndex < _answers.length) {
      _answers[_currentQuestionIndex] = null;
      notifyListeners();
    }
  }

  @override
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
      final speakingResults = <S>[];

      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final answer = _answers[i];

        if (_testService.isMcq(question)) {
          if (answer is int) {
            mcqAnswers[_testService.questionId(question)] = answer;
          }
        } else if (_testService.isSpeakingTask(question)) {
          if (answer is S) {
            speakingResults.add(answer);
          } else {
            speakingResults.add(
              _testService.createEmptySpeakingResult(question),
            );
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
        ErrorHandler.logError(
          'FinalTestProvider.submitTest - Calculation (${_testService.phaseLabel})',
          e,
        );
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

      try {
        await _testService.saveTestResult(_testResult as R);
        _error = null;
      } catch (storageError) {
        ErrorHandler.logError(
          'FinalTestProvider.submitTest - Storage (${_testService.phaseLabel})',
          storageError,
        );
        _error =
            'Results calculated but may not be fully saved. You can still view your score.';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        'FinalTestProvider.submitTest (${_testService.phaseLabel})',
        e,
        stackTrace,
      );

      _error ??= ErrorHandler.getUserMessage(e);

      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<void> retrySubmitTest() async {
    if (_testResult != null) {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        await _testService.saveTestResult(_testResult as R);
        _error = null;
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        ErrorHandler.logError(
          'FinalTestProvider.retrySubmitTest (${_testService.phaseLabel})',
          e,
        );
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
        AppLogger.debug(
          '${_testService.phaseLabel} previous test result: score=$score, passed=$passed',
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        'FinalTestProvider.loadPreviousResult (${_testService.phaseLabel})',
        e,
        stackTrace,
      );
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

  @override
  Future<bool> hasPassedBefore() async {
    try {
      return await _testService.hasPassedTest();
    } catch (e) {
      ErrorHandler.logError(
        'FinalTestProvider.hasPassedBefore (${_testService.phaseLabel})',
        e,
      );
      return false;
    }
  }

  @override
  Future<bool> canTakeTest() async {
    if (AppConfig.devMode) return true;

    if (_gatingService != null) {
      try {
        return await _gatingService.isFinalTestAccessible(
          _testService.phaseNumber,
        );
      } catch (e) {
        AppLogger.warning('Warning: GatingService error, falling back to direct check: $e');
      }
    }

    try {
      return await _testService.canTakeTest();
    } catch (e) {
      ErrorHandler.logError(
        'FinalTestProvider.canTakeTest (${_testService.phaseLabel})',
        e,
      );
      return false;
    }
  }

  @override
  Future<int?> getLastTestScore() async {
    try {
      return await _testService.getLastTestScore();
    } catch (e) {
      ErrorHandler.logError(
        'FinalTestProvider.getLastTestScore (${_testService.phaseLabel})',
        e,
      );
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
