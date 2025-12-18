import 'package:flutter/material.dart';
import '../../data/models/phase4_test_result.dart';
import '../../../../app/theme.dart';

/// Phase 4 Final Test Review Screen (Placeholder)
/// Will be fully implemented in task 13
/// 
/// Requirements: 7.1, 7.2, 7.3, 7.4
class Phase4FinalTestReviewScreen extends StatelessWidget {
  final List<Phase4IncorrectAnswer> incorrectAnswers;

  const Phase4FinalTestReviewScreen({
    super.key,
    required this.incorrectAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Mistakes'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: incorrectAnswers.isEmpty
            ? _buildNoMistakesMessage()
            : _buildMistakesList(),
      ),
    );
  }

  Widget _buildNoMistakesMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: AppTheme.correctColor,
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'No mistakes to review!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: incorrectAnswers.length,
      itemBuilder: (context, index) {
        final mistake = incorrectAnswers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  mistake.question.prompt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildAnswerRow(
                  'Your answer:',
                  mistake.selectedAnswer,
                  AppTheme.incorrectColor,
                  Icons.close,
                ),
                const SizedBox(height: AppTheme.spacingS),
                _buildAnswerRow(
                  'Correct answer:',
                  mistake.correctAnswer,
                  AppTheme.correctColor,
                  Icons.check,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
