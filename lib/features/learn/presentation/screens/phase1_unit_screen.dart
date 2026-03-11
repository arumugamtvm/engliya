import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/mcq_final_test_provider.dart';
import '../../../../core/widgets/lesson_card.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_config.dart';
import '../../domain/entities/phase_config.dart';
import '../../domain/repositories/test_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../services/gating_service.dart';

class Phase1UnitScreen extends StatefulWidget {
  const Phase1UnitScreen({super.key});

  @override
  State<Phase1UnitScreen> createState() => _Phase1UnitScreenState();
}

class _Phase1UnitScreenState extends State<Phase1UnitScreen> {
  bool _isLesson6Completed = false;
  bool _hasPassedTest = false;
  int? _lastTestScore;

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndInitialize();
    });
  }

  /// Load progress data first, then initialize test service
  Future<void> _loadDataAndInitialize() async {
    try {
      // Wait for progress data to load
      await context.read<ProgressProvider>().loadAllData();
      await _loadTestStatus();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  /// Check test status and update local state
  Future<void> _loadTestStatus() async {
    try {
      // Check if Lesson 6 is completed
      final progressProvider = context.read<ProgressProvider>();
      final lesson6Status = progressProvider.getLessonStatus('phase1_lesson6');

      // In development mode, always show the final test card
      // Otherwise, only show when lesson 6 is mastered
      _isLesson6Completed =
          AppConfig.devMode || (lesson6Status?.isMastered ?? false);

      final testProvider = McqFinalTestProvider(
        config: PhaseConfig.phase1,
        testRepository: context.read<TestRepository>(),
        progressRepository: context.read<ProgressRepository>(),
        gatingService: context.read<GatingService>(),
      );
      _hasPassedTest = await testProvider.hasPassedBefore();
      _lastTestScore = await testProvider.getLastTestScore();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing test service: $e');
    }
  }

  Future<void> _initializeTestService() async {
    await _loadTestStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 1: Basic English')),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          // Show loading indicator
          if (progressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message
          if (progressProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading lessons',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      progressProvider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      progressProvider.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show lesson list - filter to only Phase 1 lessons
          final lessons = progressProvider.getUnitLessons('phase1');

          if (lessons.isEmpty) {
            return const Center(child: Text('No lessons available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: lessons.length + (_isLesson6Completed ? 1 : 0),
            itemBuilder: (context, index) {
              // Show final test card after all lessons if Lesson 6 is completed
              if (index == lessons.length && _isLesson6Completed) {
                return _buildFinalTestCard();
              }

              final lesson = lessons[index];
              final status = progressProvider.getLessonStatus(lesson.id);
              final isUnlocked = progressProvider.isLessonUnlocked(lesson.id);

              return LessonCard(
                lesson: lesson,
                status: status,
                isUnlocked: isUnlocked,
                onTap: () => _handleLessonTap(context, lesson.id, isUnlocked),
              );
            },
          );
        },
      ),
    );
  }

  void _handleLessonTap(
    BuildContext context,
    String lessonId,
    bool isUnlocked,
  ) async {
    if (isUnlocked) {
      // Navigate to lesson screen
      await Navigator.pushNamed(context, AppRoutes.lesson, arguments: lessonId);

      // Refresh progress after returning from lesson
      if (mounted) {
        await context.read<ProgressProvider>().reload();
        await _initializeTestService();
      }
    } else {
      // Show locked message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please master the previous lesson first'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Build the final test card that appears after Lesson 6
  Widget _buildFinalTestCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: _handleFinalTestTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phase 1 Final Test',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Test your mastery of all 6 lessons',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.quiz, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '20 Questions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (_hasPassedTest) ...[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Passed${_lastTestScore != null ? ' ($_lastTestScore/20)' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle final test card tap
  void _handleFinalTestTap() async {
    // Navigate to final test screen
    await Navigator.pushNamed(context, AppRoutes.phase1FinalTest);

    // Refresh test status after returning
    if (mounted) {
      await _initializeTestService();
    }
  }
}
