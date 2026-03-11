import 'package:flutter/material.dart';

import '../../data/models/phase4_final_test_question.dart';
import '../../data/models/phase4_test_result.dart';
import '../../data/models/phase5_final_test_question.dart';
import '../../data/models/phase5_test_result.dart';
import '../../../../app/theme.dart';

class FinalTestReviewItem {
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final String? categoryLabel;

  const FinalTestReviewItem({
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    this.categoryLabel,
  });
}

class FinalTestReviewConfig {
  final String title;
  final String emptyTitle;
  final String? emptyMessage;
  final String emptyButtonLabel;
  final bool showInfoBanner;
  final String Function(int count)? infoBannerText;
  final bool showBottomActions;
  final String backButtonLabel;
  final String doneButtonLabel;
  final bool showDoneButton;

  const FinalTestReviewConfig({
    required this.title,
    required this.emptyTitle,
    required this.emptyButtonLabel,
    required this.showInfoBanner,
    required this.showBottomActions,
    required this.backButtonLabel,
    required this.doneButtonLabel,
    required this.showDoneButton,
    this.emptyMessage,
    this.infoBannerText,
  });

  factory FinalTestReviewConfig.phase4() {
    return const FinalTestReviewConfig(
      title: 'Review Mistakes',
      emptyTitle: 'No mistakes to review!',
      emptyMessage: null,
      emptyButtonLabel: 'Go Back',
      showInfoBanner: false,
      showBottomActions: false,
      backButtonLabel: 'Back to Results',
      doneButtonLabel: 'Done',
      showDoneButton: false,
    );
  }

  factory FinalTestReviewConfig.phase5() {
    return FinalTestReviewConfig(
      title: 'Review Mistakes',
      emptyTitle: 'Perfect Score!',
      emptyMessage: 'You answered all MCQ questions correctly.',
      emptyButtonLabel: 'Go Back',
      showInfoBanner: true,
      infoBannerText: (count) =>
          '$count incorrect answer${count == 1 ? '' : 's'} to review',
      showBottomActions: true,
      backButtonLabel: 'Back to Results',
      doneButtonLabel: 'Done',
      showDoneButton: true,
    );
  }
}

class FinalTestReviewScreen extends StatelessWidget {
  final List<FinalTestReviewItem> items;
  final FinalTestReviewConfig config;

  const FinalTestReviewScreen({
    super.key,
    required this.items,
    required this.config,
  });

  factory FinalTestReviewScreen.phase4({
    required List<Phase4IncorrectAnswer> incorrectAnswers,
  }) {
    return FinalTestReviewScreen(
      items: incorrectAnswers
          .map(
            (answer) => FinalTestReviewItem(
              question: answer.question.prompt,
              selectedAnswer: answer.selectedAnswer,
              correctAnswer: answer.correctAnswer,
              categoryLabel: _phase4QuestionTypeLabel(answer.question.type),
            ),
          )
          .toList(growable: false),
      config: FinalTestReviewConfig.phase4(),
    );
  }

  factory FinalTestReviewScreen.phase5({
    required List<Phase5IncorrectAnswer> incorrectAnswers,
  }) {
    return FinalTestReviewScreen(
      items: incorrectAnswers
          .map(
            (answer) => FinalTestReviewItem(
              question: answer.question.prompt,
              selectedAnswer: answer.selectedAnswer,
              correctAnswer: answer.correctAnswer,
              categoryLabel: _phase5QuestionTypeLabel(answer.question.type),
            ),
          )
          .toList(growable: false),
      config: FinalTestReviewConfig.phase5(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(config.title), centerTitle: true),
      body: items.isEmpty
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
            Text(
              config.emptyTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (config.emptyMessage != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                config.emptyMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(config.emptyButtonLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakesList(BuildContext context) {
    return Column(
      children: [
        if (config.showInfoBanner) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            color: Colors.orange[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    config.infoBannerText?.call(items.length) ?? '',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildMistakeCard(items[index], index + 1);
            },
          ),
        ),
        if (config.showBottomActions) _buildBottomButtons(context),
      ],
    );
  }

  Widget _buildMistakeCard(FinalTestReviewItem item, int number) {
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
                if (item.categoryLabel != null)
                  Expanded(
                    child: Text(
                      item.categoryLabel!,
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
              item.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildAnswerRow(
              icon: Icons.close,
              iconColor: Colors.red,
              label: 'Your answer:',
              answer: item.selectedAnswer,
              backgroundColor: Colors.red[50]!,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _buildAnswerRow(
              icon: Icons.check,
              iconColor: Colors.green,
              label: 'Correct answer:',
              answer: item.correctAnswer,
              backgroundColor: Colors.green[50]!,
            ),
          ],
        ),
      ),
    );
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(answer, style: const TextStyle(fontSize: 14)),
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
              child: Text(config.backButtonLabel),
            ),
          ),
          if (config.showDoneButton) ...[
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(config.doneButtonLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _phase4QuestionTypeLabel(Phase4QuestionType type) {
  switch (type) {
    case Phase4QuestionType.pronunciation:
      return 'Pronunciation';
    case Phase4QuestionType.dialogue:
      return 'Dialogue';
    case Phase4QuestionType.listening:
      return 'Listening';
    case Phase4QuestionType.speaking:
      return 'Speaking';
  }
}

String _phase5QuestionTypeLabel(Phase5QuestionType type) {
  switch (type) {
    case Phase5QuestionType.businessEnglish:
      return 'Business English';
    case Phase5QuestionType.interview:
      return 'Interview';
    case Phase5QuestionType.presentation:
      return 'Presentation';
    case Phase5QuestionType.writing:
      return 'Writing';
    case Phase5QuestionType.shortAnswer:
      return 'Short Answer';
    case Phase5QuestionType.rewrite:
      return 'Rewrite';
    case Phase5QuestionType.ordering:
      return 'Ordering';
    case Phase5QuestionType.speakingRubricScored:
      return 'Speaking';
    case Phase5QuestionType.writingRubricScored:
      return 'Writing Task';
  }
}
