import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../../../../app/theme.dart';
import '../../../../../core/constants/app_strings.dart';

/// Practice tab widget for quiz practice
/// Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7
class PracticeTab extends StatefulWidget {
  const PracticeTab({super.key});

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  final Map<int, int?> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  final Map<int, bool> _answeredCorrectly = {}; // questionIndex -> isCorrect
  bool _hasMarkedComplete = false;
  bool _showFinalScore = false;

  void _selectAnswer(int questionIndex, int optionIndex, int correctIndex) {
    if (_selectedAnswers.containsKey(questionIndex)) {
      // Already answered, don't allow changing
      return;
    }

    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
      _answeredCorrectly[questionIndex] = (optionIndex == correctIndex);
    });

    final lessonProvider = context.read<LessonProvider>();
    final lesson = lessonProvider.currentLesson;
    final totalQuestions = lesson?.practiceQuestions.length ?? 0;
    final correctCount = _answeredCorrectly.values.where((correct) => correct).length;
    final accuracy = totalQuestions == 0 ? 0.0 : (correctCount / totalQuestions);
    lessonProvider.updatePracticeProgress(
      answeredCount: _selectedAnswers.length,
      totalCount: totalQuestions,
      accuracy: accuracy,
    );

    // Check if all questions are answered
    _checkCompletion();
  }

  void _checkCompletion() {
    final lessonProvider = context.read<LessonProvider>();
    final lesson = lessonProvider.currentLesson;
    
    if (lesson == null) return;

    final totalQuestions = lesson.practiceQuestions.length;

    // Check if all questions are answered
    if (_selectedAnswers.length == totalQuestions) {
      // Calculate total score
      int correctCount = _answeredCorrectly.values.where((correct) => correct).length;
      double scorePercentage = correctCount / totalQuestions;

      setState(() {
        _showFinalScore = true;
      });

      // Mark complete if score >= 60% and haven't marked yet
      if (scorePercentage >= 0.6 && !_hasMarkedComplete) {
        _hasMarkedComplete = true;
        lessonProvider.updateQuizScore(scorePercentage);
      }
    }
  }

  void _retryPractice() {
    setState(() {
      _selectedAnswers.clear();
      _answeredCorrectly.clear();
      _hasMarkedComplete = false;
      _showFinalScore = false;
    });

    context.read<LessonProvider>().updatePracticeProgress(
      answeredCount: 0,
      totalCount: context.read<LessonProvider>().currentLesson?.practiceQuestions.length ?? 0,
      accuracy: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final lesson = lessonProvider.currentLesson;

    if (lesson == null) {
      return const Center(
        child: Text(
          AppStrings.noLessonData,
          textAlign: TextAlign.center,
        ),
      );
    }

    final questions = lesson.practiceQuestions;

    if (questions.isEmpty) {
      return const Center(
        child: Text('No practice questions available'),
      );
    }

    // Calculate current score
    int correctCount = _answeredCorrectly.values.where((correct) => correct).length;
    double scorePercentage = _selectedAnswers.isEmpty 
        ? 0.0 
        : correctCount / questions.length;
    lessonProvider.updatePracticeProgress(
      answeredCount: _selectedAnswers.length,
      totalCount: questions.length,
      accuracy: scorePercentage,
    );

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(
                Icons.quiz,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.practiceRuleEn,
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.practiceRuleTa,
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Answered: ${_selectedAnswers.length} / ${questions.length}',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (_showFinalScore && scorePercentage >= 0.6)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
            ],
          ),
        ),

        // Final score display
        if (_showFinalScore)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scorePercentage >= 0.6
                  ? AppTheme.correctColor.withValues(alpha: 0.1)
                  : AppTheme.incorrectColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scorePercentage >= 0.6
                    ? AppTheme.correctColor
                    : AppTheme.incorrectColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  scorePercentage >= 0.6
                      ? Icons.celebration
                      : Icons.refresh,
                  color: scorePercentage >= 0.6
                      ? AppTheme.correctColor
                      : AppTheme.incorrectColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Final Score',
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(scorePercentage * 100).toStringAsFixed(0)}%',
                  style: AppTheme.headline1.copyWith(
                    color: scorePercentage >= 0.6
                        ? AppTheme.correctColor
                        : AppTheme.incorrectColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scorePercentage >= 0.6
                      ? AppStrings.practicePassed
                      : AppStrings.practiceFailed,
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$correctCount / ${questions.length} correct',
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (scorePercentage < 0.6) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _retryPractice,
                    icon: const Icon(Icons.refresh),
                    label: const Text(AppStrings.tryAgain),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Questions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final selectedAnswer = _selectedAnswers[index];
              final isAnswered = selectedAnswer != null;
              final isCorrect = _answeredCorrectly[index] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isAnswered
                        ? (isCorrect
                            ? AppTheme.correctColor.withValues(alpha: 0.3)
                            : AppTheme.incorrectColor.withValues(alpha: 0.3))
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question header
                      Text(
                        'Question ${index + 1}',
                        style: AppTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Question prompt (English)
                      Text(
                        question.promptEn,
                        style: AppTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      // Question prompt (Tamil)
                      if (question.promptTa != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          question.promptTa!,
                          style: AppTheme.bodyText2.copyWith(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Answer options
                      ...List.generate(question.options.length, (optionIndex) {
                        final option = question.options[optionIndex];
                        final isSelected = selectedAnswer == optionIndex;
                        final isCorrectOption = optionIndex == question.correctIndex;
                        
                        Color? buttonColor;
                        Color? textColor;
                        IconData? icon;

                        if (isAnswered) {
                          if (isSelected) {
                            if (isCorrect) {
                              buttonColor = AppTheme.correctColor;
                              textColor = Colors.white;
                              icon = Icons.check_circle;
                            } else {
                              buttonColor = AppTheme.incorrectColor;
                              textColor = Colors.white;
                              icon = Icons.cancel;
                            }
                          } else if (isCorrectOption) {
                            // Show correct answer if user selected wrong
                            buttonColor = AppTheme.correctColor.withValues(alpha: 0.3);
                            textColor = AppTheme.correctColor;
                            icon = Icons.check_circle;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: isAnswered
                                ? null
                                : () => _selectAnswer(index, optionIndex, question.correctIndex),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor ?? Colors.white,
                              foregroundColor: textColor ?? Colors.black87,
                              elevation: isSelected ? 4 : 1,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: buttonColor ?? Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: AppTheme.bodyText2.copyWith(
                                      color: textColor,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (icon != null)
                                  Icon(
                                    icon,
                                    color: textColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Feedback message
                      if (isAnswered)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect
                                    ? AppTheme.correctColor
                                    : AppTheme.incorrectColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCorrect
                                    ? AppStrings.correct
                                    : AppStrings.incorrect,
                                style: AppTheme.bodyText2.copyWith(
                                  color: isCorrect
                                      ? AppTheme.correctColor
                                      : AppTheme.incorrectColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
