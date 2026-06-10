import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../../services/mastery_service.dart';
import '../../../data/models/quiz_question.dart';
import '../../../data/models/user_lesson_status.dart';
import '../../../../../app/theme.dart';
import '../../../../../core/constants/app_strings.dart';

enum MasteryTestLifecycle {
  preTest,
  inProgress,
  completedPass,
  completedFail,
}

class MasteryTab extends StatefulWidget {
  const MasteryTab({super.key});

  @override
  State<MasteryTab> createState() => _MasteryTabState();
}

class _MasteryTabState extends State<MasteryTab> {
  final MasteryService _masteryService = MasteryService();

  List<QuizQuestion> _testQuestions = [];
  final Map<int, int?> _selectedAnswers = {};
  final Map<int, bool> _answeredCorrectly = {};
  bool _hasMarkedComplete = false;
  bool _isResetting = false;
  MasteryTestLifecycle _lifecycle = MasteryTestLifecycle.preTest;

  double get _scorePercentage {
    if (_testQuestions.isEmpty) return 0;
    final correctCount = _answeredCorrectly.values.where((correct) => correct).length;
    return correctCount / _testQuestions.length;
  }

  int get _correctCount => _answeredCorrectly.values.where((correct) => correct).length;

  void _startMasteryTest() {
    final lessonProvider = context.read<LessonProvider>();
    final lesson = lessonProvider.currentLesson;
    if (lesson == null) return;

    setState(() {
      _lifecycle = MasteryTestLifecycle.inProgress;
      _testQuestions = _masteryService.generateMasteryTest(lesson);
      _selectedAnswers.clear();
      _answeredCorrectly.clear();
      _hasMarkedComplete = false;
    });

    lessonProvider.updateMasteryProgress(
      answeredCount: 0,
      totalCount: _testQuestions.length,
      accuracy: 0,
    );
  }

  Future<void> _tryAgain() async {
    if (_isResetting) return;
    setState(() {
      _isResetting = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _startMasteryTest();
    if (!mounted) return;
    setState(() {
      _isResetting = false;
    });
  }

  void _selectAnswer(int questionIndex, int optionIndex, int correctIndex) {
    if (_selectedAnswers.containsKey(questionIndex)) {
      return;
    }

    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
      _answeredCorrectly[questionIndex] = optionIndex == correctIndex;
    });

    _updateValidationProgress();
    _checkCompletion();
  }

  void _updateValidationProgress() {
    if (!mounted) return;
    context.read<LessonProvider>().updateMasteryProgress(
          answeredCount: _selectedAnswers.length,
          totalCount: _testQuestions.length,
          accuracy: _scorePercentage,
        );
  }

  void _checkCompletion() {
    if (_selectedAnswers.length != _testQuestions.length) {
      return;
    }

    final scorePercentage = _scorePercentage;

    setState(() {
      _lifecycle = scorePercentage >= 0.8
          ? MasteryTestLifecycle.completedPass
          : MasteryTestLifecycle.completedFail;
    });

    if (!_hasMarkedComplete) {
      _hasMarkedComplete = true;
      final lessonProvider = context.read<LessonProvider>();
      lessonProvider.updateMasteryScore(scorePercentage);
      _updateValidationProgress();

      if (scorePercentage >= 0.8) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.read<ProgressProvider>().loadAllData();
          }
        });
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
        child: Text(
          AppStrings.noLessonData,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_lifecycle == MasteryTestLifecycle.preTest) {
      return _buildSummaryView(status);
    }

    return _buildTestView();
  }

  Widget _buildSummaryView(UserLessonStatus status) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.emoji_events, color: AppTheme.primaryColor, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Mastery Test',
                    style: AppTheme.headline2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.masteryRuleEn,
                    style: AppTheme.bodyText2.copyWith(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.masteryRuleTa,
                    style: AppTheme.bodyText2.copyWith(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Your Progress', style: AppTheme.headline2.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildScoreCard('Practice Quiz', status.quizBestScore, Icons.quiz, AppTheme.primaryColor),
          const SizedBox(height: 12),
          _buildScoreCard('Listening', status.listeningScore, Icons.headphones, AppTheme.accentColor),
          const SizedBox(height: 12),
          _buildScoreCard('Speaking', status.speakingScore, Icons.mic, Colors.orange),
          const SizedBox(height: 24),
          if (status.masteryBestScore > 0) ...[
            Text('Previous Mastery Score', style: AppTheme.headline2.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildScoreCard(
              'Best Mastery Score',
              status.masteryBestScore,
              Icons.emoji_events,
              status.isMastered ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 24),
          ],
          ElevatedButton(
            onPressed: _startMasteryTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(status.isMastered ? Icons.refresh : Icons.play_arrow, size: 24),
                const SizedBox(width: 8),
                Text(
                  status.isMastered ? 'Retake Mastery Test' : 'Start Mastery Test',
                  style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    score > 0 ? '${(score * 100).toStringAsFixed(0)}%' : 'Not completed',
                    style: AppTheme.bodyText2.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (score >= 0.7) const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTestView() {
    final scorePercentage = _scorePercentage;
    final isPass = _lifecycle == MasteryTestLifecycle.completedPass;
    final isFail = _lifecycle == MasteryTestLifecycle.completedFail;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mastery Test', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Answered: ${_selectedAnswers.length} / ${_testQuestions.length}',
                      style: AppTheme.bodyText2.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              if (isPass) const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ],
          ),
        ),
        if (isPass || isFail)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isPass ? AppTheme.correctColor.withValues(alpha: 0.1) : AppTheme.incorrectColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isPass ? AppTheme.correctColor : AppTheme.incorrectColor, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  isPass ? Icons.emoji_events : Icons.refresh,
                  color: isPass ? AppTheme.correctColor : AppTheme.incorrectColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  isPass ? AppStrings.lessonMastered : AppStrings.keepPracticing,
                  style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(scorePercentage * 100).toStringAsFixed(0)}%',
                  style: AppTheme.headline1.copyWith(
                    color: isPass ? AppTheme.correctColor : AppTheme.incorrectColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPass
                      ? AppStrings.masteryPassedDetail
                      : AppStrings.masteryFailedDetail,
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_correctCount / ${_testQuestions.length} correct',
                  style: AppTheme.bodyText2.copyWith(color: Colors.grey[600]),
                ),
                if (isFail) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isResetting ? null : _tryAgain,
                      icon: _isResetting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _isResetting ? 'Restarting...' : AppStrings.tryAgain,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                        ? (isCorrect ? AppTheme.correctColor.withValues(alpha: 0.3) : AppTheme.incorrectColor.withValues(alpha: 0.3))
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.promptEn,
                        style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      if (question.promptTa != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          question.promptTa!,
                          style: AppTheme.bodyText2.copyWith(color: Colors.grey[700], fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 16),
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
                            buttonColor = AppTheme.correctColor.withValues(alpha: 0.3);
                            textColor = AppTheme.correctColor;
                            icon = Icons.check_circle;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: isAnswered ? null : () => _selectAnswer(index, optionIndex, question.correctIndex),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor ?? Colors.white,
                              foregroundColor: textColor ?? Colors.black87,
                              elevation: isSelected ? 4 : 1,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: buttonColor ?? Colors.grey[300]!, width: 1),
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
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (icon != null) Icon(icon, color: textColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      }),
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
