import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '../providers/phase2_final_test_provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';
import 'phase2_final_test_result_screen.dart';

/// Phase 2 Final Test Screen
/// Displays a 25-question test covering all Phase 2 units (Units 7-11)
/// Requirements: 1.2, 1.3, 3.1-3.10, 8.1-8.8
class Phase2FinalTestScreen extends StatefulWidget {
  const Phase2FinalTestScreen({super.key});

  @override
  State<Phase2FinalTestScreen> createState() => _Phase2FinalTestScreenState();
}

class _Phase2FinalTestScreenState extends State<Phase2FinalTestScreen>
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
    final provider = context.read<Phase2FinalTestProvider>();
    
    // Check if test can be taken (all lessons mastered or development mode)
    final canTake = AppConfig.isDevelopmentMode || await provider.canTakeTest();
    
    if (!canTake) {
      // Don't start test if lessons not mastered
      return;
    }
    
    try {
      await provider.startTest();
    } catch (e) {
      // Error is handled by provider and displayed in UI
      print('Test initialization failed: $e');
    }
  }

  Future<void> _retryInitializeTest() async {
    try {
      await context.read<Phase2FinalTestProvider>().retryStartTest();
    } catch (e) {
      // Error is handled by provider and displayed in UI
      print('Test retry failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<Phase2FinalTestProvider>(
        builder: (context, provider, child) {
          // Handle loading state
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle locked state (lessons not mastered)
          return FutureBuilder<bool>(
            future: provider.canTakeTest(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              // In development mode, always allow access
              final canTake = AppConfig.isDevelopmentMode || (snapshot.data ?? false);
              if (!canTake) {
                return _buildLockedState(context);
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
          );
        },
      ),
    );
  }

  /// Build AppBar with title and subtitle
  /// Requirement: 1.2, 1.3, 8.1, 8.2
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Semantics(
        label: 'Phase 2 Final Test, Units 7 to 11, 25 Questions',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Phase 2 – Final Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Units 7–11 • 25 Questions',
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

  /// Build locked state UI when lessons not mastered
  /// Requirement: 1.4, 7.5
  Widget _buildLockedState(BuildContext context) {
    return Semantics(
      label: 'Test locked. Please master all Phase 2 lessons before taking the final test.',
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
              const Text(
                'Please master all Phase 2 lessons before taking the final test',
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

  /// Build error state UI with retry mechanism
  /// Requirement: 1.4, 1.5
  Widget _buildErrorState(BuildContext context, Phase2FinalTestProvider provider) {
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
              const Text(
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
  Widget _buildTestContent(BuildContext context, Phase2FinalTestProvider provider) {
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
  /// Requirement: 3.2, 3.3, 8.5
  Widget _buildProgressSection(Phase2FinalTestProvider provider) {
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
  /// Requirement: 3.4, 8.1, 8.2, 8.6
  Widget _buildQuestionSection(Phase2FinalTestProvider provider) {
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
  Widget _buildAnswerOptions(Phase2FinalTestProvider provider) {
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
  /// Requirement: 8.3, 8.4, 8.7
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
          scale: isSelected ? 1.02 : 1.0,
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

  /// Build navigation controls (Skip and Next buttons) with animation
  /// Requirement: 3.6, 3.7, 3.8, 3.9, 3.10
  Widget _buildNavigationControls(
    BuildContext context,
    Phase2FinalTestProvider provider,
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
        child: Row(
          children: [
            // Skip button (optional)
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
            
            // Next button
            Expanded(
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
          ],
        ),
      ),
    );
  }

  /// Handle skip button press
  /// Requirement: 3.8
  void _handleSkip(
    BuildContext context,
    Phase2FinalTestProvider provider,
  ) {
    provider.skipQuestion();
    
    if (provider.isLastQuestion) {
      // If last question, submit test
      _submitTest(context, provider);
    } else {
      // Move to next question
      provider.nextQuestion();
      
      // Announce question change to screen readers
      final nextQuestionNum = provider.currentQuestionIndex + 1;
      final totalQuestions = provider.totalQuestions;
      final question = provider.currentQuestion;
      
      if (question != null && context.mounted) {
        SemanticsService.announce(
          'Question $nextQuestionNum of $totalQuestions. ${question.promptEn}',
          TextDirection.ltr,
        );
      }
    }
  }

  /// Handle next button press
  /// Requirement: 3.8, 3.9, 3.10
  Future<void> _handleNext(
    BuildContext context,
    Phase2FinalTestProvider provider,
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
        SemanticsService.announce(
          'Question $nextQuestionNum of $totalQuestions. ${question.promptEn}',
          TextDirection.ltr,
        );
      }
    }
  }

  /// Submit test and navigate to result screen
  /// Handles storage failures gracefully and still shows results
  /// Implements comprehensive error handling with retry mechanism
  Future<void> _submitTest(
    BuildContext context,
    Phase2FinalTestProvider provider,
  ) async {
    // Prevent multiple simultaneous submissions
    if (provider.isLoading) {
      print('Submission already in progress');
      return;
    }

    try {
      // Show loading indicator with error handling
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Submit test
      await provider.submitTest();

      // Close loading indicator safely
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (e) {
          print('Error closing loading dialog: $e');
        }
      }

      // Show warning if there was a storage error but results were calculated
      if (context.mounted && provider.error != null && provider.testResult != null) {
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
                  print('Retry save failed: $e');
                }
              },
            ),
          ),
        );
      }

      // Navigate to result screen if we have results
      if (context.mounted && provider.testResult != null) {
        try {
          // Navigate to result screen
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => Phase2FinalTestResultScreen(
                testResult: provider.testResult!,
              ),
            ),
          );
          
          // After returning from result screen, pop back to lesson list
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } catch (navError) {
          print('Navigation error: $navError');
          ErrorHandler.logError('Phase2FinalTestScreen._submitTest - Navigation', navError);
          
          // Fallback: show results in snackbar and go back
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
        // No results available - show error with retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to calculate test results. Please try again.'),
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
      ErrorHandler.logError('Phase2FinalTestScreen._submitTest', e, stackTrace);
      
      // Close loading indicator if still showing
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          print('Error closing dialog after error: $popError');
        }
      }

      // Show error message with retry option
      if (context.mounted) {
        final errorMessage = provider.error ?? ErrorHandler.getUserMessage(e);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit test: $errorMessage'),
            backgroundColor: AppTheme.incorrectColor,
            duration: const Duration(seconds: 6),
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
