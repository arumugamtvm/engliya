import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '../providers/final_test_provider.dart';
import '../../../../app/theme.dart';
import '../../../../app/routes.dart';
import '../../../../core/utils/animations.dart';

/// Phase 1 Final Test Screen
/// Displays a 20-question test covering all Phase 1 lessons
/// Requirements: 1.2, 1.3, 3.1-3.9, 8.1-8.8
class Phase1FinalTestScreen extends StatefulWidget {
  const Phase1FinalTestScreen({super.key});

  @override
  State<Phase1FinalTestScreen> createState() => _Phase1FinalTestScreenState();
}

class _Phase1FinalTestScreenState extends State<Phase1FinalTestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late Animation<double> _fadeAnimation;
  int _previousQuestionIndex = -1; // Start at -1 so first question triggers animation
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for question transitions
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
    
    // Start animation immediately for first question
    _questionAnimationController.forward();
    
    // Initialize test on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTest();
    });
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeTest() async {
    try {
      await context.read<FinalTestProvider>().startTest();
    } catch (e) {
      // Error is handled by provider and displayed in UI
      print('Test initialization failed: $e');
    }
  }

  Future<void> _retryInitializeTest() async {
    try {
      await context.read<FinalTestProvider>().retryStartTest();
    } catch (e) {
      // Error is handled by provider and displayed in UI
      print('Test retry failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<FinalTestProvider>(
        builder: (context, provider, child) {
          // Handle loading state
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle error state
          if (provider.error != null) {
            return _buildErrorState(context, provider);
          }

          // Handle empty state (no questions loaded)
          if (provider.questions.isEmpty) {
            return const Center(
              child: Text('No questions available'),
            );
          }

          // Display test content
          return _buildTestContent(context, provider);
        },
      ),
    );
  }

  /// Build AppBar with title and subtitle
  /// Requirement: 1.2, 1.3, 8.1, 8.2, 8.8
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Semantics(
        label: 'Phase 1 Final Test, Covering Lessons 1 to 6',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Phase 1 – Final Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Covering Lessons 1 to 6',
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

  /// Build error state UI with retry mechanism
  /// Requirement: 1.4, 7.4, 2.10, 8.8
  Widget _buildErrorState(BuildContext context, FinalTestProvider provider) {
    return Semantics(
      label: 'Error loading test. ${provider.error}. Please check your connection and try again.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.incorrectColor,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: AppTheme.bodyText1,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    button: true,
                    label: 'Retry loading test',
                    child: ElevatedButton.icon(
                      onPressed: () => _retryInitializeTest(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Semantics(
                    button: true,
                    label: 'Go back to previous screen',
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main test content
  Widget _buildTestContent(BuildContext context, FinalTestProvider provider) {
    return Column(
      children: [
        // Progress section
        _buildProgressSection(provider),
        
        // Question and options section (scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question display
                _buildQuestionSection(provider),
                
                const SizedBox(height: AppTheme.spacingL),
                
                // Answer options
                _buildAnswerOptions(provider),
              ],
            ),
          ),
        ),
        
        // Navigation controls
        _buildNavigationControls(context, provider),
      ],
    );
  }

  /// Build progress section with counter and progress bar
  /// Requirement: 3.2, 3.3, 8.5, 8.8
  Widget _buildProgressSection(FinalTestProvider provider) {
    final currentQuestion = provider.currentQuestionIndex + 1;
    final totalQuestions = provider.totalQuestions;
    final progress = provider.progress;
    final progressPercent = (progress * 100).toInt();

    return Semantics(
      label: 'Question $currentQuestion of $totalQuestions. Progress: $progressPercent percent',
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
            // Question counter
            ExcludeSemantics(
              child: Text(
                'Question $currentQuestion/$totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            
            // Animated progress bar
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                duration: AppAnimations.normal,
                curve: Curves.easeInOut,
                tween: Tween<double>(
                  begin: 0,
                  end: progress,
                ),
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

  /// Build question display section with fade animation
  /// Requirement: 3.4, 8.1, 8.2, 8.6, 8.8
  Widget _buildQuestionSection(FinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    // Trigger animation when question changes
    if (_previousQuestionIndex != provider.currentQuestionIndex) {
      _previousQuestionIndex = provider.currentQuestionIndex;
      _questionAnimationController.forward(from: 0.0);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        label: 'Question: ${question.promptEn}',
        readOnly: true,
        child: Container(
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
        ),
      ),
    );
  }

  /// Build answer options with radio buttons and fade animation
  /// Requirement: 3.5, 3.6, 3.7, 8.3, 8.4, 8.7
  Widget _buildAnswerOptions(FinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final selectedAnswer = provider.selectedAnswer;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
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

  /// Build individual option tile with press animation
  /// Requirement: 8.3, 8.4, 8.7, 8.8
  Widget _buildOptionTile({
    required BuildContext context,
    required String option,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: 'Option $optionLabel: $option',
        hint: isSelected ? 'Selected' : 'Tap to select',
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 1.0,
          duration: AppAnimations.fast,
          child: Material(
            color: isSelected
                ? const Color(0xFFE3F2FD) // Light blue for selected
                : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            elevation: isSelected ? 2 : 1,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 48, // Minimum touch target size
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingM,
                ),
                child: Row(
                  children: [
                    // Radio button with animation
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
                    
                    // Option text
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
    );
  }

  /// Build navigation controls (Next button) with animation
  /// Requirement: 3.6, 3.7, 3.8, 3.9, 8.8
  Widget _buildNavigationControls(
    BuildContext context,
    FinalTestProvider provider,
  ) {
    final canProceed = provider.canProceed;
    final isLastQuestion = provider.isLastQuestion;
    final buttonText = isLastQuestion ? 'Submit Test' : 'Next';
    final semanticLabel = canProceed
        ? (isLastQuestion ? 'Submit test and view results' : 'Go to next question')
        : 'Please select an answer to continue';

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
        child: SizedBox(
          width: double.infinity,
          child: Semantics(
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
          ),
        ),
      ),
    );
  }

  /// Handle next button press
  /// Requirement: 3.8, 3.9, 8.8
  Future<void> _handleNext(
    BuildContext context,
    FinalTestProvider provider,
  ) async {
    if (provider.isLastQuestion) {
      // Submit test and navigate to result screen
      await _submitTest(context, provider);
    } else {
      // Move to next question
      provider.nextQuestion();
      
      // Announce question change to screen readers
      final nextQuestionNum = provider.currentQuestionIndex + 1;
      final totalQuestions = provider.totalQuestions;
      final question = provider.currentQuestion;
      
      if (question != null && context.mounted) {
        // Use SemanticsService to announce the new question
        SemanticsService.announce(
          'Question $nextQuestionNum of $totalQuestions. ${question.promptEn}',
          TextDirection.ltr,
        );
      }
    }
  }

  /// Submit test and navigate to result screen
  /// Handles storage failures gracefully and still shows results
  Future<void> _submitTest(
    BuildContext context,
    FinalTestProvider provider,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Submit test
      await provider.submitTest();

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show warning if there was a storage error but results were calculated
      if (context.mounted && provider.error != null && provider.testResult != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Navigate to result screen if we have results
      if (context.mounted && provider.testResult != null) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.phase1FinalTestResult,
          arguments: provider.testResult,
        );
      } else if (context.mounted) {
        // No results available - show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to calculate test results. Please try again.'),
            backgroundColor: AppTheme.incorrectColor,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _submitTest(context, provider),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message with retry option
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit test: ${provider.error ?? e.toString()}'),
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
