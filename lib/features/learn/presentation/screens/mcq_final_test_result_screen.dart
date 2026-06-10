import 'package:flutter/material.dart';

import '../../domain/entities/test_result.dart';
import '../../../../app/theme.dart';

class McqUnitBreakdownItem {
  final String unitId;
  final String? displayName;
  final int? expectedTotal;
  final int delayMs;
  final bool showWhenMissing;

  const McqUnitBreakdownItem({
    required this.unitId,
    this.displayName,
    this.expectedTotal,
    this.delayMs = 0,
    this.showWhenMissing = false,
  });
}

class McqUnitBreakdownStyle {
  final double highThreshold;
  final double midThreshold;
  final Color highColor;
  final Color midColor;
  final Color lowColor;
  final Color highTextColor;
  final Color midTextColor;
  final Color lowTextColor;
  final double borderOpacity;
  final double borderWidth;

  const McqUnitBreakdownStyle({
    required this.highThreshold,
    required this.midThreshold,
    required this.highColor,
    required this.midColor,
    required this.lowColor,
    required this.highTextColor,
    required this.midTextColor,
    required this.lowTextColor,
    this.borderOpacity = 0.3,
    this.borderWidth = 1,
  });

  _PerformanceStyle _resolve(double accuracy) {
    if (accuracy >= highThreshold) {
      return _PerformanceStyle(
        color: highColor,
        textColor: highTextColor,
        level: 'Excellent',
        icon: Icons.check_circle,
      );
    }
    if (accuracy >= midThreshold) {
      return _PerformanceStyle(
        color: midColor,
        textColor: midTextColor,
        level: 'Good',
        icon: Icons.info,
      );
    }
    return _PerformanceStyle(
      color: lowColor,
      textColor: lowTextColor,
      level: 'Needs Improvement',
      icon: Icons.warning,
    );
  }
}

class McqUnitBreakdownConfig {
  final String title;
  final List<McqUnitBreakdownItem> items;
  final McqUnitBreakdownStyle style;

  const McqUnitBreakdownConfig({
    required this.title,
    required this.items,
    required this.style,
  });
}

class McqFinalTestResultConfig {
  final String completionTitle;
  final IconData successIcon;
  final IconData failureIcon;
  final String Function(TestResult result) passedMessage;
  final String Function(TestResult result) failedMessage;
  final String continueLabel;
  final IconData continueIcon;
  final String continueHint;
  final String continueSemanticLabel;
  final String continueSnackMessage;
  final String reviewRouteName;
  final McqUnitBreakdownConfig? breakdownConfig;

  const McqFinalTestResultConfig({
    required this.completionTitle,
    required this.successIcon,
    required this.failureIcon,
    required this.passedMessage,
    required this.failedMessage,
    required this.continueLabel,
    required this.continueIcon,
    required this.continueHint,
    required this.continueSemanticLabel,
    required this.continueSnackMessage,
    required this.reviewRouteName,
    this.breakdownConfig,
  });

  static McqFinalTestResultConfig phase1() {
    return McqFinalTestResultConfig(
      completionTitle: 'Phase 1 Final Test - Completed!',
      successIcon: Icons.check_circle,
      failureIcon: Icons.cancel,
      passedMessage: (_) => 'You have mastered the entire Phase 1 foundation',
      failedMessage: (_) => 'Keep practicing to master Phase 1 content',
      continueLabel: 'Continue to Phase 2',
      continueIcon: Icons.arrow_forward,
      continueHint: 'Proceed to the next learning phase',
      continueSemanticLabel: 'Continue to Phase 2',
      continueSnackMessage: 'Phase 2 will be unlocked soon!',
      reviewRouteName: '/phase1/finalTest/review',
      breakdownConfig: null,
    );
  }

