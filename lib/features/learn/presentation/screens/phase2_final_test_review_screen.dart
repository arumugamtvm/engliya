import 'package:flutter/material.dart';
import '../../data/models/incorrect_answer.dart';
import '../../data/models/phase2_final_test_question.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/animations.dart';

/// Phase 2 Final Test Review Screen
/// Displays incorrect answers with correct solutions for review
/// Requirements: 5.1-5.9, 8.1, 8.2, 8.6
class Phase2FinalTestReviewScreen extends StatelessWidget {
  final List<IncorrectAnswer> incorrectAnswers;

  const Phase2FinalTestReviewScreen({
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
  /// Requirement: 5.1
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Semantics(
        button: true,
        label: 'Back to results',
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Results',
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
  /// Requirement: 5.1, 5.2
  Widget _buildBody(BuildContext context) {
    // Handle empty state (perfect score scenario)
    if (incorrectAnswers.isEmpty) {
      return _buildEmptyState(context);
    }

    return SafeArea(
      child: Column(
        children: [
          // Header section with mistake count
          _buildHeader(),
          
          // List of incorrect answers
          Expanded(
            child: _buildIncorrectAnswersList(),
          ),
          
          // Back to Results button at bottom
          _buildBackButton(context),
        ],
      ),
    );
  }

  /// Build empty state for perfect score with animation
  /// Requirement: 5.2
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon with pulse animation
              PulseAnimation(
                child: Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: AppTheme.correctColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Perfect score message
              Text(
                'Perfect Score!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.correctColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'No mistakes to review',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Back button
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.correctColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingM,
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section with mistake count
  Widget _buildHeader() {
    final mistakeCount = incorrectAnswers.length;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.incorrectColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.incorrectColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Semantics(
        label: 'You made $mistakeCount mistake${mistakeCount == 1 ? '' : 's'}',
        readOnly: true,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.incorrectColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                'You made $mistakeCount mistake${mistakeCount == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.incorrectColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build list of incorrect answers with staggered animation
  /// Requirement: 5.3, 5.9
  Widget _buildIncorrectAnswersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: incorrectAnswers.length,
      itemBuilder: (context, index) {
        // Add staggered fade-in animation for each item
        return AnimatedListItem(
          index: index,
          delay: const Duration(milliseconds: 80),
          child: _buildIncorrectAnswerCard(
            incorrectAnswers[index],
            index + 1,
          ),
        );
      },
    );
  }

  /// Build individual incorrect answer card
  /// Requirement: 5.3, 5.4, 5.5, 5.6, 5.7, 5.8
  Widget _buildIncorrectAnswerCard(IncorrectAnswer incorrectAnswer, int questionNumber) {
    final question = incorrectAnswer.question as Phase2FinalTestQuestion;
    
    final semanticLabel = 'Question $questionNumber. ${question.promptEn}. '
        'Your answer: ${incorrectAnswer.selectedAnswer}. '
        'Correct answer: ${incorrectAnswer.correctAnswer}. '
        'From ${_getUnitName(question.unitId)}, ${question.lessonTitle}';

    return Semantics(
      label: semanticLabel,
      readOnly: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question number and unit/lesson badge
              _buildQuestionHeader(question, questionNumber),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Question text
              _buildQuestionText(question),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Your answer (incorrect)
              _buildYourAnswer(incorrectAnswer),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Correct answer
              _buildCorrectAnswer(incorrectAnswer),
            ],
          ),
        ),
      ),
    );
  }

  /// Build question header with number and unit/lesson badge
  /// Requirement: 5.7, 5.8
  Widget _buildQuestionHeader(Phase2FinalTestQuestion question, int questionNumber) {
    return ExcludeSemantics(
      child: Row(
        children: [
          // Question number badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Text(
              'Q$questionNumber',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: AppTheme.spacingM),
          
          // Unit badge
          _buildUnitBadge(question.unitId),
          
          const SizedBox(width: AppTheme.spacingS),
          
          // Lesson title
          Expanded(
            child: Text(
              question.lessonTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build unit badge with color coding
  /// Requirement: 5.7
  Widget _buildUnitBadge(String unitId) {
    final unitColor = _getUnitColor(unitId);
    final unitName = _getUnitName(unitId);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: unitColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: unitColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        unitName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: unitColor,
        ),
      ),
    );
  }

  /// Build question text
  /// Requirement: 5.3, 8.6
  Widget _buildQuestionText(Phase2FinalTestQuestion question) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.scaffoldBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Text(
          question.promptEn,
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

  /// Build your answer section (incorrect, red highlighting)
  /// Requirement: 5.5, 5.6
  Widget _buildYourAnswer(IncorrectAnswer incorrectAnswer) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE), // Light red background
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.incorrectColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // X icon
            Icon(
              Icons.close,
              color: AppTheme.incorrectColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingM),
            
            // Answer content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Answer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.incorrectColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    incorrectAnswer.selectedAnswer,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.incorrectColor,
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

  /// Build correct answer section (green highlighting)
  /// Requirement: 5.4, 5.6
  Widget _buildCorrectAnswer(IncorrectAnswer incorrectAnswer) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // Light green background
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.correctColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check icon
            Icon(
              Icons.check,
              color: AppTheme.correctColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingM),
            
            // Answer content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correct Answer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.correctColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    incorrectAnswer.correctAnswer,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.correctColor,
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

  /// Build back to results button
  /// Requirement: 5.8
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
              minimumSize: const Size(double.infinity, 48),
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
    );
  }

  /// Get unit color based on unit ID
  /// Requirement: 5.7, 8.1, 8.2
  Color _getUnitColor(String unitId) {
    switch (unitId) {
      case 'unit7':
        return const Color(0xFF2196F3); // Blue
      case 'unit8':
        return const Color(0xFF9C27B0); // Purple
      case 'unit9':
        return const Color(0xFFFF9800); // Orange
      case 'unit10':
        return const Color(0xFF009688); // Teal
      case 'unit11':
        return const Color(0xFFE91E63); // Pink
      default:
        return AppTheme.primaryColor;
    }
  }

  /// Get unit display name
  /// Requirement: 5.7
  String _getUnitName(String unitId) {
    switch (unitId) {
      case 'unit7':
        return 'Unit 7';
      case 'unit8':
        return 'Unit 8';
      case 'unit9':
        return 'Unit 9';
      case 'unit10':
        return 'Unit 10';
      case 'unit11':
        return 'Unit 11';
      default:
        return unitId;
    }
  }
}
