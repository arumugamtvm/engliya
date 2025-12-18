import 'package:flutter/material.dart';
import '../../data/models/incorrect_answer.dart';
import '../../../../app/theme.dart';

/// Phase 1 Final Test Review Screen
/// Displays incorrect answers with correct solutions for review
/// Requirements: 5.1-5.8, 8.1-8.2, 8.6
class Phase1FinalTestReviewScreen extends StatelessWidget {
  final List<IncorrectAnswer> incorrectAnswers;

  const Phase1FinalTestReviewScreen({
    super.key,
    required this.incorrectAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Build AppBar with back button and title
  /// Requirement: 5.1, 8.8
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Semantics(
        button: true,
        label: 'Back to results',
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      title: const Text(
        'Review Mistakes',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build main body content
  Widget _buildBody(BuildContext context) {
    // Handle empty state (perfect score scenario)
    // Requirement: 5.2
    if (incorrectAnswers.isEmpty) {
      return _buildEmptyState();
    }

    return SafeArea(
      child: Column(
        children: [
          // Header with mistake count
          _buildHeader(),
          
          // List of incorrect answers
          Expanded(
            child: _buildIncorrectAnswersList(),
          ),
          
          // Back to Results button
          _buildBackButton(context),
        ],
      ),
    );
  }

  /// Build empty state for perfect score
  /// Requirement: 5.2, 8.8
  Widget _buildEmptyState() {
    return Semantics(
      label: 'Perfect Score! No mistakes to review',
      readOnly: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: AppTheme.correctColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              const ExcludeSemantics(
                child: Text(
                  'Perfect Score!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const ExcludeSemantics(
                child: Text(
                  'No mistakes to review',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section with mistake count
  /// Requirement: 8.8
  Widget _buildHeader() {
    final mistakeCount = incorrectAnswers.length;
    final headerText = 'You got $mistakeCount question${mistakeCount == 1 ? '' : 's'} wrong. Review them below:';
    
    return Semantics(
      label: headerText,
      readOnly: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE), // Light red background
          border: Border(
            bottom: BorderSide(
              color: AppTheme.incorrectColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.info_outline,
                color: AppTheme.incorrectColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  headerText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build ListView for incorrect answers
  /// Requirement: 5.1, 5.8
  Widget _buildIncorrectAnswersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: incorrectAnswers.length,
      itemBuilder: (context, index) {
        return _buildIncorrectAnswerCard(incorrectAnswers[index], index);
      },
    );
  }

  /// Build card for a single incorrect answer
  /// Requirements: 5.3, 5.4, 5.5, 5.6, 5.7, 8.1, 8.2, 8.6, 8.8
  Widget _buildIncorrectAnswerCard(IncorrectAnswer incorrectAnswer, int index) {
    final question = incorrectAnswer.question;
    final questionNum = index + 1;
    
    final semanticLabel = 'Mistake $questionNum. Question: ${question.promptEn}. Your answer: ${incorrectAnswer.selectedAnswer}. Correct answer: ${incorrectAnswer.correctAnswer}';
    
    return Semantics(
      label: semanticLabel,
      readOnly: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question number and lesson information
              // Requirement: 5.7
              _buildQuestionHeader(questionNum, question.lessonTitle),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Question text
              // Requirement: 5.3, 8.6
              _buildQuestionText(question.promptEn),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // User's selected answer (incorrect)
              // Requirement: 5.5, 5.6
              _buildAnswerOption(
                label: 'Your Answer',
                answer: incorrectAnswer.selectedAnswer,
                isCorrect: false,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Correct answer
              // Requirement: 5.4, 5.6
              _buildAnswerOption(
                label: 'Correct Answer',
                answer: incorrectAnswer.correctAnswer,
                isCorrect: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build question header with number and lesson info
  /// Requirement: 5.7, 8.8
  Widget _buildQuestionHeader(int questionNumber, String lessonTitle) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              size: 18,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              'Question $questionNumber',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              '•',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            Flexible(
              child: Text(
                lessonTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build question text
  /// Requirement: 5.3, 8.6, 8.8
  Widget _buildQuestionText(String questionText) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // Light gray background
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Text(
          questionText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// Build answer option with color coding
  /// Requirements: 5.4, 5.5, 5.6, 8.1, 8.2, 8.8
  Widget _buildAnswerOption({
    required String label,
    required String answer,
    required bool isCorrect,
  }) {
    final backgroundColor = isCorrect
        ? const Color(0xFFE8F5E9) // Light green (#E8F5E9)
        : const Color(0xFFFFEBEE); // Light red (#FFEBEE)
    
    final textColor = isCorrect
        ? const Color(0xFF2E7D32) // Green (#2E7D32)
        : const Color(0xFFC62828); // Red (#C62828)
    
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;

    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: textColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    answer,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Back to Results button
  /// Requirement: 5.7, 8.8
  Widget _buildBackButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: 'Back to results',
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                'Back to Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
