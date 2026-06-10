import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/phase4_final_test_question.dart';
import '../../data/models/phase4_test_result.dart';
import '../../data/models/phase5_final_test_question.dart';
import '../../data/models/phase5_test_result.dart';
import '../providers/final_test_provider.dart';
import '../providers/hybrid_final_test_provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/logging/app_logger.dart';

class SpeakingResultViewData {
  final int score;
  final int maxScore;
  final String feedback;
  final String? recognizedText;
  final int wordCount;

  const SpeakingResultViewData({
    required this.score,
    required this.maxScore,
    required this.feedback,
    required this.recognizedText,
    required this.wordCount,
  });
}

class FinalTestScreenConfig<TQuestion, TSpeakingResult, TResult> {
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final String lockedDescription;
  final String lockedSemanticsLabel;
  final String resultRoute;
  final int maxRecordingSeconds;
  final bool autoStopRecording;
  final bool submitOnSkipLast;
  final String speakingInstruction;
  final bool showRecognizedText;
  final String Function(TQuestion question) questionId;
  final String Function(TQuestion question) prompt;
  final List<String>? Function(TQuestion question) options;
  final String? Function(TQuestion question) audioText;
  final String Function(TQuestion question) questionTypeLabel;
  final Color Function(TQuestion question) questionTypeColor;
  final String Function(int seconds) mockSpeechText;
  final TSpeakingResult Function({
    required String taskId,
    required String prompt,
    String? recognizedText,
  })
  createSpeakingResult;
  final SpeakingResultViewData Function(TSpeakingResult result)
  speakingResultViewData;

  const FinalTestScreenConfig({
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
    required this.lockedDescription,
    required this.lockedSemanticsLabel,
    required this.resultRoute,
    required this.maxRecordingSeconds,
    required this.autoStopRecording,
    required this.submitOnSkipLast,
    required this.speakingInstruction,
    required this.showRecognizedText,
    required this.questionId,
    required this.prompt,
    required this.options,
    required this.audioText,
    required this.questionTypeLabel,
    required this.questionTypeColor,
    required this.mockSpeechText,
    required this.createSpeakingResult,
    required this.speakingResultViewData,
  });

  static FinalTestScreenConfig<
    Phase4FinalTestQuestion,
    SpeakingResult,
    Phase4TestResult
  >
  phase4() {
    return FinalTestScreenConfig(
      title: 'Phase 4 - Final Test',
      subtitle: 'Fluency & Pronunciation Check',
      semanticsLabel: 'Phase 4 Final Test, Fluency and Pronunciation Check',
      lockedDescription:
          'Please master all Phase 4 lessons before taking the Final Test',
      lockedSemanticsLabel:
          'Test locked. Please master all Phase 4 lessons before taking the final test.',
      resultRoute: '/phase4/finalTest/result',
      maxRecordingSeconds: 30,
      autoStopRecording: true,
      submitOnSkipLast: true,
      speakingInstruction:
          'Speak for 20-30 seconds. Try to use 20+ words for full points.',
      showRecognizedText: true,
      questionId: (question) => question.id,
      prompt: (question) => question.prompt,
      options: (question) => question.options,
      audioText: (question) => question.audioText,
      questionTypeLabel: (question) {
        switch (question.type) {
          case Phase4QuestionType.pronunciation:
            return 'Pronunciation';
          case Phase4QuestionType.dialogue:
            return 'Dialogue Response';
          case Phase4QuestionType.listening:
            return 'Listening';
          case Phase4QuestionType.speaking:
            return 'Speaking Task';
        }
      },
      questionTypeColor: (question) {
        switch (question.type) {
          case Phase4QuestionType.pronunciation:
            return Colors.purple;
          case Phase4QuestionType.dialogue:
            return Colors.teal;
          case Phase4QuestionType.listening:
            return Colors.orange;
          case Phase4QuestionType.speaking:
            return Colors.blue;
        }
      },
      mockSpeechText: _buildPhase4MockSpeechText,
      createSpeakingResult:
          ({
            required String taskId,
            required String prompt,
            String? recognizedText,
          }) {
            return SpeakingResult.fromRecognition(
              taskId: taskId,
              prompt: prompt,
              recognizedText: recognizedText,
            );
          },
      speakingResultViewData: (result) {
        return SpeakingResultViewData(
          score: result.score,
          maxScore: 3,
          feedback: result.feedback,
          recognizedText: result.recognizedText,
          wordCount: result.wordCount,
        );
      },
    );
  }

