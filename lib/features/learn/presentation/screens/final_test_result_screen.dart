import 'package:flutter/material.dart';

import '../../data/models/phase4_test_result.dart';
import '../../data/models/phase5_test_result.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';

enum FinalTestActionStyle { filled, outlined, text }

class FinalTestAction {
  final String label;
  final IconData? icon;
  final FinalTestActionStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool visible;
  final void Function(BuildContext context) onPressed;

  const FinalTestAction({
    required this.label,
    required this.style,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.visible = true,
  });
}

class FinalTestScoreBreakdownItem {
  final String label;
  final int score;
  final int maxScore;
  final IconData icon;
  final bool isTotal;

  const FinalTestScoreBreakdownItem({
    required this.label,
    required this.score,
    required this.maxScore,
    required this.icon,
    this.isTotal = false,
  });
}

class FinalTestResultViewData {
  final bool passed;
  final bool showBackButton;
  final String appBarTitle;
  final String completionTitle;
  final String statusLabel;
  final String statusMessage;
  final String? badgeText;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final IconData passedIcon;
  final IconData failedIcon;
  final int score;
  final int maxScore;
  final double percentage;
  final String? passingScoreText;
  final List<FinalTestScoreBreakdownItem> breakdownItems;
  final List<FinalTestAction> actions;

  const FinalTestResultViewData({
    required this.passed,
    required this.showBackButton,
    required this.appBarTitle,
    required this.completionTitle,
    required this.statusLabel,
    required this.statusMessage,
    required this.passedIcon,
    required this.failedIcon,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.breakdownItems,
    required this.actions,
    this.badgeText,
    this.badgeIcon,
    this.badgeColor,
    this.passingScoreText,
  });

  factory FinalTestResultViewData.fromPhase4(Phase4TestResult result) {
    final passed = result.passed;
    final hasMistakes = result.incorrectMcqAnswers.isNotEmpty;

    return FinalTestResultViewData(
      passed: passed,
      showBackButton: true,
      appBarTitle: 'Test Results',
      completionTitle: 'Phase 4 Final Test Completed!',
      statusLabel: passed ? 'PASSED ✅' : 'NOT PASSED ❌',
      statusMessage: passed
          ? 'Congratulations! You have mastered Phase 4.\nPhase 5 - Professional English is now unlocked!'
          : 'You are close! Review Phase 4 lessons and try again.\nYou need 18 points (75%) to pass.',
      badgeText: passed ? 'Phase 5 Unlocked!' : null,
      badgeIcon: Icons.lock_open,
      badgeColor: AppTheme.masteredColor,
      passedIcon: Icons.celebration,
      failedIcon: Icons.cancel,
      score: result.totalScore,
      maxScore: result.maxScore,
      percentage: result.percentage,
      breakdownItems: [
        FinalTestScoreBreakdownItem(
          label: 'MCQ Questions',
          score: result.mcqCorrect,
          maxScore: Phase4TestResult.maxMcqScore,
          icon: Icons.quiz,
        ),
        FinalTestScoreBreakdownItem(
          label: 'Speaking Tasks',
          score: result.speakingScore,
          maxScore: Phase4TestResult.maxSpeakingScore,
          icon: Icons.mic,
        ),
        FinalTestScoreBreakdownItem(
          label: 'Total Score',
          score: result.totalScore,
          maxScore: result.maxScore,
          icon: Icons.stars,
          isTotal: true,
        ),
      ],
      actions: [
        FinalTestAction(
          label: 'Review Mistakes',
          icon: Icons.rate_review,
          style: FinalTestActionStyle.outlined,
          visible: hasMistakes,
          onPressed: (context) {
            Navigator.of(context).pushNamed(
              AppRoutes.phase4FinalTestReview,
              arguments: result.incorrectMcqAnswers,
            );
          },
        ),
        FinalTestAction(
          label: 'Continue',
          icon: Icons.check,
          style: FinalTestActionStyle.filled,
          backgroundColor: AppTheme.correctColor,
          foregroundColor: Colors.white,
          visible: passed,
          onPressed: (context) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phase 5 is now unlocked!'),
                backgroundColor: AppTheme.correctColor,
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
        FinalTestAction(
          label: 'Try Again',
          icon: Icons.refresh,
          style: FinalTestActionStyle.filled,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          visible: !passed,
          onPressed: (context) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Starting a new test...'),
                duration: Duration(seconds: 2),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          },
        ),
      ],
    );
  }

