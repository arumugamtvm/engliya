import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../../domain/entities/phase_units.dart';
import '../../../../core/widgets/lesson_card.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_strings.dart';

class PhaseLessonListScreen extends StatefulWidget {
  final String unitId;
  final String? unitTitle;

  const PhaseLessonListScreen({
    super.key,
    required this.unitId,
    this.unitTitle,
  });

  @override
  State<PhaseLessonListScreen> createState() => _PhaseLessonListScreenState();
}

class _PhaseLessonListScreenState extends State<PhaseLessonListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await context.read<ProgressProvider>().loadAllData();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  String _getUnitTitle() {
    final unitDefinition = PhaseUnits.findById(widget.unitId);
    final unitNumber = unitDefinition?.order ?? _extractUnitNumber();
    final unitTitle = widget.unitTitle ?? unitDefinition?.title;

    if (unitNumber != null && unitTitle != null) {
      return 'Unit $unitNumber: $unitTitle';
    }
    if (unitTitle != null) {
      return unitTitle;
    }
    return 'Unit Lessons';
  }

  int? _extractUnitNumber() {
    final match = RegExp(r'unit(\d+)').firstMatch(widget.unitId);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getUnitTitle()),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          if (progressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (progressProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(AppStrings.errorLoadingLessons,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
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
                    onPressed: () => progressProvider.reload(),
                    child: const Text(AppStrings.tryAgain),
                  ),
                ],
              ),
            );
          }

          final lessons = progressProvider.getUnitLessons(widget.unitId);
          if (lessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(AppStrings.noLessonsAvailable,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            );
          }

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
                onTap: () =>
                    _handleLessonTap(context, lesson.id, isUnlocked),
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
      await Navigator.pushNamed(
        context,
        AppRoutes.lesson,
        arguments: lessonId,
      );

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      await context.read<ProgressProvider>().reload();
    } else {
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
