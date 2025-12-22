import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum BadgeStatus { locked, inProgress, mastered, completed }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final double size;
  final bool showLabel;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = 24,
    this.showLabel = false,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final badgeData = _getBadgeData();

    if (showLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeData.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: badgeData.color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              badgeData.icon,
              color: badgeData.color,
              size: size * 0.8,
            ),
            const SizedBox(width: 6),
            Text(
              customLabel ?? badgeData.label,
              style: AppTheme.bodyText2.copyWith(
                color: badgeData.color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      badgeData.icon,
      color: badgeData.color,
      size: size,
    );
  }

  _BadgeData _getBadgeData() {
    switch (status) {
      case BadgeStatus.locked:
        return _BadgeData(
          icon: Icons.lock,
          color: AppTheme.lockedColor,
          label: 'Locked',
        );
      case BadgeStatus.inProgress:
        return _BadgeData(
          icon: Icons.play_circle_outline,
          color: AppTheme.accentColor,
          label: 'In Progress',
        );
      case BadgeStatus.mastered:
        return _BadgeData(
          icon: Icons.check_circle,
          color: AppTheme.masteredColor,
          label: 'Mastered',
        );
      case BadgeStatus.completed:
        return _BadgeData(
          icon: Icons.check_circle,
          color: AppTheme.correctColor,
          label: 'Completed',
        );
    }
  }
}

class _BadgeData {
  final IconData icon;
  final Color color;
  final String label;

  _BadgeData({
    required this.icon,
    required this.color,
    required this.label,
  });
}

// Animated feedback badge for correct/incorrect answers
class FeedbackBadge extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback? onComplete;

  const FeedbackBadge({
    super.key,
    required this.isCorrect,
    this.onComplete,
  });

  @override
  State<FeedbackBadge> createState() => _FeedbackBadgeState();
}

class _FeedbackBadgeState extends State<FeedbackBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isCorrect ? Icons.check_circle : Icons.cancel,
          color: widget.isCorrect
              ? AppTheme.correctColor
              : AppTheme.incorrectColor,
          size: 48,
        ),
      ),
    );
  }
}
