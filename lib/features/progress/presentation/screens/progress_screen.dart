import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../learn/presentation/providers/progress_provider.dart';
import '../../../learn/data/models/lesson.dart';
import '../../../learn/data/models/user_lesson_status.dart';
import '../../../learn/domain/entities/phase_units.dart';
import '../../../../app/theme.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/constants/app_strings.dart';

/// Progress overview screen displaying all lessons with their mastery status
/// Shows detailed scores for completed lessons
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Load progress data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(AppStrings.yourProgressEn),
            Text(
              AppStrings.yourProgressTa,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load progress',
                    style: AppTheme.headline2,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.error!,
                      style: AppTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.reload(),
                    child: const Text(AppStrings.tryAgain),
                  ),
                ],
              ),
            );
          }

          if (provider.allLessons.isEmpty) {
            return const Center(
              child: Text('No lessons available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.reload(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Overall progress summary
                _buildOverallProgressCard(provider),
                const SizedBox(height: 28),

                // Phase 1 Section
                _buildSectionHeader(
                  'Phase 1: ${AppStrings.phaseFoundationEn}',
                  AppTheme.primaryColor,
                  tamilGloss: AppStrings.phaseFoundationTa,
                ),
                const SizedBox(height: 16),
                ...provider.getUnitLessons('phase1').map((lesson) {
                  final status = provider.getLessonStatus(lesson.id);
                  final isUnlocked = provider.isLessonUnlocked(lesson.id);
                  return _buildLessonProgressCard(
                    context,
                    lesson,
                    status,
                    isUnlocked,
                  );
                }),

                // Phase 2 Section
                if (provider.isPhase2Unlocked) ...[
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    'Phase 2: ${AppStrings.phaseIntermediateEn}',
                    Colors.blue,
                    tamilGloss: AppStrings.phaseIntermediateTa,
                  ),
                  const SizedBox(height: 16),
                  ..._buildPhase2Lessons(provider),
                ],

                // Phase 3 Section
                if (provider.isPhase3Unlocked) ...[
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    'Phase 3: Real-Life Communication',
                    Colors.purple,
                    tamilGloss: AppStrings.phaseRealLifeTa,
                  ),
                  const SizedBox(height: 16),
                  ..._buildPhase3Lessons(provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build overall progress summary card
  Widget _buildOverallProgressCard(ProgressProvider provider) {
    final masteredCount = provider.masteredCount;
    final totalLessons = provider.totalLessons;
    final progressPercentage = totalLessons > 0
        ? (masteredCount / totalLessons * 100).toInt()
        : 0;

    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.05),
              AppTheme.accentColor.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.masteredColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 40,
                    color: AppTheme.masteredColor,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Progress',
                      style: AppTheme.headline3.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$masteredCount / $totalLessons',
                      style: AppTheme.headline1.copyWith(
                        fontSize: 36,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'lessons mastered',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalLessons > 0 ? masteredCount / totalLessons : 0.0,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$progressPercentage% Complete',
              style: AppTheme.headline3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual lesson progress card
  Widget _buildLessonProgressCard(
    BuildContext context,
    Lesson lesson,
    UserLessonStatus? status,
    bool isUnlocked,
  ) {
    final hasProgress = status != null &&
        (status.explainDone ||
            status.examplesDone ||
            status.listeningScore > 0 ||
            status.speakingScore > 0 ||
            status.quizBestScore > 0 ||
            status.masteryBestScore > 0);

    final badgeStatus = !isUnlocked
        ? BadgeStatus.locked
        : status?.isMastered == true
            ? BadgeStatus.mastered
            : hasProgress
                ? BadgeStatus.inProgress
                : BadgeStatus.locked;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: InkWell(
        onTap: isUnlocked
            ? () async {
                // Navigate to lesson
                await Navigator.pushNamed(
                  context,
                  AppRoutes.lesson,
                  arguments: lesson.id,
                );
                // Refresh progress after returning
                if (context.mounted) {
                  await context.read<ProgressProvider>().reload();
                }
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.masterPreviousLesson),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson header
              Row(
                children: [
                  // Lesson number badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppTheme.primaryColor
                          : AppTheme.lockedColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${lesson.order}',
                        style: AppTheme.headline3.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Lesson title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: AppTheme.headline3.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lesson.description,
                          style: AppTheme.bodyText2.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  StatusBadge(
                    status: badgeStatus,
                    size: 28,
                  ),
                ],
              ),

              // Show detailed scores if lesson has progress
              if (hasProgress) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildScoreDetails(status),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build detailed score information
  Widget _buildScoreDetails(UserLessonStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Scores',
          style: AppTheme.bodyText2.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        
        // Tab completion status
        Row(
          children: [
            Expanded(
              child: _buildCompletionIndicator(
                'Explain',
                status.explainDone,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompletionIndicator(
                'Examples',
                status.examplesDone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Scores
        if (status.listeningScore > 0)
          _buildScoreRow(
            'Listening',
            status.listeningScore,
            Icons.headphones,
          ),
        if (status.speakingScore > 0)
          _buildScoreRow(
            'Speaking',
            status.speakingScore,
            Icons.mic,
          ),
        if (status.quizBestScore > 0)
          _buildScoreRow(
            'Practice Quiz',
            status.quizBestScore,
            Icons.quiz,
          ),
        if (status.masteryBestScore > 0)
          _buildScoreRow(
            'Mastery Test',
            status.masteryBestScore,
            Icons.emoji_events,
          ),
      ],
    );
  }

  /// Build completion indicator for tabs
  Widget _buildCompletionIndicator(String label, bool isComplete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete
            ? AppTheme.correctColor.withValues(alpha: 0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isComplete ? AppTheme.correctColor : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isComplete ? AppTheme.correctColor : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(
                fontSize: 12,
                color: isComplete ? AppTheme.correctColor : Colors.grey[600],
                fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build score row with icon and percentage
  Widget _buildScoreRow(String label, double score, IconData icon) {
    final percentage = (score * 100).toInt();
    final color = score >= 0.8
        ? AppTheme.correctColor
        : score >= 0.6
            ? AppTheme.warningColor
            : AppTheme.incorrectColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              '$percentage%',
              style: AppTheme.bodyText2.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header for each phase.
  /// [tamilGloss] adds a short Tamil label under the English title.
  Widget _buildSectionHeader(String title, Color color, {String? tamilGloss}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: tamilGloss != null ? 44 : 24,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.headline2,
              ),
              if (tamilGloss != null)
                Text(
                  tamilGloss,
                  style: AppTheme.bodyText2.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Phase 2 lessons list
  List<Widget> _buildPhase2Lessons(ProgressProvider provider) {
    final widgets = <Widget>[];
    
    for (final unit in PhaseUnits.phase2) {
      final unitId = unit.id;
      final lessons = provider.getUnitLessons(unitId);
      for (final lesson in lessons) {
        final status = provider.getLessonStatus(lesson.id);
        final isUnlocked = provider.isLessonUnlocked(lesson.id);
        widgets.add(_buildLessonProgressCard(
          context,
          lesson,
          status,
          isUnlocked,
        ));
      }
    }
    
    return widgets;
  }

  /// Build Phase 3 lessons list
  List<Widget> _buildPhase3Lessons(ProgressProvider provider) {
    final widgets = <Widget>[];
    
    for (final unit in PhaseUnits.phase3) {
      final unitId = unit.id;
      final lessons = provider.getUnitLessons(unitId);
      for (final lesson in lessons) {
        final status = provider.getLessonStatus(lesson.id);
        final isUnlocked = provider.isLessonUnlocked(lesson.id);
        widgets.add(_buildLessonProgressCard(
          context,
          lesson,
          status,
          isUnlocked,
        ));
      }
    }
    
    return widgets;
  }
}
