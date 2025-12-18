import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../../../../core/widgets/lesson_card.dart';
import '../../../../app/routes.dart';

/// Screen displaying all lessons for a specific Phase 3 unit
/// Shows lesson cards with lock status and progress indicators
class Phase3LessonListScreen extends StatefulWidget {
  final String unitId;

  const Phase3LessonListScreen({
    super.key,
    required this.unitId,
  });

  @override
  State<Phase3LessonListScreen> createState() => _Phase3LessonListScreenState();
}

class _Phase3LessonListScreenState extends State<Phase3LessonListScreen> {
  @override
  void initState() {
    super.initState();
    // Load lesson data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Load progress data
  Future<void> _loadData() async {
    try {
      await context.read<ProgressProvider>().loadAllData();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  /// Get the unit title based on unit ID
  String _getUnitTitle(String unitId) {
    switch (unitId) {
      case 'phase3_unit12':
        return 'Unit 12: Story Listening & Retelling';
      case 'phase3_unit13':
        return 'Unit 13: Complex Sentences & Connectors';
      case 'phase3_unit14':
        return 'Unit 14: Passive Voice';
      case 'phase3_unit15':
        return 'Unit 15: Reported Speech';
      case 'phase3_unit16':
        return 'Unit 16: Functional English';
      case 'phase3_unit17':
        return 'Unit 17: Speaking & Writing Projects';
      default:
        return 'Unit Lessons';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getUnitTitle(widget.unitId)),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          // Show loading indicator
          if (progressProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error message
          if (progressProvider.error != null) {
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

          // Get lessons for this unit
          final lessons = progressProvider.getUnitLessons(widget.unitId);

          // Show empty state if no lessons
          if (lessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No lessons available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          // Show lesson list
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final status = progressProvider.getLessonStatus(lesson.id);
              final isUnlocked = progressProvider.isLessonUnlocked(lesson.id);

              return LessonCard(
                lesson: lesson,
                status: status,
                isUnlocked: isUnlocked,
                onTap: () => _handleLessonTap(
                  context,
                  lesson.id,
                  isUnlocked,
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Handle lesson card tap
  /// Navigates to lesson if unlocked, shows snackbar if locked
  void _handleLessonTap(
    BuildContext context,
    String lessonId,
    bool isUnlocked,
  ) async {
    if (isUnlocked) {
      // Navigate to lesson screen
      await Navigator.pushNamed(
        context,
        AppRoutes.lesson,
        arguments: lessonId,
      );

      // Refresh progress after returning from lesson
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      await context.read<ProgressProvider>().reload();
    } else {
      // Show locked message snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please master the previous lesson first'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
