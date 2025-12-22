import 'package:flutter/material.dart';
import '../../data/models/phase5_test_result.dart';
import '../../../../app/theme.dart';

/// Phase 5 Final Test Review Screen
/// Displays incorrect MCQ answers for review
/// Speaking tasks are excluded from review
/// 
/// Requirements: 8.1, 8.2, 8.3, 8.4
class Phase5FinalTestReviewScreen extends StatelessWidget {
  final List<Phase5IncorrectAnswer> incorrectAnswers;

  const Phase5FinalTestReviewScreen({super.key, required this.incorrectAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Mistakes'),
        centerTitle: true,
      ),
      body: incorrectAnswers.isEmpty
          ? _buildNoMistakesView(context)
          : _buildMistakesList(context),
    );
  }

  Widget _buildNoMistakesView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
            const SizedBox(height: AppTheme.spacingM),
            const Text(
              'Perfect Score!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Text(
              'You answered all MCQ questions correctly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakesList(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          color: Colors.orange[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700]),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  '${incorrectAnswers.length} incorrect answer${incorrectAnswers.length > 1 ? 's' : ''} to review',
                  style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: incorrectAnswers.length,
            itemBuilder: (context, index) {
              return _buildMistakeCard(context, incorrectAnswers[index], index + 1);
            },
          ),
        ),
        _buildBottomButtons(context),
      ],
    );
  }

  Widget _buildMistakeCard(BuildContext context, Phase5IncorrectAnswer mistake, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    _getQuestionTypeLabel(mistake.question.type),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              mistake.question.prompt,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildAnswerRow(
              icon: Icons.close,
              iconColor: Colors.red,
              label: 'Your answer:',
              answer: mistake.selectedAnswer,
              backgroundColor: Colors.red[50]!,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _buildAnswerRow(
              icon: Icons.check,
              iconColor: Colors.green,
              label: 'Correct answer:',
              answer: mistake.correctAnswer,
              backgroundColor: Colors.green[50]!,
            ),
          ],
        ),
      ),
    );
  }

  String _getQuestionTypeLabel(dynamic type) {
    switch (type.toString()) {
      case 'Phase5QuestionType.businessEnglish':
        return 'Business English';
      case 'Phase5QuestionType.interview':
        return 'Interview';
      case 'Phase5QuestionType.presentation':
        return 'Presentation';
      case 'Phase5QuestionType.writing':
        return 'Writing';
      default:
        return 'MCQ';
    }
  }

  Widget _buildAnswerRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String answer,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  answer,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Results'),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
