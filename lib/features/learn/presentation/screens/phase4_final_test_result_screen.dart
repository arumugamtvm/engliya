import 'package:flutter/material.dart';
import '../../data/models/phase4_test_result.dart';
import '../../../../app/theme.dart';
import 'phase4_final_test_review_screen.dart';

/// Phase 4 Final Test Result Screen
/// Displays test score out of 24, percentage, pass/fail status, and action buttons
/// 
/// Requirements: 6.1, 6.2, 6.3, 6.4
class Phase4FinalTestResultScreen extends StatefulWidget {
  final Phase4TestResult testResult;

  const Phase4FinalTestResultScreen({
    super.key,
    required this.testResult,
  });

  @override
  State<Phase4FinalTestResultScreen> createState() => _Phase4FinalTestResultScreenState();
}

class _Phase4FinalTestResultScreenState extends State<Phase4FinalTestResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for result screen entry (400ms as per design)
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
              
              // Score breakdown section with delayed fade
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
                child: _buildScoreBreakdownSection(),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Action buttons with delayed fade
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
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

  /// Build score display section with icon, title, score, and percentage
  /// Requirement: 6.1
  Widget _buildScoreSection() {
    final passed = widget.testResult.passed;
    final iconColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final scoreColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final statusText = passed ? 'Passed' : 'Failed';
    
    final semanticLabel = 'Test $statusText. You scored ${widget.testResult.totalScore} out of ${widget.testResult.maxScore}. ${widget.testResult.percentage.toStringAsFixed(1)} percent';

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
                  passed ? Icons.celebration : Icons.cancel,
                  size: 80,
                  color: iconColor,
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Completion Title
            const ExcludeSemantics(
              child: Text(
                'Phase 4 Final Test Completed!',
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
                tween: IntTween(begin: 0, end: widget.testResult.totalScore),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    'Score: $value / ${widget.testResult.maxScore}',
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
            
            // Percentage Display with count-up animation
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0.0, end: widget.testResult.percentage),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    '${value.toStringAsFixed(1)}%',
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
  /// Requirement: 6.2, 6.3
  Widget _buildStatusMessage() {
    final passed = widget.testResult.passed;
    final statusEmoji = passed ? 'PASSED ✅' : 'NOT PASSED ❌';
    final message = passed
        ? 'Congratulations! You have mastered Phase 4.\nPhase 5 - Professional English is now unlocked!'
        : 'You are close! Review Phase 4 lessons and try again.\nYou need 18 points (75%) to pass.';
    final messageColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;

    return Semantics(
      label: '$statusEmoji. $message',
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
        child: Column(
          children: [
            ExcludeSemantics(
              child: Text(
                statusEmoji,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: messageColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            ExcludeSemantics(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: messageColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Phase 5 unlock badge for passed tests
            if (passed) ...[
              const SizedBox(height: AppTheme.spacingM),
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.masteredColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: AppTheme.masteredColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_open,
                        color: AppTheme.masteredColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        'Phase 5 Unlocked!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.masteredColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build score breakdown section showing MCQ and Speaking scores
  Widget _buildScoreBreakdownSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'Score Breakdown:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // MCQ Score
          _buildScoreBreakdownItem(
            'MCQ Questions',
            widget.testResult.mcqCorrect,
            Phase4TestResult.maxMcqScore,
            Icons.quiz,
          ),
          const SizedBox(height: AppTheme.spacingS),
          
          // Speaking Score
          _buildScoreBreakdownItem(
            'Speaking Tasks',
            widget.testResult.speakingScore,
            Phase4TestResult.maxSpeakingScore,
            Icons.mic,
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          const Divider(),
          const SizedBox(height: AppTheme.spacingS),
          
          // Total Score
          _buildScoreBreakdownItem(
            'Total Score',
            widget.testResult.totalScore,
            widget.testResult.maxScore,
            Icons.stars,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  /// Build individual score breakdown item
  Widget _buildScoreBreakdownItem(
    String label,
    int score,
    int maxScore,
    IconData icon, {
    bool isTotal = false,
  }) {
    final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0.0;
    Color performanceColor;
    
    if (percentage >= 75) {
      performanceColor = AppTheme.correctColor;
    } else if (percentage >= 50) {
      performanceColor = AppTheme.warningColor;
    } else {
      performanceColor = AppTheme.incorrectColor;
    }
    
    final semanticLabel = '$label: $score out of $maxScore. ${percentage.toStringAsFixed(0)} percent';

    return Semantics(
      label: semanticLabel,
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isTotal 
              ? performanceColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: isTotal
              ? Border.all(color: performanceColor.withValues(alpha: 0.5), width: 2)
              : null,
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: isTotal ? 24 : 20,
                color: isTotal ? performanceColor : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isTotal ? 18 : 16,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            
            ExcludeSemantics(
              child: Text(
                '$score / $maxScore',
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isTotal ? performanceColor : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Build action buttons section
  /// Requirement: 6.4
  Widget _buildActionButtons(BuildContext context) {
    final passed = widget.testResult.passed;
    final hasMistakes = widget.testResult.incorrectMcqAnswers.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Review Mistakes button (visible if mistakes exist)
        if (hasMistakes) ...[
          _buildReviewMistakesButton(context),
          const SizedBox(height: AppTheme.spacingM),
        ],
        
        // Continue button (only if passed)
        if (passed) ...[
          _buildContinueButton(context),
        ],
        
        // Retry Test button (only if failed)
        if (!passed) ...[
          _buildRetryTestButton(context),
        ],
      ],
    );
  }

  /// Build Review Mistakes button
  /// Requirement: 6.4
  Widget _buildReviewMistakesButton(BuildContext context) {
    final mistakeCount = widget.testResult.incorrectMcqAnswers.length;
    
    return Semantics(
      button: true,
      label: 'Review $mistakeCount mistake${mistakeCount == 1 ? '' : 's'}',
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
    );
  }

  /// Build Continue button (for passed test)
  /// Requirement: 6.4
  Widget _buildContinueButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue',
      hint: 'Return to home screen. Phase 5 is now unlocked.',
      child: ElevatedButton.icon(
        onPressed: () => _navigateToHome(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.correctColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.check),
        label: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build Retry Test button (for failed test)
  /// Requirement: 6.4
  Widget _buildRetryTestButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retry test',
      hint: 'Take the test again to improve your score',
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
    );
  }

  /// Navigate to review screen
  /// Requirement: 6.4
  /// Handles navigation errors gracefully
  void _navigateToReviewScreen(BuildContext context) {
    try {
      if (!context.mounted) {
        print('Context not mounted, cannot navigate to review screen');
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Phase4FinalTestReviewScreen(
            incorrectAnswers: widget.testResult.incorrectMcqAnswers,
          ),
        ),
      ).catchError((error) {
        print('Navigation error to review screen: $error');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open review screen. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (e) {
      print('Error navigating to review screen: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to home screen
  /// Requirement: 6.4
  /// Handles navigation errors gracefully
  void _navigateToHome(BuildContext context) {
    try {
      if (!context.mounted) {
        print('Context not mounted, cannot navigate to home');
        return;
      }

      // Pop all routes and return to home
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phase 5 is now unlocked!'),
            backgroundColor: AppTheme.correctColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error navigating to home: $e');
      if (context.mounted) {
        // Try alternative navigation
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          print('Error popping route: $popError');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation error. Please use back button.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Retry test
  /// Requirement: 6.4
  /// Handles navigation errors gracefully
  void _retryTest(BuildContext context) {
    try {
      if (!context.mounted) {
        print('Context not mounted, cannot retry test');
        return;
      }

      // Pop back to test screen to retry
      Navigator.of(context).pop();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Starting a new test...'),
            duration: Duration(seconds: 2),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      print('Error retrying test: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to restart test. Please navigate manually.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
