import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/phase_config.dart';
import '../../domain/entities/test_question.dart';
import '../../domain/repositories/test_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../services/gating_service.dart';
import '../providers/mcq_final_test_provider.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/logging/app_logger.dart';

typedef QuestionLabelBuilder =
    String Function(
      TestQuestion question,
      int questionNumber,
      int totalQuestions,
    );

typedef AnnouncementLabelBuilder =
    String Function(
      TestQuestion question,
      int questionNumber,
      int totalQuestions,
    );

class McqFinalTestScreenConfig {
  final PhaseConfig phaseConfig;
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final bool checkAccess;
  final String lockedDescription;
  final String lockedSemanticsLabel;
  final bool showSkipButton;
  final bool useSlideAnimation;
  final bool useFocusTraversal;
  final bool useQuestionFocus;
  final bool useLiveRegion;
  final bool useSemanticsAnnouncement;
  final double selectedScale;
  final String resultRoute;
  final bool replaceOnResult;
  final bool popAfterResult;
  final bool showRetrySaveAction;
  final QuestionLabelBuilder questionSemanticsLabel;
  final AnnouncementLabelBuilder announcementLabel;

  const McqFinalTestScreenConfig({
    required this.phaseConfig,
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
    required this.checkAccess,
    required this.lockedDescription,
    required this.lockedSemanticsLabel,
    required this.showSkipButton,
    required this.useSlideAnimation,
    required this.useFocusTraversal,
    required this.useQuestionFocus,
    required this.useLiveRegion,
    required this.useSemanticsAnnouncement,
    required this.selectedScale,
    required this.resultRoute,
    required this.replaceOnResult,
    required this.popAfterResult,
    required this.showRetrySaveAction,
    required this.questionSemanticsLabel,
    required this.announcementLabel,
  });

  static McqFinalTestScreenConfig phase1() {
    return McqFinalTestScreenConfig(
      phaseConfig: PhaseConfig.phase1,
      title: 'Phase 1 – Final Test',
      subtitle: 'Covering Lessons 1 to 6',
      semanticsLabel: 'Phase 1 Final Test, Covering Lessons 1 to 6',
      checkAccess: false,
      lockedDescription: AppStrings.finalTestLockedDescription(1),
      lockedSemanticsLabel:
          'Test locked. Please master all Phase 1 lessons before taking the final test.',
      showSkipButton: false,
      useSlideAnimation: false,
      useFocusTraversal: false,
      useQuestionFocus: false,
      useLiveRegion: false,
      useSemanticsAnnouncement: true,
      selectedScale: 1.0,
      resultRoute: AppRoutes.phase1FinalTestResult,
      replaceOnResult: true,
      popAfterResult: false,
      showRetrySaveAction: false,
      questionSemanticsLabel: (question, _, _) =>
          'Question: ${question.promptEn}',
      announcementLabel: (question, number, total) =>
          'Question $number of $total. ${question.promptEn}',
    );
  }

  static McqFinalTestScreenConfig phase2() {
    return McqFinalTestScreenConfig(
      phaseConfig: PhaseConfig.phase2,
      title: 'Phase 2 – Final Test',
      subtitle: 'Units 7–11 • 25 Questions',
      semanticsLabel: 'Phase 2 Final Test, Units 7 to 11, 25 Questions',
      checkAccess: true,
      lockedDescription: AppStrings.finalTestLockedDescription(2),
      lockedSemanticsLabel:
          'Test locked. Please master all Phase 2 lessons before taking the final test.',
      showSkipButton: true,
      useSlideAnimation: false,
      useFocusTraversal: false,
      useQuestionFocus: false,
      useLiveRegion: false,
      useSemanticsAnnouncement: true,
      selectedScale: 1.02,
      resultRoute: AppRoutes.phase2FinalTestResult,
      replaceOnResult: false,
      popAfterResult: true,
      showRetrySaveAction: true,
      questionSemanticsLabel: (question, _, _) =>
          'Question: ${question.promptEn}',
      announcementLabel: (question, number, total) =>
          'Question $number of $total. ${question.promptEn}',
    );
  }

  static McqFinalTestScreenConfig phase3() {
    return McqFinalTestScreenConfig(
      phaseConfig: PhaseConfig.phase3,
      title: 'Phase 3 – Final Test',
      subtitle: 'Real-Life Communication Check',
      semanticsLabel: 'Phase 3 Final Test, Real-Life Communication Check',
      checkAccess: true,
      lockedDescription: AppStrings.finalTestLockedDescription(3),
      lockedSemanticsLabel:
          'Test locked. Please master all Phase 3 lessons before taking the final test.',
      showSkipButton: true,
      useSlideAnimation: true,
      useFocusTraversal: true,
      useQuestionFocus: true,
      useLiveRegion: true,
      useSemanticsAnnouncement: false,
      selectedScale: 1.02,
      resultRoute: AppRoutes.phase3FinalTestResult,
      replaceOnResult: false,
      popAfterResult: true,
      showRetrySaveAction: true,
      questionSemanticsLabel: (question, number, total) =>
          'Question $number of $total: ${question.promptEn}',
      announcementLabel: (question, number, total) =>
          'Question $number of $total. ${question.promptEn}',
    );
  }
}

