import 'package:flutter/foundation.dart';

import '../../domain/entities/phase_config.dart';
import '../../domain/entities/test_question.dart';
import '../../domain/entities/test_result.dart';
import '../../domain/repositories/test_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../services/gating_service.dart';
import 'final_test_status_provider.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';

class McqFinalTestProvider extends ChangeNotifier
    implements FinalTestStatusProvider {
  final PhaseConfig _config;
  final TestRepository _testRepository;
  final ProgressRepository? _progressRepository;
  final GatingService? _gatingService;

  McqFinalTestProvider({
    required PhaseConfig config,
    required TestRepository testRepository,
    ProgressRepository? progressRepository,
    GatingService? gatingService,
  })  : _config = config,
        _testRepository = testRepository,
        _progressRepository = progressRepository,
        _gatingService = gatingService;

  // State properties
  List<TestQuestion> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  TestResult? _testResult;

  // Getters
  List<TestQuestion> get questions => _questions;
  List<int?> get selectedAnswers => _selectedAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TestResult? get testResult => _testResult;

  TestQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  int? get selectedAnswer {
    if (_selectedAnswers.isEmpty || _currentQuestionIndex >= _selectedAnswers.length) {
      return null;
    }
    return _selectedAnswers[_currentQuestionIndex];
  }

  int get totalQuestions => _questions.length;

  double get progress {
    if (totalQuestions == 0) return 0.0;
    return (_currentQuestionIndex + 1) / totalQuestions;
  }

  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;

  bool get canProceed => selectedAnswer != null;

  Future<void> startTest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final canTake = await canTakeTest();
      if (!canTake) {
        _error = 'Please master all ${_phaseLabel()} lessons before taking the final test';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      _questions = await _testRepository.generateTest(_config);

      if (_questions.isEmpty) {
        _error = 'No questions were generated. Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      if (_questions.length < _config.minRequiredQuestions) {
        _error = 'Insufficient questions available (${_questions.length}/${_config.totalQuestions}). Please complete more lessons.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      _selectedAnswers = List<int?>.filled(_questions.length, null);
      _currentQuestionIndex = 0;
      _testResult = null;

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('McqFinalTestProvider.startTest', e, stackTrace);
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

  Future<void> retrySubmitTest() async {
    if (_testResult != null) {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        await _testRepository.saveTestResult(_config, _testResult!);
        _error = null;
      } catch (e) {
        ErrorHandler.logError('McqFinalTestProvider.retrySubmitTest', e);
        _error = 'Still unable to save results. You can continue anyway.';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      await submitTest();
    }
  }

  void selectAnswer(int index) {
    if (_currentQuestionIndex < _selectedAnswers.length) {
      _selectedAnswers[_currentQuestionIndex] = index;
      notifyListeners();
    }
  }

  void skipQuestion() {
    if (_currentQuestionIndex < _selectedAnswers.length) {
      _selectedAnswers[_currentQuestionIndex] = null;
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

      if (_selectedAnswers.length != _questions.length) {
        _error = 'Answer count mismatch. Please restart the test.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_error);
      }

      _testResult = TestResult.calculate(
        questions: _questions,
        selectedAnswers: _selectedAnswers,
        passingScore: _config.passingScore,
        completedAt: DateTime.now(),
        unitNames: _config.unitNames.isNotEmpty ? _config.unitNames : null,
      );

      try {
        await _testRepository.saveTestResult(_config, _testResult!);
        _error = null;
      } catch (storageError) {
        ErrorHandler.logError('McqFinalTestProvider.submitTest - Storage', storageError);
        _error = 'Results calculated but may not be fully saved. You can still view your score.';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('McqFinalTestProvider.submitTest', e, stackTrace);
      if (_error == null) {
        _error = ErrorHandler.getUserMessage(e);
      }
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadPreviousResult() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _testResult = await _testRepository.loadTestResult(_config);
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      ErrorHandler.logError('McqFinalTestProvider.loadPreviousResult', e, stackTrace);
      _error = ErrorHandler.getUserMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetTest() {
    _questions = [];
    _selectedAnswers = [];
    _currentQuestionIndex = 0;
    _testResult = null;
    _error = null;
    notifyListeners();
  }

  @override
  Future<bool> hasPassedBefore() async {
    try {
      return await _testRepository.hasPassedTest(_config);
    } catch (e) {
      ErrorHandler.logError('McqFinalTestProvider.hasPassedBefore', e);
      return false;
    }
  }

  @override
  Future<int?> getLastTestScore() async {
    try {
      return await _testRepository.getLastTestScore(_config);
    } catch (e) {
      ErrorHandler.logError('McqFinalTestProvider.getLastTestScore', e);
      return null;
    }
  }

  @override
  Future<bool> canTakeTest() async {
    if (AppConfig.isDevelopmentMode) return true;

    if (_gatingService != null) {
      try {
        return await _gatingService!.isFinalTestAccessible(_phaseNumber());
      } catch (e) {
        print('Warning: GatingService error, falling back to direct check: $e');
        if (_config.type == PhaseType.phase1) {
          return true;
        }
      }
    }

    if (_config.type == PhaseType.phase1) {
      return true;
    }

    if (_progressRepository == null) {
      return false;
    }

    try {
      final allProgress = await _progressRepository!.loadAllProgress();
      for (final lessonId in _config.requiredLessonIds) {
        final progress = allProgress[lessonId];
        if (progress == null || !progress.isMastered) {
          return false;
        }
      }
      return true;
    } catch (e) {
      ErrorHandler.logError('McqFinalTestProvider.canTakeTest', e);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  int _phaseNumber() {
    switch (_config.type) {
      case PhaseType.phase1:
        return 1;
      case PhaseType.phase2:
        return 2;
      case PhaseType.phase3:
        return 3;
      case PhaseType.phase4:
        return 4;
      case PhaseType.phase5:
        return 5;
    }
  }

  String _phaseLabel() => 'Phase ${_phaseNumber()}';
}