  factory FinalTestResultViewData.fromPhase5(Phase5TestResult result) {
    final passed = result.passed;

    return FinalTestResultViewData(
      passed: passed,
      showBackButton: false,
      appBarTitle: 'Test Results',
      completionTitle: 'Phase 5 Final Test Completed!',
      statusLabel: passed ? 'Congratulations!' : 'Not Passed',
      statusMessage: passed
          ? 'You have completed the English Communication Mastery Program!'
          : 'You are very close. Review Phase 5 lessons and try again.',
      badgeText: passed ? 'CERTIFIED ✔️' : null,
      badgeIcon: Icons.verified,
      badgeColor: Colors.green,
      passedIcon: Icons.emoji_events,
      failedIcon: Icons.sentiment_dissatisfied,
      score: result.totalScore,
      maxScore: result.maxScore,
      percentage: result.percentage,
      passingScoreText: 'Passing Score: 42/60 (70%)',
      breakdownItems: [
        FinalTestScoreBreakdownItem(
          label: 'MCQ Questions',
          score: result.mcqCorrect,
          maxScore: Phase5TestResult.maxMcqScore,
          icon: Icons.quiz,
        ),
        FinalTestScoreBreakdownItem(
          label: 'Speaking Tasks',
          score: result.speakingScore,
          maxScore: Phase5TestResult.maxSpeakingScore,
          icon: Icons.mic,
        ),
        FinalTestScoreBreakdownItem(
          label: 'Total Score',
          score: result.totalScore,
          maxScore: result.maxScore,
          icon: Icons.stars,
          isTotal: true,
        ),
      ],
      actions: [
        FinalTestAction(
          label: 'Review Mistakes',
          icon: Icons.rate_review,
          style: FinalTestActionStyle.filled,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          onPressed: (context) {
            Navigator.of(context).pushNamed(
              AppRoutes.phase5FinalTestReview,
              arguments: result.incorrectMcqAnswers,
            );
          },
        ),
        FinalTestAction(
          label: 'Download Certificate',
          icon: Icons.download,
          style: FinalTestActionStyle.outlined,
          visible: passed,
          onPressed: (context) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Certificate download coming soon!'),
              ),
            );
          },
        ),
        FinalTestAction(
          label: 'Return to Home',
          style: FinalTestActionStyle.text,
          visible: passed,
          onPressed: (context) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        FinalTestAction(
          label: 'Try Again',
          icon: Icons.refresh,
          style: FinalTestActionStyle.outlined,
          visible: !passed,
          onPressed: (context) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.phase5FinalTest);
          },
        ),
      ],
    );
  }
}

class FinalTestResultScreen extends StatefulWidget {
  final FinalTestResultViewData data;

  const FinalTestResultScreen({
    super.key,
    required this.data,
  });

  factory FinalTestResultScreen.phase4({
    required Phase4TestResult result,
  }) {
    return FinalTestResultScreen(
      data: FinalTestResultViewData.fromPhase4(result),
    );
  }

  factory FinalTestResultScreen.phase5({
    required Phase5TestResult result,
  }) {
    return FinalTestResultScreen(
      data: FinalTestResultViewData.fromPhase5(result),
    );
  }

  @override
  State<FinalTestResultScreen> createState() => _FinalTestResultScreenState();
}