class McqFinalTestScreen extends StatelessWidget {
  final McqFinalTestScreenConfig config;

  const McqFinalTestScreen({super.key, required this.config});

  factory McqFinalTestScreen.phase1({Key? key}) {
    return McqFinalTestScreen(
      key: key,
      config: McqFinalTestScreenConfig.phase1(),
    );
  }

  factory McqFinalTestScreen.phase2({Key? key}) {
    return McqFinalTestScreen(
      key: key,
      config: McqFinalTestScreenConfig.phase2(),
    );
  }

  factory McqFinalTestScreen.phase3({Key? key}) {
    return McqFinalTestScreen(
      key: key,
      config: McqFinalTestScreenConfig.phase3(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => McqFinalTestProvider(
        config: config.phaseConfig,
        testRepository: context.read<TestRepository>(),
        progressRepository: context.read<ProgressRepository>(),
        gatingService: context.read<GatingService>(),
      ),
      child: _McqFinalTestScreenBody(config: config),
    );
  }
}

class _McqFinalTestScreenBody extends StatefulWidget {
  final McqFinalTestScreenConfig config;

  const _McqFinalTestScreenBody({required this.config});

  @override
  State<_McqFinalTestScreenBody> createState() =>
      _McqFinalTestScreenBodyState();
}

class _McqFinalTestScreenBodyState extends State<_McqFinalTestScreenBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late Animation<double> _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  int _previousQuestionIndex = -1;
  final FocusNode _questionFocusNode = FocusNode();
  bool _isRetryingInitialize = false;

  McqFinalTestScreenConfig get _config => widget.config;

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

    if (_config.useSlideAnimation) {
      _slideAnimation =
          Tween<Offset>(
            begin: const Offset(0.1, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _questionAnimationController,
              curve: Curves.easeOutCubic,
            ),
          );
    }

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
    final provider = context.read<McqFinalTestProvider>();

    if (_config.checkAccess) {
      final canTake = AppConfig.devMode || await provider.canTakeTest();
      if (!canTake) {
        return;
      }
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
      await context.read<McqFinalTestProvider>().retryStartTest();
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
      body: Consumer<McqFinalTestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoadingState(message: 'Loading test...');
          }

