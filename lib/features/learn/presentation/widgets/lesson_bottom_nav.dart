import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../../../../core/utils/error_handler.dart';

class LessonBottomNav extends StatelessWidget {
  const LessonBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        final canGoPrevious = lessonProvider.canGoPrevious;
        final canGoNext = lessonProvider.canGoNext;
        final isFinalTab = lessonProvider.isOnFinalTab;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Previous Step Button
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Previous',
                    child: OutlinedButton.icon(
                      onPressed: canGoPrevious
                          ? () {
                              lessonProvider.goToPreviousTab();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledForegroundColor: Colors.grey[400],
                        side: BorderSide(
                          color: canGoPrevious ? Theme.of(context).primaryColor : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Next Step Button
                Expanded(
                  child: Semantics(
                    button: true,
                    label: isFinalTab ? 'Complete' : 'Next',
                    child: ElevatedButton.icon(
                      onPressed: canGoNext
                          ? () {
                              final validation = lessonProvider.validateCurrentTab();
                              if (!validation.isValid) {
                                ErrorHandler.showWarningSnackbar(
                                  context,
                                  validation.message,
                                  actionLabel: validation.actionLabel,
                                );
                                return;
                              }
                              lessonProvider.goToNextTab();
                            }
                          : null,
                      label: Text(isFinalTab ? 'Complete' : 'Next'),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
