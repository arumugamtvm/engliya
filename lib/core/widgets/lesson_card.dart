import 'package:flutter/material.dart';
import '../../features/learn/data/models/lesson.dart';
import '../../features/learn/data/models/user_lesson_status.dart';
import '../../app/theme.dart';

enum LessonStatus { locked, inProgress, mastered }

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final UserLessonStatus? status;
  final bool isUnlocked;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.status,
    required this.isUnlocked,
    required this.onTap,
  });

  LessonStatus get lessonStatus {
    if (!isUnlocked) return LessonStatus.locked;
    if (status?.isMastered ?? false) return LessonStatus.mastered;
    if (status != null &&
        (status!.explainDone ||
            status!.examplesDone ||
            status!.listeningScore > 0 ||
            status!.speakingScore > 0 ||
            status!.quizBestScore > 0)) {
      return LessonStatus.inProgress;
    }
    return LessonStatus.inProgress; // Unlocked but not started
  }

  double get progressPercentage {
    if (status == null || !isUnlocked) return 0.0;
    if (status!.isMastered) return 1.0;

    // Calculate progress based on completed tabs (6 tabs total)
    int completedTabs = 0;
    if (status!.explainDone) completedTabs++;
    if (status!.examplesDone) completedTabs++;
    if (status!.listeningScore >= 0.7) completedTabs++;
    if (status!.speakingScore >= 0.7) completedTabs++;
    if (status!.quizBestScore >= 0.6) completedTabs++;
    if (status!.masteryBestScore >= 0.8) completedTabs++;

    return completedTabs / 6.0;
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = lessonStatus;

    return Card(
      elevation: isUnlocked ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Lesson number circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(currentStatus),
                ),
                child: Center(
                  child: Text(
                    '${lesson.order}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Lesson info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: AppTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? Colors.black87
                                  : AppTheme.lockedColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(currentStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: AppTheme.bodyText2.copyWith(
                        color: isUnlocked
                            ? Colors.black54
                            : AppTheme.lockedColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress indicator
                    if (isUnlocked)
                      LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentStatus == LessonStatus.mastered
                              ? AppTheme.masteredColor
                              : AppTheme.primaryColor,
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

  Widget _buildStatusBadge(LessonStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case LessonStatus.locked:
        icon = Icons.lock;
        color = AppTheme.lockedColor;
        break;
      case LessonStatus.inProgress:
        icon = Icons.play_circle_outline;
        color = AppTheme.accentColor;
        break;
      case LessonStatus.mastered:
        icon = Icons.check_circle;
        color = AppTheme.masteredColor;
        break;
    }

    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }

  Color _getStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.locked:
        return AppTheme.lockedColor;
      case LessonStatus.inProgress:
        return AppTheme.accentColor;
      case LessonStatus.mastered:
        return AppTheme.masteredColor;
    }
  }
}
