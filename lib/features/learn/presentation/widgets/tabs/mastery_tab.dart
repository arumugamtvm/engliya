import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../../services/mastery_service.dart';
import '../../../data/models/quiz_question.dart';
import '../../../../../app/theme.dart';

/// Mastery tab widget for final mastery test
/// Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8
class MasteryTab extends StatefulWidget {
  const MasteryTab({super.key});

  @override
  State<MasteryTab> createState() => _MasteryTabState();
}

class _MasteryTabState extends State<MasteryTab> {
  final MasteryService _masteryService = MasteryService();
  
  bool _isTestStarted = false;
  List<QuizQuestion> _testQuestions = [];
  final Map<int, int?> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  final Map<int, bool> _answeredCorrectly = {}; // questionIndex -> isCorrect
  bool _hasMarkedComplete = false;
  bool _showFinalScore = false;

  void _startMasteryTest() {
    final lessonProvider = context.read<LessonProvider>();
    final lesson = lessonProvider.currentLesson;
    
    if (lesson == null) return;

    setState(() {
      _isTestStarted = true;
      _testQuestions = _masteryService.generateMasteryTest(lesson);
      _selectedAnswers.clear();
      _answeredCorrectly.clear();
      _hasMarkedComplete = false;
      _showFinalScore = false;
    });
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

    // Check if all questions are answered
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_selectedAnswers.length == _testQuestions.length) {
      // Calculate total score
      int correctCount = _answeredCorrectly.values.where((correct) => correct).length;
      double scorePercentage = correctCount / _testQuestions.length;

      setState(() {
        _showFinalScore = true;
      });

      // Mark as mastered if score >= 80% and haven't marked yet
      if (!_hasMarkedComplete) {
        _hasMarkedComplete = true;
        final lessonProvider = context.read<LessonProvider>();
        lessonProvider.updateMasteryScore(scorePercentage);

        // Trigger progress provider refresh to unlock next lesson
        if (scorePercentage >= 0.8) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<ProgressProvider>().loadAllData();
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final lesson = lessonProvider.currentLesson;
    final status = lessonProvider.currentStatus;

    if (lesson == null || status == null) {
      return const Center(
        child: Text('No lesson data available'),
      );
    }

    // If test not started, show summary view
    if (!_isTestStarted) {
      return _buildSummaryView(status);
    }

    // Show test view
    return _buildTestView();
  }

  Widget _buildSummaryView(status) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppTheme.primaryColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mastery Test',
                    style: AppTheme.headline2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete this test with 80% or higher to master this lesson',
                    style: AppTheme.bodyText2.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Previous scores summary
          Text(
            'Your Progress',
            style: AppTheme.headline2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Practice score
          _buildScoreCard(
            'Practice Quiz',
            status.quizBestScore,
            Icons.quiz,
            AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),

          // Listening score
          _buildScoreCard(
            'Listening',
            status.listeningScore,
            Icons.headphones,
            AppTheme.accentColor,
          ),
          const SizedBox(height: 12),

          // Speaking score
          _buildScoreCard(
            'Speaking',
            status.speakingScore,
            Icons.mic,
            Colors.orange,
          ),
          const SizedBox(height: 24),

          // Previous mastery score (if exists)
          if (status.masteryBestScore > 0) ...[
            Text(
              'Previous Mastery Score',
              style: AppTheme.headline2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
              'Best Mastery Score',
              status.masteryBestScore,
              Icons.emoji_events,
              status.isMastered ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 24),
          ],

          // Mastery status
          if (status.isMastered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lesson Mastered!',
                          style: AppTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You can retake the test to improve your score',
                          style: AppTheme.bodyText2.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complete the mastery test to unlock the next lesson',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Start test button
          ElevatedButton(
            onPressed: _startMasteryTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status.isMastered ? Icons.refresh : Icons.play_arrow,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  status.isMastered ? 'Retake Mastery Test' : 'Start Mastery Test',
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String title, double score, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    score > 0 ? '${(score * 100).toStringAsFixed(0)}%' : 'Not completed',
                    style: AppTheme.bodyText2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (score >= 0.7)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestView() {
    // Calculate current score
    int correctCount = _answeredCorrectly.values.where((correct) => correct).length;
    double scorePercentage = _selectedAnswers.isEmpty 
        ? 0.0 
        : correctCount / _testQuestions.length;

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mastery Test',
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Answered: ${_selectedAnswers.length} / ${_testQuestions.length}',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (_showFinalScore && scorePercentage >= 0.8)
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
              color: scorePercentage >= 0.8
                  ? AppTheme.correctColor.withOpacity(0.1)
                  : AppTheme.incorrectColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scorePercentage >= 0.8
                    ? AppTheme.correctColor
                    : AppTheme.incorrectColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  scorePercentage >= 0.8
                      ? Icons.emoji_events
                      : Icons.refresh,
                  color: scorePercentage >= 0.8
                      ? AppTheme.correctColor
                      : AppTheme.incorrectColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  scorePercentage >= 0.8 ? 'Lesson Mastered!' : 'Keep Practicing',
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(scorePercentage * 100).toStringAsFixed(0)}%',
                  style: AppTheme.headline1.copyWith(
                    color: scorePercentage >= 0.8
                        ? AppTheme.correctColor
                        : AppTheme.incorrectColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scorePercentage >= 0.8
                      ? 'Congratulations! You\'ve mastered this lesson!'
                      : 'You need 80% or higher to master this lesson',
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${correctCount} / ${_testQuestions.length} correct',
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (scorePercentage >= 0.8) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_open,
                          color: Colors.green[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Next lesson unlocked!',
                          style: AppTheme.bodyText2.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
            itemCount: _testQuestions.length,
            itemBuilder: (context, index) {
              final question = _testQuestions[index];
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
                            ? AppTheme.correctColor.withOpacity(0.3)
                            : AppTheme.incorrectColor.withOpacity(0.3))
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
                            buttonColor = AppTheme.correctColor.withOpacity(0.3);
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
                                isCorrect ? 'Correct!' : 'Incorrect',
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