  static McqFinalTestResultConfig phase2() {
    return McqFinalTestResultConfig(
      completionTitle: 'Phase 2 Final Test Completed!',
      successIcon: Icons.check_circle,
      failureIcon: Icons.cancel,
      passedMessage: (_) => 'You have mastered Phase 2',
      failedMessage: (result) =>
          'You scored ${result.accuracy.toStringAsFixed(1)}%. Try again to pass Phase 2',
      continueLabel: 'Continue',
      continueIcon: Icons.check,
      continueHint: 'Return to home screen',
      continueSemanticLabel: 'Continue',
      continueSnackMessage: 'Phase 3 is now unlocked!',
      reviewRouteName: '/phase2/finalTest/review',
      breakdownConfig: McqUnitBreakdownConfig(
        title: 'Summary',
        style: McqUnitBreakdownStyle(
          highThreshold: 80,
          midThreshold: 60,
          highColor: AppTheme.correctColor,
          midColor: AppTheme.warningColor,
          lowColor: AppTheme.incorrectColor,
          highTextColor: AppTheme.correctColor,
          midTextColor: AppTheme.warningColor,
          lowTextColor: AppTheme.incorrectColor,
        ),
        items: const [
          McqUnitBreakdownItem(unitId: 'unit7', delayMs: 0),
          McqUnitBreakdownItem(unitId: 'unit8', delayMs: 100),
          McqUnitBreakdownItem(unitId: 'unit9', delayMs: 200),
          McqUnitBreakdownItem(unitId: 'unit10', delayMs: 300),
          McqUnitBreakdownItem(unitId: 'unit11', delayMs: 400),
        ],
      ),
    );
  }

  static McqFinalTestResultConfig phase3() {
    return McqFinalTestResultConfig(
      completionTitle: 'Phase 3 Final Test Completed!',
      successIcon: Icons.celebration,
      failureIcon: Icons.cancel,
      passedMessage: (_) => 'You have mastered Phase 3',
      failedMessage: (_) => 'You are close! Review Phase 3 lessons and try again',
      continueLabel: 'Continue',
      continueIcon: Icons.check,
      continueHint: 'Return to home screen. Phase 4 is now unlocked.',
      continueSemanticLabel: 'Continue',
      continueSnackMessage: 'Phase 4 is now unlocked!',
      reviewRouteName: '/phase3/finalTest/review',
      breakdownConfig: McqUnitBreakdownConfig(
        title: 'Breakdown:',
        style: McqUnitBreakdownStyle(
          highThreshold: 80,
          midThreshold: 60,
          highColor: const Color(0xFF2E7D32),
          midColor: const Color(0xFFE65100),
          lowColor: const Color(0xFFC62828),
          highTextColor: const Color(0xFF1B5E20),
          midTextColor: const Color(0xFFBF360C),
          lowTextColor: const Color(0xFFB71C1C),
          borderOpacity: 0.5,
          borderWidth: 2,
        ),
        items: const [
          McqUnitBreakdownItem(
            unitId: 'unit12',
            displayName: 'Stories & Retelling',
            expectedTotal: 6,
            delayMs: 0,
            showWhenMissing: true,
          ),
          McqUnitBreakdownItem(
            unitId: 'unit13',
            displayName: 'Connectors & Complex Sent.',
            expectedTotal: 7,
            delayMs: 100,
            showWhenMissing: true,
          ),
          McqUnitBreakdownItem(
            unitId: 'unit14',
            displayName: 'Passive Voice',
            expectedTotal: 5,
            delayMs: 200,
            showWhenMissing: true,
          ),
          McqUnitBreakdownItem(
            unitId: 'unit15',
            displayName: 'Reported Speech',
            expectedTotal: 5,
            delayMs: 300,
            showWhenMissing: true,
          ),
          McqUnitBreakdownItem(
            unitId: 'unit16',
            displayName: 'Functional English',
            expectedTotal: 4,
            delayMs: 400,
            showWhenMissing: true,
          ),
          McqUnitBreakdownItem(
            unitId: 'unit17',
            displayName: 'Projects & General Use',
            expectedTotal: 3,
            delayMs: 500,
            showWhenMissing: true,
          ),
        ],
      ),
    );
  }
}

class McqFinalTestResultScreen extends StatefulWidget {
  final TestResult testResult;
  final McqFinalTestResultConfig config;

  const McqFinalTestResultScreen({
    super.key,
    required this.testResult,
    required this.config,
  });

  factory McqFinalTestResultScreen.phase1({
    Key? key,
    required TestResult testResult,
  }) {
    return McqFinalTestResultScreen(
      key: key,
      testResult: testResult,
      config: McqFinalTestResultConfig.phase1(),
    );
  }

  factory McqFinalTestResultScreen.phase2({
    Key? key,
    required TestResult testResult,
  }) {
    return McqFinalTestResultScreen(
      key: key,
      testResult: testResult,
      config: McqFinalTestResultConfig.phase2(),
    );
  }

  factory McqFinalTestResultScreen.phase3({
    Key? key,
    required TestResult testResult,
  }) {
    return McqFinalTestResultScreen(
      key: key,
      testResult: testResult,
      config: McqFinalTestResultConfig.phase3(),
    );
  }

  @override
  State<McqFinalTestResultScreen> createState() => _McqFinalTestResultScreenState();
}