  static FinalTestScreenConfig<
    Phase5FinalTestQuestion,
    Phase5SpeakingResult,
    Phase5TestResult
  >
  phase5() {
    return FinalTestScreenConfig(
      title: 'Phase 5 - Final Test',
      subtitle: 'Professional English Mastery',
      semanticsLabel: 'Phase 5 Final Test, Professional English Mastery',
      lockedDescription:
          'Please master all Phase 5 lessons before taking the Final Test',
      lockedSemanticsLabel:
          'Test locked. Please master all Phase 5 lessons before taking the final test.',
      resultRoute: '/phase5/finalTest/result',
      maxRecordingSeconds: 60,
      autoStopRecording: false,
      submitOnSkipLast: false,
      speakingInstruction:
          'Speak for 30-60 seconds. Aim for 40+ words for full points.',
      showRecognizedText: false,
      questionId: (question) => question.id,
      prompt: (question) => question.prompt,
      options: (question) => question.options,
      audioText: (_) => null,
      questionTypeLabel: (question) {
        switch (question.type) {
          case Phase5QuestionType.businessEnglish:
            return 'Business English';
          case Phase5QuestionType.interview:
            return 'Interview';
          case Phase5QuestionType.presentation:
            return 'Presentation';
          case Phase5QuestionType.writing:
            return 'Writing';
          case Phase5QuestionType.shortAnswer:
            return 'Short Answer';
          case Phase5QuestionType.rewrite:
            return 'Rewrite';
          case Phase5QuestionType.ordering:
            return 'Ordering';
          case Phase5QuestionType.speakingRubricScored:
            return 'Speaking';
          case Phase5QuestionType.writingRubricScored:
            return 'Writing Task';
        }
      },
      questionTypeColor: (question) {
        switch (question.type) {
          case Phase5QuestionType.businessEnglish:
            return Colors.blue;
          case Phase5QuestionType.interview:
            return Colors.green;
          case Phase5QuestionType.presentation:
            return Colors.orange;
          case Phase5QuestionType.writing:
            return Colors.purple;
          case Phase5QuestionType.shortAnswer:
            return Colors.teal;
          case Phase5QuestionType.rewrite:
            return Colors.cyan;
          case Phase5QuestionType.ordering:
            return Colors.indigo;
          case Phase5QuestionType.speakingRubricScored:
            return Colors.red;
          case Phase5QuestionType.writingRubricScored:
            return Colors.brown;
        }
      },
      mockSpeechText: _buildPhase5MockSpeechText,
      createSpeakingResult:
          ({
            required String taskId,
            required String prompt,
            String? recognizedText,
          }) {
            return Phase5SpeakingResult.fromRecognition(
              taskId: taskId,
              prompt: prompt,
              recognizedText: recognizedText,
            );
          },
      speakingResultViewData: (result) {
        return SpeakingResultViewData(
          score: result.score,
          maxScore: 4,
          feedback: result.feedback,
          recognizedText: result.recognizedText,
          wordCount: result.wordCount,
        );
      },
    );
  }
}

class FinalTestScreen<
  TProvider
      extends HybridFinalTestProvider<TQuestion, TSpeakingResult, TResult>,
  TQuestion,
  TSpeakingResult,
  TResult
>
    extends StatefulWidget {
  final FinalTestScreenConfig<TQuestion, TSpeakingResult, TResult> config;

  const FinalTestScreen({required this.config, super.key});

  static FinalTestScreen<
    FinalTestProvider<
      Phase4FinalTestQuestion,
      SpeakingResult,
      Phase4TestResult
    >,
    Phase4FinalTestQuestion,
    SpeakingResult,
    Phase4TestResult
  >
  phase4({Key? key}) {
    return FinalTestScreen<
      FinalTestProvider<
        Phase4FinalTestQuestion,
        SpeakingResult,
        Phase4TestResult
      >,
      Phase4FinalTestQuestion,
      SpeakingResult,
      Phase4TestResult
    >(key: key, config: FinalTestScreenConfig.phase4());
  }

  static FinalTestScreen<
    FinalTestProvider<
      Phase5FinalTestQuestion,
      Phase5SpeakingResult,
      Phase5TestResult
    >,
    Phase5FinalTestQuestion,
    Phase5SpeakingResult,
    Phase5TestResult
  >
  phase5({Key? key}) {
    return FinalTestScreen<
      FinalTestProvider<
        Phase5FinalTestQuestion,
        Phase5SpeakingResult,
        Phase5TestResult
      >,
      Phase5FinalTestQuestion,
      Phase5SpeakingResult,
      Phase5TestResult
    >(key: key, config: FinalTestScreenConfig.phase5());
  }

  @override
  State<FinalTestScreen<TProvider, TQuestion, TSpeakingResult, TResult>>
  createState() =>
      _FinalTestScreenState<TProvider, TQuestion, TSpeakingResult, TResult>();
}

