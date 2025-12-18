import 'package:flutter/material.dart';
import '../../data/models/phase2_test_result.dart';
import '../../../../app/theme.dart';
import 'phase2_final_test_review_screen.dart';

/// Phase 2 Final Test Result Screen
/// Displays test score, accuracy, unit breakdown, pass/fail status, and action buttons
/// Requirements: 4.1-4.14, 8.1-8.2
class Phase2FinalTestResultScreen extends StatefulWidget {
  final Phase2TestResult testResult;

  const Phase2FinalTestResultScreen({
    super.key,
    required this.testResult,
  });

  @override
  State<Phase2FinalTestResultScreen> createState() => _Phase2FinalTestResultScreenState();
}

class _Phase2FinalTestResultScreenState extends State<Phase2FinalTestResultScreen>
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
  /// Requirement: 4.1
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
              
              // Unit breakdown section with delayed fade
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
                child: _buildUnitBreakdownSection(),
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

  /// Build score display section with icon, title, score, and accuracy
  /// Requirement: 4.1, 4.2, 4.3, 8.1, 8.2
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
                'Phase 2 Final Test Completed!',
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
  /// Requirement: 4.10, 4.11
  Widget _buildStatusMessage() {
    final passed = widget.testResult.passed;
    final message = passed
        ? 'You have mastered Phase 2'
        : 'You scored ${widget.testResult.accuracy.toStringAsFixed(1)}%. Try again to pass Phase 2';
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

  /// Build unit breakdown section showing performance by unit
  /// Requirement: 4.4, 4.5, 4.6, 4.7, 4.8, 4.9
  Widget _buildUnitBreakdownSection() {
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
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Unit performance items with staggered animation
          _buildUnitPerformanceItem('unit7', 0),
          const SizedBox(height: AppTheme.spacingS),
          _buildUnitPerformanceItem('unit8', 100),
          const SizedBox(height: AppTheme.spacingS),
          _buildUnitPerformanceItem('unit9', 200),
          const SizedBox(height: AppTheme.spacingS),
          _buildUnitPerformanceItem('unit10', 300),
          const SizedBox(height: AppTheme.spacingS),
          _buildUnitPerformanceItem('unit11', 400),
        ],
      ),
    );
  }

  /// Build individual unit performance item with color coding
  /// Requirement: 4.4, 4.5, 4.6, 4.7, 4.8, 4.9
  /// Accessibility: Don't rely solely on color - includes text labels and icons
  Widget _buildUnitPerformanceItem(String unitId, int delayMs) {
    final unitPerformance = widget.testResult.unitBreakdown[unitId];
    
    if (unitPerformance == null) {
      return const SizedBox.shrink();
    }
    
    // Determine color and performance level based on accuracy
    Color performanceColor;
    String performanceLevel;
    IconData performanceIcon;
    
    if (unitPerformance.accuracy >= 80) {
      performanceColor = AppTheme.correctColor; // Green for 80%+
      performanceLevel = 'Excellent';
      performanceIcon = Icons.check_circle;
    } else if (unitPerformance.accuracy >= 60) {
      performanceColor = AppTheme.warningColor; // Orange for 60-79%
      performanceLevel = 'Good';
      performanceIcon = Icons.info;
    } else {
      performanceColor = AppTheme.incorrectColor; // Red for <60%
      performanceLevel = 'Needs Improvement';
      performanceIcon = Icons.warning;
    }
    
    final semanticLabel = '${unitPerformance.unitName}: ${unitPerformance.correctAnswers} out of ${unitPerformance.totalQuestions} correct. ${unitPerformance.accuracy.toStringAsFixed(0)} percent. Performance: $performanceLevel';

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Semantics(
        label: semanticLabel,
        readOnly: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: performanceColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: performanceColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Performance icon (not relying solely on color)
              ExcludeSemantics(
                child: Icon(
                  performanceIcon,
                  size: 20,
                  color: performanceColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              
              // Unit name and score
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    '${unitPerformance.unitName}: ${unitPerformance.correctAnswers} / ${unitPerformance.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              
              // Accuracy percentage with performance level
              ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${unitPerformance.accuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: performanceColor,
                      ),
                    ),
                    Text(
                      performanceLevel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: performanceColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build action buttons section
  /// Requirement: 4.12, 4.13, 4.14
  Widget _buildActionButtons(BuildContext context) {
    final passed = widget.testResult.passed;
    final hasMistakes = widget.testResult.incorrectQuestionDetails.isNotEmpty;

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
  /// Requirement: 4.12
  Widget _buildReviewMistakesButton(BuildContext context) {
    final mistakeCount = widget.testResult.incorrectQuestionDetails.length;
    
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
  /// Requirement: 4.13
  Widget _buildContinueButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue',
      hint: 'Return to home screen',
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
  /// Requirement: 4.14
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
  /// Requirement: 4.12
  /// Handles navigation errors gracefully
  void _navigateToReviewScreen(BuildContext context) {
    try {
      if (!context.mounted) {
        print('Context not mounted, cannot navigate to review screen');
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Phase2FinalTestReviewScreen(
            incorrectAnswers: widget.testResult.incorrectQuestionDetails,
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
  /// Requirement: 4.13
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
            content: Text('Phase 3 is now unlocked!'),
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
  /// Requirement: 4.14
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
