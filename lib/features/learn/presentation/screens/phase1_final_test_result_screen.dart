import 'package:flutter/material.dart';
import '../../data/models/test_result.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/animations.dart';
import 'phase1_final_test_review_screen.dart';

/// Phase 1 Final Test Result Screen
/// Displays test score, accuracy, pass/fail status, and action buttons
/// Requirements: 4.1-4.8, 8.1-8.2
class Phase1FinalTestResultScreen extends StatefulWidget {
  final TestResult testResult;

  const Phase1FinalTestResultScreen({
    super.key,
    required this.testResult,
  });

  @override
  State<Phase1FinalTestResultScreen> createState() => _Phase1FinalTestResultScreenState();
}

class _Phase1FinalTestResultScreenState extends State<Phase1FinalTestResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for result screen entry
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Build AppBar with back button and title
  /// Requirement: 4.1, 8.8
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Semantics(
        button: true,
        label: 'Back to test',
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      title: const Text(
        'Test Results',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build main body content with animations
  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacingL),
              
              // Score display section with scale animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildScoreSection(),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Status message with delayed fade
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.easeIn,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: _buildStatusMessage(),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Action buttons with delayed fade
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.easeIn,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: _buildActionButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build score display section with icon, title, score, and accuracy
  /// Requirement: 4.1, 4.2, 4.3, 8.1, 8.2, 8.8
  Widget _buildScoreSection() {
    final passed = widget.testResult.passed;
    final iconColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final scoreColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final statusText = passed ? 'Passed' : 'Failed';
    
    final semanticLabel = 'Test $statusText. You scored ${widget.testResult.correctAnswers} out of ${widget.testResult.totalQuestions}. Accuracy: ${widget.testResult.accuracy.toStringAsFixed(1)} percent';

    return Semantics(
      label: semanticLabel,
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            // Success/Failure Icon with pulse animation
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  size: 80,
                  color: iconColor,
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Completion Title
            const ExcludeSemantics(
              child: Text(
                'Phase 1 Final Test – Completed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Score Display with count-up animation
            ExcludeSemantics(
              child: TweenAnimationBuilder<int>(
                duration: const Duration(milliseconds: 800),
                tween: IntTween(begin: 0, end: widget.testResult.correctAnswers),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    'Score: $value / ${widget.testResult.totalQuestions}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Accuracy Display with count-up animation
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0.0, end: widget.testResult.accuracy),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    'Accuracy: ${value.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build status message based on pass/fail
  /// Requirement: 4.4, 4.5, 8.8
  Widget _buildStatusMessage() {
    final passed = widget.testResult.passed;
    final message = passed
        ? 'You have mastered the entire Phase 1 foundation'
        : 'Keep practicing to master Phase 1 content';
    final messageColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;

    return Semantics(
      label: message,
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: passed
              ? const Color(0xFFE8F5E9) // Light green
              : const Color(0xFFFFEBEE), // Light red
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: messageColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                passed ? Icons.emoji_events : Icons.info_outline,
                color: messageColor,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: messageColor,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons section
  /// Requirement: 4.6, 4.7, 4.8
  Widget _buildActionButtons(BuildContext context) {
    final passed = widget.testResult.passed;
    final hasMistakes = widget.testResult.incorrectQuestionDetails.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Review Mistakes button (always visible if mistakes exist)
        if (hasMistakes) ...[
          _buildReviewMistakesButton(context),
          const SizedBox(height: AppTheme.spacingM),
        ],
        
        // Continue to Phase 2 button (only if passed)
        if (passed) ...[
          _buildContinueToPhase2Button(context),
        ],
        
        // Retry Test button (only if failed)
        if (!passed) ...[
          _buildRetryTestButton(context),
        ],
      ],
    );
  }

  /// Build Review Mistakes button with press animation
  /// Requirement: 4.6, 8.8
  Widget _buildReviewMistakesButton(BuildContext context) {
    final mistakeCount = widget.testResult.incorrectQuestionDetails.length;
    
    return Semantics(
      button: true,
      label: 'Review $mistakeCount mistake${mistakeCount == 1 ? '' : 's'}',
      child: AnimatedScale(
        scale: 1.0,
        duration: AppAnimations.fast,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToReviewScreen(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              side: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.rate_review),
          label: const Text(
            'Review Mistakes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build Continue to Phase 2 button with press animation
  /// Requirement: 4.7, 8.8
  Widget _buildContinueToPhase2Button(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue to Phase 2',
      hint: 'Proceed to the next learning phase',
      child: AnimatedScale(
        scale: 1.0,
        duration: AppAnimations.fast,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToPhase2(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.correctColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.arrow_forward),
          label: const Text(
            'Continue to Phase 2',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build Retry Test button with press animation
  /// Requirement: 4.8, 8.8
  Widget _buildRetryTestButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retry test',
      hint: 'Take the test again to improve your score',
      child: AnimatedScale(
        scale: 1.0,
        duration: AppAnimations.fast,
        child: ElevatedButton.icon(
          onPressed: () => _retryTest(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.refresh),
          label: const Text(
            'Retry Test',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to review screen with smooth transition
  /// Requirement: 4.6
  void _navigateToReviewScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Phase1FinalTestReviewScreen(
          incorrectAnswers: widget.testResult.incorrectQuestionDetails,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// Navigate to Phase 2
  /// Requirement: 4.7
  void _navigateToPhase2(BuildContext context) {
    // TODO: Navigate to Phase 2 when implemented
    // For now, return to home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phase 2 will be unlocked soon!'),
        backgroundColor: AppTheme.correctColor,
      ),
    );
  }

  /// Retry test
  /// Requirement: 4.8
  void _retryTest(BuildContext context) {
    // Pop back to test screen to retry
    Navigator.of(context).pop();
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting a new test...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