class _McqFinalTestResultScreenState extends State<McqFinalTestResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  McqFinalTestResultConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();

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
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildScoreSection(),
              ),
              const SizedBox(height: AppTheme.spacingXL),
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
              if (_config.breakdownConfig != null) ...[
                const SizedBox(height: AppTheme.spacingXL),
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
                  child: _buildUnitBreakdownSection(_config.breakdownConfig!),
                ),
              ],
              const SizedBox(height: AppTheme.spacingXL),
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

  Widget _buildScoreSection() {
    final passed = widget.testResult.passed;
    final iconColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final scoreColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final statusText = passed ? 'Passed' : 'Failed';

    final semanticLabel =
        'Test $statusText. You scored ${widget.testResult.correctAnswers} out of ${widget.testResult.totalQuestions}. Accuracy: ${widget.testResult.accuracy.toStringAsFixed(1)} percent';

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
                  passed ? _config.successIcon : _config.failureIcon,
                  size: 80,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            ExcludeSemantics(
              child: Text(
                _config.completionTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
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

  Widget _buildStatusMessage() {
    final passed = widget.testResult.passed;
    final message = passed
        ? _config.passedMessage(widget.testResult)
        : _config.failedMessage(widget.testResult);
    final messageColor = passed ? AppTheme.correctColor : AppTheme.incorrectColor;

    return Semantics(
      label: message,
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: passed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
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

  Widget _buildUnitBreakdownSection(McqUnitBreakdownConfig config) {
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
          Text(
            config.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          for (final item in config.items) ...[
            _buildUnitPerformanceItem(item, config.style),
            const SizedBox(height: AppTheme.spacingS),
          ],
        ],
      ),
    );
  }

  Widget _buildUnitPerformanceItem(
    McqUnitBreakdownItem item,
    McqUnitBreakdownStyle style,
  ) {
    final unitPerformance = widget.testResult.unitBreakdown?[item.unitId];
    if (unitPerformance == null && !item.showWhenMissing) {
      return const SizedBox.shrink();
    }

    final correctAnswers = unitPerformance?.correctAnswers ?? 0;
    final totalQuestions = unitPerformance?.totalQuestions ?? item.expectedTotal ?? 0;
    if (totalQuestions == 0) {
      return const SizedBox.shrink();
    }

    final accuracy = (correctAnswers / totalQuestions) * 100;
    final performance = style._resolve(accuracy);
    final displayName =
        item.displayName ?? unitPerformance?.unitName ?? item.unitId;

    final semanticLabel =
        '$displayName: $correctAnswers out of $totalQuestions correct. ${accuracy.toStringAsFixed(0)} percent. Performance: ${performance.level}';

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
            color: performance.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: performance.color.withValues(alpha: style.borderOpacity),
              width: style.borderWidth,
            ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  performance.icon,
                  size: 20,
                  color: performance.color,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    '$displayName: $correctAnswers / $totalQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${accuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: performance.textColor,
                      ),
                    ),
                    Text(
                      performance.level,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: performance.textColor,
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

  Widget _buildActionButtons(BuildContext context) {
    final passed = widget.testResult.passed;
    final hasMistakes = widget.testResult.incorrectQuestionDetails.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasMistakes) ...[
          _buildReviewMistakesButton(context),
          const SizedBox(height: AppTheme.spacingM),
        ],
        if (passed) ...[
          _buildContinueButton(context),
        ],
        if (!passed) ...[
          _buildRetryTestButton(context),
        ],
      ],
    );
  }

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

  Widget _buildContinueButton(BuildContext context) {
    return Semantics(
      button: true,
      label: _config.continueSemanticLabel,
      hint: _config.continueHint,
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
        icon: Icon(_config.continueIcon),
        label: Text(
          _config.continueLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRetryTestButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Try again',
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
          'Try Again',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToReviewScreen(BuildContext context) {
    try {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushNamed(
        _config.reviewRouteName,
        arguments: widget.testResult.incorrectQuestionDetails,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open review screen. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToHome(BuildContext context) {
    try {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_config.continueSnackMessage),
            backgroundColor: AppTheme.correctColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation error. Please use back button.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _retryTest(BuildContext context) {
    try {
      if (!context.mounted) {
        return;
      }

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

class _PerformanceStyle {
  final Color color;
  final Color textColor;
  final String level;
  final IconData icon;

  const _PerformanceStyle({
    required this.color,
    required this.textColor,
    required this.level,
    required this.icon,
  });
}
