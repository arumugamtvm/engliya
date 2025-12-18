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
import '../../../../core/utils/error_handler.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        context.read<LessonProvider>().goToTab(_tabController.index);
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
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (lessonProvider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    lessonProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      lessonProvider.loadLesson(widget.lessonId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final lesson = lessonProvider.currentLesson;
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Lesson'),
            ),
            body: const Center(
              child: Text('No lesson data available'),
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

        return WillPopScope(
          onWillPop: () async {
            // Save progress before navigating back
            await lessonProvider.saveProgress();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(fontSize: 18),
                  ),
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
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.menu_book, size: 20),
                      text: 'Explain',
                      height: 48,
                    ),
                    Tab(
                      icon: Icon(Icons.lightbulb_outline, size: 20),
                      text: 'Examples',
                      height: 48,
                    ),
                    Tab(
                      icon: Icon(Icons.headphones, size: 20),
                      text: 'Listen',
                      height: 48,
                    ),
                    Tab(
                      icon: Icon(Icons.mic, size: 20),
                      text: 'Speak',
                      height: 48,
                    ),
                    Tab(
                      icon: Icon(Icons.quiz, size: 20),
                      text: 'Practice',
                      height: 48,
                    ),
                    Tab(
                      icon: Icon(Icons.star, size: 20),
                      text: 'Mastery',
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: const [
                ExplainTab(),
                ExamplesTab(),
                ListenTab(),
                SpeakTab(),
                PracticeTab(),
                MasteryTab(),
              ],
            ),
            bottomNavigationBar: const LessonBottomNav(),
          ),
        );
      },
    );
  }
}
