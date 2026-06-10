import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../../services/audio_service.dart';
import '../../../../../app/theme.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/constants/app_strings.dart';

/// Listen tab widget for listening comprehension practice
/// Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6
class ListenTab extends StatefulWidget {
  const ListenTab({super.key});

  @override
  State<ListenTab> createState() => _ListenTabState();
}

class _ListenTabState extends State<ListenTab> {
  final AudioService _audioService = AudioService();
  final Map<int, int?> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  final Map<int, bool> _answeredCorrectly = {}; // questionIndex -> isCorrect
  bool _hasMarkedComplete = false;
  int? _currentlyPlayingIndex;
  bool _ttsUnavailable = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioService.init();
    } catch (e) {
      ErrorHandler.logError('ListenTab.initAudio', e);
      setState(() {
        _ttsUnavailable = true;
      });
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, e);
      }
    }
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  Future<void> _playQuestion(int index, String audioText) async {
    if (_ttsUnavailable) {
      ErrorHandler.showInfoSnackbar(
        context,
        'Audio playback is currently unavailable',
      );
      return;
    }

    setState(() {
      _currentlyPlayingIndex = index;
    });

    try {
      await _audioService.speak(audioText);
    } catch (e) {
      ErrorHandler.logError('ListenTab.playQuestion', e);
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, e);
      }
      setState(() {
        _ttsUnavailable = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _currentlyPlayingIndex = null;
        });
      }
    }
  }

  void _selectAnswer(int questionIndex, int optionIndex, int correctIndex) {
    if (_selectedAnswers.containsKey(questionIndex)) {
      // Already answered, don't allow changing
      return;
    }

    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
      _answeredCorrectly[questionIndex] = (optionIndex == correctIndex);
    });

    final answeredCount = _selectedAnswers.length;
    final lessonProvider = context.read<LessonProvider>();
    final lesson = lessonProvider.currentLesson;
    final totalCount = lesson?.listeningQuestions.length ?? 0;
    final correctCount = _answeredCorrectly.values.where((correct) => correct).length;
    final accuracy = answeredCount == 0 ? 0.0 : (correctCount / answeredCount);
    lessonProvider.updateListenProgress(
      answeredCount: answeredCount,
      totalCount: totalCount,
      accuracy: accuracy,
    );

    // Check if we should mark as complete
    _checkCompletion();
  }

  void _checkCompletion() {
    // Need at least 3 questions answered
    if (_selectedAnswers.length < 3) {
      return;
    }

    // Calculate accuracy
    int correctCount = _answeredCorrectly.values.where((correct) => correct).length;
    double accuracy = correctCount / _selectedAnswers.length;

    // Mark complete if 70%+ accuracy and haven't marked yet
    if (accuracy >= 0.7 && !_hasMarkedComplete) {
      _hasMarkedComplete = true;
      if (mounted) {
        final lessonProvider = context.read<LessonProvider>();
        lessonProvider.updateListeningScore(accuracy);
      }
    }
  }

  void _retryListen() {
    setState(() {
      _selectedAnswers.clear();
      _answeredCorrectly.clear();
      _hasMarkedComplete = false;
    });

    context.read<LessonProvider>().updateListenProgress(
      answeredCount: 0,
      totalCount: context.read<LessonProvider>().currentLesson?.listeningQuestions.length ?? 0,
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

    final questions = lesson.listeningQuestions;

    if (questions.isEmpty) {
      return const Center(
        child: Text('No listening questions available'),
      );
    }

    // Calculate current accuracy
    int correctCount = _answeredCorrectly.values.where((correct) => correct).length;
    double accuracy = _selectedAnswers.isEmpty ? 0.0 : correctCount / _selectedAnswers.length;
    final hasCompletedAll = _selectedAnswers.length == questions.length;
    final needsRetry = hasCompletedAll && accuracy < 0.7;
    lessonProvider.updateListenProgress(
      answeredCount: _selectedAnswers.length,
      totalCount: questions.length,
      accuracy: accuracy,
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
                Icons.headphones,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.listenRuleEn,
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.listenRuleTa,
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Answered: ${_selectedAnswers.length} / ${questions.length} | Accuracy: ${(accuracy * 100).toStringAsFixed(0)}%',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedAnswers.length >= 3 && accuracy >= 0.7)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
            ],
          ),
        ),

        if (needsRetry)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.incorrectColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.incorrectColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.listenRetryMessageEn,
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.listenRetryMessageTa,
                  style: AppTheme.bodyText2.copyWith(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _retryListen,
                  icon: const Icon(Icons.refresh),
                  label: const Text(AppStrings.tryAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
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
              final isPlaying = _currentlyPlayingIndex == index;

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
                      // Question header with audio button
                      Row(
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: AppTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: isPlaying
                                  ? AppTheme.accentColor
                                  : AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isPlaying ? Icons.stop : Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: isPlaying
                                  ? () => _audioService.stop()
                                  : () => _playQuestion(index, question.audioText),
                            ),
                          ),
                        ],
                      ),
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