class _FinalTestScreenState<
  TProvider
      extends HybridFinalTestProvider<TQuestion, TSpeakingResult, TResult>,
  TQuestion,
  TSpeakingResult,
  TResult
>
    extends
        State<FinalTestScreen<TProvider, TQuestion, TSpeakingResult, TResult>>
    with SingleTickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _previousQuestionIndex = -1;

  final FocusNode _questionFocusNode = FocusNode();
  bool _isRecording = false;
  int _recordingSeconds = 0;
  bool _isRetryingInitialize = false;

  FinalTestScreenConfig<TQuestion, TSpeakingResult, TResult> get _config =>
      widget.config;

  @override
  void initState() {
    super.initState();

    _questionAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.1, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _questionAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _questionAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTest();
    });
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    _questionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeTest() async {
    final provider = context.read<TProvider>();
    final canTake = AppConfig.devMode || await provider.canTakeTest();

    if (!canTake) {
      return;
    }

    try {
      await provider.startTest();
      _questionAnimationController.forward();
    } catch (e) {
      AppLogger.debug('Test initialization failed: $e');
    }
  }

  Future<void> _retryInitializeTest() async {
    if (_isRetryingInitialize) return;
    setState(() {
      _isRetryingInitialize = true;
    });
    try {
      await context.read<TProvider>().retryStartTest();
      _questionAnimationController.forward();
    } catch (e) {
      AppLogger.debug('Test retry failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRetryingInitialize = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<TProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoadingState(message: 'Loading test...');
          }

          return FutureBuilder<bool>(
            future: provider.canTakeTest(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoadingState(
                  message: 'Checking test eligibility...',
                );
              }

              final canTake = AppConfig.devMode || (snapshot.data ?? false);
              if (!canTake) {
                return _buildLockedState(context);
              }

              if (provider.error != null) {
                return _buildErrorState(context, provider);
              }

              if (provider.questions.isEmpty) {
                return const AppEmptyState(
                  title: 'No questions available',
                  subtitle: 'Please try again in a moment.',
                );
              }

              return _buildTestContent(context, provider);
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Semantics(
        label: _config.semanticsLabel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _config.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              _config.subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLockedState(BuildContext context) {
    return Semantics(
      label: _config.lockedSemanticsLabel,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppTheme.lockedColor,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Test Locked',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                _config.lockedDescription,
                textAlign: TextAlign.center,
                style: AppTheme.bodyText1,
              ),
              const SizedBox(height: AppTheme.spacingL),
              Semantics(
                button: true,
                label: 'Go back to previous screen',
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TProvider provider) {
    return Semantics(
      label: 'Error loading test. ${provider.error}. Please try again.',
      child: AppErrorState(
        message: provider.error ?? 'An error occurred while loading test.',
        retryLabel: _isRetryingInitialize ? 'Retrying...' : 'Retry',
        onRetry: _isRetryingInitialize ? () {} : _retryInitializeTest,
      ),
    );
  }

  Widget _buildTestContent(BuildContext context, TProvider provider) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          _buildProgressSection(provider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionSection(provider),
                  const SizedBox(height: AppTheme.spacingL),
                  if (provider.isCurrentQuestionMcq)
                    _buildMcqOptions(provider)
                  else if (provider.isCurrentQuestionSpeaking)
                    _buildSpeakingTask(provider),
                ],
              ),
            ),
          ),
          _buildNavigationControls(context, provider),
        ],
      ),
    );
  }

  Widget _buildProgressSection(TProvider provider) {
    final currentQuestion = provider.currentQuestionIndex + 1;
    final totalQuestions = provider.totalQuestions;
    final progress = provider.progress;
    final progressPercent = (progress * 100).toInt();

    return Semantics(
      label:
          'Question $currentQuestion of $totalQuestions. Progress: $progressPercent percent',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Text(
                'Question $currentQuestion / $totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                duration: AppAnimations.normal,
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSection(TProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    if (_previousQuestionIndex != provider.currentQuestionIndex) {
      _previousQuestionIndex = provider.currentQuestionIndex;
      _questionAnimationController.forward(from: 0.0);
      _isRecording = false;
      _recordingSeconds = 0;
    }

    final questionNum = provider.currentQuestionIndex + 1;
    final totalQuestions = provider.totalQuestions;
    final questionTypeLabel = _config.questionTypeLabel(question);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Focus(
          focusNode: _questionFocusNode,
          child: Semantics(
            label:
                'Question $questionNum of $totalQuestions. $questionTypeLabel. ${_config.prompt(question)}',
            readOnly: true,
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _config
                          .questionTypeColor(question)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      questionTypeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _config.questionTypeColor(question),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  if (_config.audioText(question) != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.volume_up,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              _config.audioText(question) ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                  ],
                  ExcludeSemantics(
                    child: Text(
                      _config.prompt(question),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMcqOptions(TProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final options = _config.options(question);
    if (options == null) return const SizedBox.shrink();

    final selectedAnswer = provider.selectedMcqAnswer;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: List.generate(
            options.length,
            (index) => _buildOptionTile(
              context: context,
              option: options[index],
              index: index,
              isSelected: selectedAnswer == index,
              onTap: () => provider.selectMcqAnswer(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String option,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final optionLabel = String.fromCharCode(65 + index);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: Semantics(
          button: true,
          selected: isSelected,
          label: 'Option $optionLabel: $option',
          hint: isSelected ? 'Selected' : 'Tap to select',
          child: AnimatedScale(
            scale: isSelected ? 1.02 : 1.0,
            duration: AppAnimations.fast,
            child: Material(
              color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              elevation: isSelected ? 2 : 1,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                focusColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingM,
                  ),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: AnimatedContainer(
                          duration: AppAnimations.normal,
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: ExcludeSemantics(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakingTask(TProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final speakingResult = provider.currentSpeakingResult;
    final hasRecorded = speakingResult != null;
    final resultData = speakingResult != null
        ? _config.speakingResultViewData(speakingResult)
        : null;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        _config.speakingInstruction,
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Semantics(
                button: true,
                label: _isRecording
                    ? 'Stop recording. Recording for $_recordingSeconds seconds'
                    : hasRecorded
                    ? 'Re-record your response'
                    : 'Start recording your response',
                child: GestureDetector(
                  onTap: () => _toggleRecording(provider, question),
                  child: AnimatedContainer(
                    duration: AppAnimations.normal,
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? AppTheme.incorrectColor
                          : hasRecorded
                          ? AppTheme.correctColor
                          : AppTheme.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isRecording
                                      ? AppTheme.incorrectColor
                                      : AppTheme.primaryColor)
                                  .withValues(alpha: 0.3),
                          blurRadius: _isRecording ? 20 : 10,
                          spreadRadius: _isRecording ? 5 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording
                          ? Icons.stop
                          : hasRecorded
                          ? Icons.refresh
                          : Icons.mic,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              if (_isRecording) ...[
                Text(
                  'Recording... $_recordingSeconds s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.incorrectColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                const Text(
                  'Tap to stop',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ] else if (hasRecorded && resultData != null) ...[
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.correctColor,
                  size: 32,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Recorded! Score: ${resultData.score}/${resultData.maxScore}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.correctColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  resultData.feedback,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_config.showRecognizedText &&
                    resultData.recognizedText != null &&
                    resultData.recognizedText!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your response:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          resultData.recognizedText!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          '${resultData.wordCount} words',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!_config.showRecognizedText) ...[
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    '${resultData.wordCount} words',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingM),
                TextButton.icon(
                  onPressed: () => _toggleRecording(provider, question),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Record Again'),
                ),
              ] else ...[
                const Text(
                  'Tap to start recording',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _toggleRecording(TProvider provider, TQuestion question) {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });

      final mockText = _config.mockSpeechText(_recordingSeconds);
      final result = _config.createSpeakingResult(
        taskId: _config.questionId(question),
        prompt: _config.prompt(question),
        recognizedText: mockText,
      );

      provider.recordSpeakingResult(result);
    } else {
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _startRecordingTimer(provider, question);
    }
  }

  void _startRecordingTimer(TProvider provider, TQuestion question) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) return false;
      setState(() {
        _recordingSeconds++;
      });

      if (_recordingSeconds >= _config.maxRecordingSeconds) {
        if (_config.autoStopRecording) {
          _toggleRecording(provider, question);
        }
        return false;
      }

      return true;
    });
  }

  Widget _buildNavigationControls(BuildContext context, TProvider provider) {
    final canProceed = provider.canProceed;
    final isLastQuestion = provider.isLastQuestion;
    final buttonText = isLastQuestion ? 'Submit Test' : 'Next';
    final semanticLabel = canProceed
        ? (isLastQuestion
              ? 'Submit test and view results'
              : 'Go to next question')
        : 'Please answer the question to continue';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Skip this question',
              child: OutlinedButton(
                onPressed: () => _handleSkip(context, provider),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                ),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Semantics(
                button: true,
                enabled: canProceed,
                label: semanticLabel,
                child: AnimatedScale(
                  scale: canProceed ? 1.0 : 0.98,
                  duration: AppAnimations.normal,
                  child: ElevatedButton(
                    onPressed: canProceed
                        ? () => _handleNext(context, provider)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canProceed
                          ? AppTheme.primaryColor
                          : Colors.grey[400],
                      disabledBackgroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                    ),
                    child: ExcludeSemantics(
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSkip(BuildContext context, TProvider provider) {
    provider.skipQuestion();

    if (provider.isLastQuestion) {
      if (_config.submitOnSkipLast) {
        _submitTest(context, provider);
      }
      return;
    }

    provider.nextQuestion();
    _announceQuestionChange(context, provider);
  }

  Future<void> _handleNext(BuildContext context, TProvider provider) async {
    if (provider.isLastQuestion) {
      await _submitTest(context, provider);
    } else {
      provider.nextQuestion();
      _announceQuestionChange(context, provider);
    }
  }

  void _announceQuestionChange(BuildContext context, TProvider provider) {
    final question = provider.currentQuestion;

    if (question != null && context.mounted) {
      _questionFocusNode.requestFocus();
    }
  }

  Future<void> _submitTest(BuildContext context, TProvider provider) async {
    if (provider.isLoading) {
      return;
    }

    try {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );

      await provider.submitTest();

      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (e) {
          AppLogger.error('Error closing loading dialog: $e');
        }
      }

      if (context.mounted &&
          provider.error != null &&
          provider.testResult != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry Save',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await provider.retrySubmitTest();
                  if (context.mounted && provider.error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Results saved successfully!'),
                        backgroundColor: AppTheme.correctColor,
                      ),
                    );
                  }
                } catch (e) {
                  AppLogger.debug('Retry save failed: $e');
                }
              },
            ),
          ),
        );
      }

      if (context.mounted && provider.testResult != null) {
        try {
          await Navigator.of(context).pushReplacementNamed(
            _config.resultRoute,
            arguments: provider.testResult,
          );
        } catch (navError) {
          ErrorHandler.logError(
            'FinalTestScreen._submitTest - Navigation',
            navError,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Test completed!'),
                backgroundColor: AppTheme.correctColor,
                duration: Duration(seconds: 4),
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to calculate test results. Please try again.',
            ),
            backgroundColor: AppTheme.incorrectColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _submitTest(context, provider),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('FinalTestScreen._submitTest', e, stackTrace);

      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${ErrorHandler.getUserMessage(e)}'),
            backgroundColor: AppTheme.incorrectColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _submitTest(context, provider),
            ),
          ),
        );
      }
    }
  }
}

const List<String> _phase4SampleWords = [
  'I',
  'like',
  'to',
  'talk',
  'about',
  'my',
  'daily',
  'routine',
  'Every',
  'morning',
  'I',
  'wake',
  'up',
  'early',
  'and',
  'have',
  'breakfast',
  'Then',
  'I',
  'go',
  'to',
  'work',
  'or',
  'school',
  'In',
  'the',
  'evening',
  'I',
  'spend',
  'time',
  'with',
  'family',
  'I',
  'enjoy',
  'reading',
  'books',
  'and',
  'watching',
  'movies',
  'On',
  'weekends',
  'I',
  'like',
  'to',
  'relax',
  'and',
  'meet',
  'friends',
  'We',
  'often',
  'go',
  'shopping',
  'or',
  'eat',
  'out',
  'This',
  'is',
  'how',
  'I',
  'spend',
  'my',
  'time',
];

String _buildPhase4MockSpeechText(int seconds) {
  final wordCount = (seconds * 2).clamp(0, 60);
  if (wordCount == 0) return '';

  final result = <String>[];
  for (int i = 0; i < wordCount && i < _phase4SampleWords.length; i++) {
    result.add(_phase4SampleWords[i]);
  }

  return result.join(' ');
}

String _buildPhase5MockSpeechText(int seconds) {
  return 'This is a mock response for testing purposes. The actual implementation would use '
      'speech-to-text to capture the user response and score it based on word count and clarity.';
}
