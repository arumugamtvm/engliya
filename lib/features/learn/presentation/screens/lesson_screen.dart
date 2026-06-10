import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../widgets/tabs/explain_tab.dart';
import '../widgets/tabs/examples_tab.dart';
import '../widgets/tabs/listen_tab.dart';
import '../widgets/tabs/speak_tab.dart';
import '../widgets/tabs/practice_tab.dart';
import '../widgets/tabs/mastery_tab.dart';
import '../widgets/lesson_bottom_nav.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/constants/app_strings.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Tab _buildTab({
    required bool unlocked,
    required IconData icon,
    required String text,
  }) {
    final iconColor = unlocked ? null : Colors.grey.shade500;
    final textColor = unlocked ? null : Colors.grey.shade500;

    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(unlocked ? icon : Icons.lock_outline, size: 20, color: iconColor),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Load lesson data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLesson(widget.lessonId);
    });

    // Sync tab controller with provider
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = context.read<LessonProvider>();
        if (provider.canAccessTab(_tabController.index)) {
          provider.goToTab(_tabController.index);
        } else {
          _tabController.animateTo(provider.currentTabIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        // Sync provider tab index with tab controller
        if (_tabController.index != lessonProvider.currentTabIndex) {
          _tabController.animateTo(lessonProvider.currentTabIndex);
        }

        if (lessonProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.loading)),
            body: const AppLoadingState(message: AppStrings.loadingLesson),
          );
        }

        if (lessonProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.errorTitle)),
            body: AppErrorState(
              message: lessonProvider.error!,
              retryLabel: AppStrings.tryAgain,
              onRetry: () => lessonProvider.loadLesson(widget.lessonId),
            ),
          );
        }

        final lesson = lessonProvider.currentLesson;
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lesson')),
            body: const AppEmptyState(
              title: AppStrings.noLessonData,
              subtitle: AppStrings.goBackTryAgain,
            ),
          );
        }

        // Calculate completed tabs count
        final status = lessonProvider.currentStatus;
        int completedTabs = 0;
        if (status != null) {
          if (status.explainDone) completedTabs++;
          if (status.examplesDone) completedTabs++;
          if (status.listeningScore >= 0.7) completedTabs++;
          if (status.speakingScore >= 0.7) completedTabs++;
          if (status.quizBestScore >= 0.6) completedTabs++;
          if (status.isMastered) completedTabs++;
        }

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            // Save progress before navigating back
            if (didPop) {
              lessonProvider.saveProgress();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: const TextStyle(fontSize: 18)),
                  Text(
                    '$completedTabs / 6 completed',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onTap: (index) {
                    final canAccess = lessonProvider.canAccessTab(index);
                    if (!canAccess) {
                      final blocking = lessonProvider
                          .getBlockingValidationForTab(index);
                      final message =
                          blocking?.message ??
                          'Complete the current step before moving ahead.';
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                      _tabController.animateTo(lessonProvider.currentTabIndex);
                      return;
                    }
                    lessonProvider.goToTab(index);
                  },
                  tabs: [
                    _buildTab(
                      unlocked: lessonProvider.isTabUnlocked(0),
                      icon: Icons.menu_book,
                      text: 'Explain',
                    ),
                    _buildTab(
                      unlocked: lessonProvider.isTabUnlocked(1),
                      icon: Icons.lightbulb_outline,
                      text: 'Examples',
                    ),
                    _buildTab(
                      unlocked: lessonProvider.isTabUnlocked(2),
                      icon: Icons.headphones,
                      text: 'Listen',
                    ),
                    _buildTab(
                      unlocked: lessonProvider.isTabUnlocked(3),
                      icon: Icons.mic,
                      text: 'Speak',
                    ),
                    _buildTab(
                      unlocked: lessonProvider.isTabUnlocked(4),
                      icon: Icons.quiz,
                      text: 'Practice',
                    ),
                    _buildTab(
                      unlocked: lessonProvider.isTabUnlocked(5),
                      icon: Icons.star,
                      text: 'Mastery',
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              physics: lessonProvider.strictProgressionEnabled
                  ? const NeverScrollableScrollPhysics()
                  : null,
              children: const [
                ExplainTab(),
                ExamplesTab(),
                ListenTab(),
                SpeakTab(),
                PracticeTab(),
                MasteryTab(),
              ],
            ),
            persistentFooterButtons: lessonProvider.contentNotice == null
                ? null
                : [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Text(
                        lessonProvider.contentNotice!,
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
            bottomNavigationBar: const LessonBottomNav(),
          ),
        );
      },
    );
  }
}
