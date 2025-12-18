import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../../../../core/widgets/lesson_card.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../app/routes.dart';

/// Screen displaying all lessons for a specific Phase 4 unit
/// Shows lesson cards with lock status and progress indicators
/// Requirements: 2.4, 3.1, 3.2, 3.3
class Phase4LessonListScreen extends StatefulWidget {
  final String unitId;
  final String? unitTitle;

  const Phase4LessonListScreen({
    super.key,
    required this.unitId,
    this.unitTitle,
  });

  @override
  State<Phase4LessonListScreen> createState() => _Phase4LessonListScreenState();
}

class _Phase4LessonListScreenState extends State<Phase4LessonListScreen> {
  bool _isPhase4Unlocked = false;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndStatus();
    });
  }

  /// Load progress data and Phase 4 unlock status
  Future<void> _loadDataAndStatus() async {
    try {
      await context.read<ProgressProvider>().loadAllData();
      await _loadPhase4Status();
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  /// Load Phase 4 unlock status
  /// In development mode, Phase 4 is always unlocked
  Future<void> _loadPhase4Status() async {
    try {
      if (AppConfig.isDevelopmentMode) {
        if (mounted) {
          setState(() {
            _isPhase4Unlocked = true;
            _isLoadingStatus = false;
          });
        }
        return;
      }

      // Check Phase 4 unlock status via GatingService if available
      // For now, we'll use the ProgressProvider's cached status
      if (mounted) {
        setState(() {
          _isPhase4Unlocked = true; // Phase 4 is unlocked if user can access this screen
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading Phase 4 status: $e');
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  /// Get the unit title based on unit ID
  String _getUnitTitle(String unitId) {
    if (widget.unitTitle != null) {
      return 'Unit ${_getUnitNumber(unitId)}: ${widget.unitTitle}';
    }
    switch (unitId) {
      case 'phase4_unit18':
        return 'Unit 18: Pronunciation & Sound';
      case 'phase4_unit19':
        return 'Unit 19: Fluency Techniques';
      case 'phase4_unit20':
        return 'Unit 20: Real-Life Conversations';
      case 'phase4_unit21':
        return 'Unit 21: Discussion & Opinion Skills';
      default:
        return 'Unit Lessons';
    }
  }

  /// Extract unit number from unit ID
  int _getUnitNumber(String unitId) {
    final match = RegExp(r'phase4_unit(\d+)').firstMatch(unitId);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// Check if a Phase 4 lesson is unlocked based on progressive unlocking
  /// Requirements: 3.1, 3.2, 3.3
  bool _isLessonUnlocked(String lessonId, ProgressProvider progressProvider) {
    // Development mode: all lessons are unlocked
    if (AppConfig.isDevelopmentMode) {
      return true;
    }

    // First lesson of Unit 18 is unlocked when Phase 4 is unlocked
    if (lessonId == 'phase4_lesson18_1') {
      return _isPhase4Unlocked;
    }

    // Get previous lesson ID
    final previousLessonId = _getPhase4PreviousLessonId(lessonId);
    if (previousLessonId == null) {
      return false;
    }

    // Check if previous lesson is mastered
    final previousStatus = progressProvider.getLessonStatus(previousLessonId);
    return previousStatus?.isMastered ?? false;
  }

  /// Get the previous lesson ID in the Phase 4 sequence
  /// Handles both within-unit and cross-unit progression
  /// Requirements: 3.2, 3.3
  String? _getPhase4PreviousLessonId(String lessonId) {
    final lessonSequence = {
      // Unit 18: Pronunciation & Sound (4 lessons)
      'phase4_lesson18_2': 'phase4_lesson18_1',
      'phase4_lesson18_3': 'phase4_lesson18_2',
      'phase4_lesson18_4': 'phase4_lesson18_3',
      // Unit 19: Fluency Techniques (4 lessons) - first lesson requires Unit 18 completion
      'phase4_lesson19_1': 'phase4_lesson18_4',
      'phase4_lesson19_2': 'phase4_lesson19_1',
      'phase4_lesson19_3': 'phase4_lesson19_2',
      'phase4_lesson19_4': 'phase4_lesson19_3',
      // Unit 20: Real-Life Conversations (5 lessons) - first lesson requires Unit 19 completion
      'phase4_lesson20_1': 'phase4_lesson19_4',
      'phase4_lesson20_2': 'phase4_lesson20_1',
      'phase4_lesson20_3': 'phase4_lesson20_2',
      'phase4_lesson20_4': 'phase4_lesson20_3',
      'phase4_lesson20_5': 'phase4_lesson20_4',
      // Unit 21: Discussion & Opinion Skills (4 lessons) - first lesson requires Unit 20 completion
      'phase4_lesson21_1': 'phase4_lesson20_5',
      'phase4_lesson21_2': 'phase4_lesson21_1',
      'phase4_lesson21_3': 'phase4_lesson21_2',
      'phase4_lesson21_4': 'phase4_lesson21_3',
    };

    return lessonSequence[lessonId];
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
          if (progressProvider.isLoading || _isLoadingStatus) {
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
                  const SizedBox(height: 8),
                  Text(
                    'Lessons for this unit are coming soon',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
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
              final isUnlocked = _isLessonUnlocked(lesson.id, progressProvider);

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
  /// Requirements: 2.4
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
      await _loadPhase4Status();
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