class _FinalTestResultScreenState extends State<FinalTestResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    final data = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          data.appBarTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: data.showBackButton,
        leading: data.showBackButton
            ? Semantics(
                button: true,
                label: 'Back to test',
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              )
            : null,
      ),
      body: SafeArea(
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
                  child: _buildScoreSection(data),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: _buildStatusMessage(data),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: _buildScoreBreakdownSection(data),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: _buildActionButtons(context, data),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(FinalTestResultViewData data) {
    final iconColor =
        data.passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final scoreColor =
        data.passed ? AppTheme.correctColor : AppTheme.incorrectColor;
    final icon = data.passed ? data.passedIcon : data.failedIcon;
    final semanticLabel =
        'Test ${data.passed ? 'Passed' : 'Failed'}. You scored ${data.score} out of ${data.maxScore}. ${data.percentage.toStringAsFixed(1)} percent';

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
                  return Transform.scale(scale: value, child: child);
                },
                child: Icon(icon, size: 80, color: iconColor),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            ExcludeSemantics(
              child: Text(
                data.completionTitle,
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
                tween: IntTween(begin: 0, end: data.score),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    'Score: $value / ${data.maxScore}',
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
                tween: Tween<double>(begin: 0.0, end: data.percentage),
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
            if (data.passingScoreText != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              ExcludeSemantics(
                child: Text(
                  data.passingScoreText!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(FinalTestResultViewData data) {
    final messageColor =
        data.passed ? AppTheme.correctColor : AppTheme.incorrectColor;

    return Semantics(
      label: '${data.statusLabel}. ${data.statusMessage}',
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color:
              data.passed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
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
                data.statusLabel,
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
                data.statusMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: messageColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (data.badgeText != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: (data.badgeColor ?? AppTheme.masteredColor)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: data.badgeColor ?? AppTheme.masteredColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        data.badgeIcon ?? Icons.lock_open,
                        color: data.badgeColor ?? AppTheme.masteredColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        data.badgeText!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: data.badgeColor ?? AppTheme.masteredColor,
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

  Widget _buildScoreBreakdownSection(FinalTestResultViewData data) {
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
          const Text(
            'Score Breakdown:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          for (final item in data.breakdownItems) ...[
            _buildScoreBreakdownItem(item),
            const SizedBox(height: AppTheme.spacingS),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBreakdownItem(FinalTestScoreBreakdownItem item) {
    final percentage =
        item.maxScore > 0 ? (item.score / item.maxScore) * 100 : 0.0;
    Color performanceColor;

    if (percentage >= 75) {
      performanceColor = AppTheme.correctColor;
    } else if (percentage >= 50) {
      performanceColor = AppTheme.warningColor;
    } else {
      performanceColor = AppTheme.incorrectColor;
    }

    return Semantics(
      label:
          '${item.label}: ${item.score} out of ${item.maxScore}. ${percentage.toStringAsFixed(0)} percent',
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: item.isTotal
              ? performanceColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: item.isTotal
              ? Border.all(
                  color: performanceColor.withValues(alpha: 0.5), width: 2)
              : null,
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                item.icon,
                size: item.isTotal ? 24 : 20,
                color: item.isTotal
                    ? performanceColor
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: item.isTotal ? 18 : 16,
                    fontWeight:
                        item.isTotal ? FontWeight.bold : FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            ExcludeSemantics(
              child: Text(
                '${item.score} / ${item.maxScore}',
                style: TextStyle(
                  fontSize: item.isTotal ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: item.isTotal
                      ? performanceColor
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    FinalTestResultViewData data,
  ) {
    final visibleActions =
        data.actions.where((action) => action.visible).toList();

    if (visibleActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < visibleActions.length; i++) ...[
          _buildActionButton(context, visibleActions[i]),
          if (i < visibleActions.length - 1)
            const SizedBox(height: AppTheme.spacingM),
        ],
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, FinalTestAction action) {
    void onPressed() => action.onPressed(context);
    final buttonStyle = _buttonStyle(action);

    if (action.style == FinalTestActionStyle.text) {
      if (action.icon == null) {
        return TextButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: Text(action.label),
        );
      }
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(action.icon),
        label: Text(action.label),
        style: buttonStyle,
      );
    }

    if (action.style == FinalTestActionStyle.outlined) {
      if (action.icon == null) {
        return OutlinedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: Text(action.label),
        );
      }
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(action.icon),
        label: Text(action.label),
        style: buttonStyle,
      );
    }

    if (action.icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(action.label),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(action.icon),
      label: Text(action.label),
      style: buttonStyle,
    );
  }

  ButtonStyle _buttonStyle(FinalTestAction action) {
    final base = ButtonStyle(
      padding:
          WidgetStateProperty.all(const EdgeInsets.all(AppTheme.spacingM)),
    );

    if (action.style == FinalTestActionStyle.text) {
      return base;
    }

    if (action.style == FinalTestActionStyle.outlined) {
      return base.copyWith(
        foregroundColor: action.foregroundColor != null
            ? WidgetStateProperty.all(action.foregroundColor)
            : null,
        side: action.borderColor != null
            ? WidgetStateProperty.all(BorderSide(color: action.borderColor!))
            : null,
      );
    }

    return base.copyWith(
      backgroundColor: action.backgroundColor != null
          ? WidgetStateProperty.all(action.backgroundColor)
          : null,
      foregroundColor: action.foregroundColor != null
          ? WidgetStateProperty.all(action.foregroundColor)
          : null,
    );
  }
}