          if (_config.checkAccess) {
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

                return _buildContent(context, provider);
              },
            );
          }

          return _buildContent(context, provider);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, McqFinalTestProvider provider) {
    if (provider.error != null) {
      return _buildErrorState(context, provider);
    }

    if (provider.questions.isEmpty) {
      return const AppEmptyState(
        title: AppStrings.noQuestions,
        subtitle: AppStrings.tryAgainMoment,
      );
    }

    return _buildTestContent(context, provider);
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
                AppStrings.testLocked,
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
                  label: const Text(AppStrings.goBack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, McqFinalTestProvider provider) {
    return Semantics(
      label: 'Error loading test. ${provider.error}. Please retry.',
      child: AppErrorState(
        message: provider.error ?? AppStrings.unableToLoadTest,
        retryLabel:
            _isRetryingInitialize ? AppStrings.retrying : AppStrings.retry,
        onRetry: _isRetryingInitialize ? () {} : _retryInitializeTest,
      ),
    );
  }

  Widget _buildTestContent(
    BuildContext context,
    McqFinalTestProvider provider,
  ) {
    final content = Column(
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
                _buildAnswerOptions(provider),
              ],
            ),
          ),
        ),
        _buildNavigationControls(context, provider),
      ],
    );

    if (_config.useFocusTraversal) {
      return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: content,
      );
    }

    return content;
  }

  Widget _buildProgressSection(McqFinalTestProvider provider) {
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

  Widget _buildQuestionSection(McqFinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    if (_previousQuestionIndex != provider.currentQuestionIndex) {
      _previousQuestionIndex = provider.currentQuestionIndex;
      _questionAnimationController.forward(from: 0.0);
    }

    final questionNumber = provider.currentQuestionIndex + 1;
    final totalQuestions = provider.totalQuestions;
    final semanticsLabel = _config.questionSemanticsLabel(
      question,
      questionNumber,
      totalQuestions,
    );

    final content = Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ExcludeSemantics(
        child: Text(
          question.promptEn,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );

    final semanticsWidget = Semantics(
      label: semanticsLabel,
      readOnly: true,
      liveRegion: _config.useLiveRegion,
      child: content,
    );

    final focusWrapper = _config.useQuestionFocus
        ? Focus(focusNode: _questionFocusNode, child: semanticsWidget)
        : semanticsWidget;

    return _wrapAnimated(focusWrapper);
  }

  Widget _buildAnswerOptions(McqFinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final selectedAnswer = provider.selectedAnswer;

    return _wrapAnimated(
      Column(
        children: List.generate(
          question.options.length,
          (index) => _buildOptionTile(
            context: context,
            option: question.options[index],
            index: index,
            isSelected: selectedAnswer == index,
            onTap: () => provider.selectAnswer(index),
          ),
        ),
      ),
    );
  }

  Widget _wrapAnimated(Widget child) {
    if (_config.useSlideAnimation && _slideAnimation != null) {
      return SlideTransition(
        position: _slideAnimation!,
        child: FadeTransition(opacity: _fadeAnimation, child: child),
      );
    }

    return FadeTransition(opacity: _fadeAnimation, child: child);
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String option,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final optionLabel = String.fromCharCode(65 + index);

    final tile = Semantics(
      button: true,
      selected: isSelected,
      label: 'Option $optionLabel: $option',
      hint: isSelected ? 'Selected' : 'Tap to select',
      child: AnimatedScale(
        scale: isSelected ? _config.selectedScale : 1.0,
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
            focusColor: _config.useFocusTraversal
                ? AppTheme.primaryColor.withValues(alpha: 0.12)
                : null,
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
    );

    if (_config.useFocusTraversal) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
        child: FocusTraversalOrder(
          order: NumericFocusOrder(index.toDouble()),
          child: tile,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: tile,
    );
  }

  Widget _buildNavigationControls(
    BuildContext context,
    McqFinalTestProvider provider,
  ) {
    final canProceed = provider.canProceed;
    final isLastQuestion = provider.isLastQuestion;
    final buttonText =
        isLastQuestion ? AppStrings.submitTest : AppStrings.next;
    final semanticLabel = canProceed
        ? (isLastQuestion
              ? 'Submit test and view results'
              : 'Go to next question')
        : 'Please answer the question to continue';

    final nextButton = Semantics(
      button: true,
      enabled: canProceed,
      label: semanticLabel,
      child: AnimatedScale(
        scale: canProceed ? 1.0 : 0.98,
        duration: AppAnimations.normal,
        child: ElevatedButton(
          onPressed: canProceed ? () => _handleNext(context, provider) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canProceed
                ? AppTheme.primaryColor
                : Colors.grey[400],
            disabledBackgroundColor: Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
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
    );

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
        child: _config.showSkipButton
            ? Row(
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
                      child: const Text(AppStrings.skip),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(child: nextButton),
                ],
              )
            : SizedBox(width: double.infinity, child: nextButton),
      ),
    );
  }

  void _handleSkip(BuildContext context, McqFinalTestProvider provider) {
    provider.skipQuestion();

    if (provider.isLastQuestion) {
      _submitTest(context, provider);
      return;
    }

    provider.nextQuestion();
    _announceQuestionChange(provider);
  }

  Future<void> _handleNext(
    BuildContext context,
    McqFinalTestProvider provider,
  ) async {
    if (provider.isLastQuestion) {
      await _submitTest(context, provider);
      return;
    }

    provider.nextQuestion();
    _announceQuestionChange(provider);
  }

  void _announceQuestionChange(McqFinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null || !context.mounted) {
      return;
    }

    if (_config.useQuestionFocus) {
      _questionFocusNode.requestFocus();
      return;
    }

    if (_config.useSemanticsAnnouncement) {
      final questionNumber = provider.currentQuestionIndex + 1;
      final totalQuestions = provider.totalQuestions;
      final announcement = _config.announcementLabel(
        question,
        questionNumber,
        totalQuestions,
      );
      SemanticsService.sendAnnouncement(
        View.of(context),
        announcement,
        TextDirection.ltr,
      );
    }
  }

  Future<void> _submitTest(
    BuildContext context,
    McqFinalTestProvider provider,
  ) async {
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
        final action = _config.showRetrySaveAction
            ? SnackBarAction(
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
              )
            : null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
            action: action,
          ),
        );
      }

      if (context.mounted && provider.testResult != null) {
        try {
          if (_config.replaceOnResult) {
            await Navigator.of(context).pushReplacementNamed(
              _config.resultRoute,
              arguments: provider.testResult,
            );
          } else {
            await Navigator.of(
              context,
            ).pushNamed(_config.resultRoute, arguments: provider.testResult);
          }

          if (_config.popAfterResult && context.mounted) {
            Navigator.of(context).pop();
          }
        } catch (navError) {
          ErrorHandler.logError(
            'McqFinalTestScreen._submitTest - Navigation',
            navError,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Test completed! Score: ${provider.testResult!.correctAnswers}/${provider.testResult!.totalQuestions}',
                ),
                backgroundColor: AppTheme.correctColor,
                duration: const Duration(seconds: 4),
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
              label: AppStrings.retry,
              textColor: Colors.white,
              onPressed: () => _submitTest(context, provider),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('McqFinalTestScreen._submitTest', e, stackTrace);

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
              label: AppStrings.retry,
              textColor: Colors.white,
              onPressed: () => _submitTest(context, provider),
            ),
          ),
        );
      }
    }
  }
}
