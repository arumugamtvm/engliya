import 'package:flutter/material.dart';
import '../../data/models/incorrect_answer.dart';
import '../../data/models/phase3_final_test_question.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/animations.dart';

/// Phase 3 Final Test Review Screen
/// Displays incorrect answers with correct solutions for review
/// Requirements: 6.1-6.8, 13.1, 13.2, 13.6
/// Accessibility: Semantic labels, screen reader announcements, WCAG compliant colors - Requirement: 13.8
class Phase3FinalTestReviewScreen extends StatelessWidget {
  final List<IncorrectAnswer> incorrectAnswers;

  const Phase3FinalTestReviewScreen({
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
  /// Requirement: 6.7
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
  /// Requirement: 6.1, 6.2
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
  /// Requirement: 6.2
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
  /// Requirement: 6.1, 6.8
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
  /// Requirement: 6.3, 6.4, 6.5, 6.6
  Widget _buildIncorrectAnswerCard(IncorrectAnswer incorrectAnswer, int questionNumber) {
    final question = incorrectAnswer.question as Phase3FinalTestQuestion;
    
    final semanticLabel = 'Question $questionNumber. ${question.promptEn}. '
        'Your answer: ${incorrectAnswer.selectedAnswer}. '
        'Correct answer: ${incorrectAnswer.correctAnswer}. '
        'From ${_getUnitDisplayName(question.unitId)}, ${question.lessonTitle}';

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
              
              // Your answer (incorrect) - red highlighting
              _buildYourAnswer(incorrectAnswer),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Correct answer - green highlighting
              _buildCorrectAnswer(incorrectAnswer),
            ],
          ),
        ),
      ),
    );
  }

  /// Build question header with number and unit/lesson badge
  Widget _buildQuestionHeader(Phase3FinalTestQuestion question, int questionNumber) {
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
  Widget _buildUnitBadge(String unitId) {
    final unitColor = _getUnitColor(unitId);
    final unitName = _getUnitDisplayName(unitId);
    
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
  /// Requirement: 6.3, 13.6
  Widget _buildQuestionText(Phase3FinalTestQuestion question) {
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
  /// Requirement: 6.5, 6.6 - #FFEBEE background, #B71C1C text (darker for WCAG 4.5:1 contrast)
  /// Accessibility: Uses darker text color for better contrast - Requirement: 13.8
  Widget _buildYourAnswer(IncorrectAnswer incorrectAnswer) {
    // Using darker red (#B71C1C) for WCAG 4.5:1 contrast ratio on light red background
    const textColor = Color(0xFFB71C1C);
    
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE), // Light red background
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: textColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // X icon - provides non-color indicator
            const Icon(
              Icons.close,
              color: textColor,
              size: 24,
              semanticLabel: 'Incorrect',
            ),
            const SizedBox(width: AppTheme.spacingM),
            
            // Answer content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Answer (Incorrect)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    incorrectAnswer.selectedAnswer,
                    style: const TextStyle(
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

  /// Build correct answer section (green highlighting)
  /// Requirement: 6.4, 6.6 - #E8F5E9 background, #1B5E20 text (darker for WCAG 4.5:1 contrast)
  /// Accessibility: Uses darker text color for better contrast - Requirement: 13.8
  Widget _buildCorrectAnswer(IncorrectAnswer incorrectAnswer) {
    // Using darker green (#1B5E20) for WCAG 4.5:1 contrast ratio on light green background
    const textColor = Color(0xFF1B5E20);
    
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // Light green background
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: textColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check icon - provides non-color indicator
            const Icon(
              Icons.check,
              color: textColor,
              size: 24,
              semanticLabel: 'Correct',
            ),
            const SizedBox(width: AppTheme.spacingM),
            
            // Answer content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Correct Answer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    incorrectAnswer.correctAnswer,
                    style: const TextStyle(
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

  /// Build back to results button
  /// Requirement: 6.7
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
  Color _getUnitColor(String unitId) {
    switch (unitId) {
      case 'unit12':
        return const Color(0xFF2196F3); // Blue - Stories & Retelling
      case 'unit13':
        return const Color(0xFF9C27B0); // Purple - Connectors
      case 'unit14':
        return const Color(0xFFFF9800); // Orange - Passive Voice
      case 'unit15':
        return const Color(0xFF009688); // Teal - Reported Speech
      case 'unit16':
        return const Color(0xFFE91E63); // Pink - Functional English
      case 'unit17':
        return const Color(0xFF4CAF50); // Green - Projects
      default:
        return AppTheme.primaryColor;
    }
  }

  /// Get unit display name
  String _getUnitDisplayName(String unitId) {
    switch (unitId) {
      case 'unit12':
        return 'Unit 12';
      case 'unit13':
        return 'Unit 13';
      case 'unit14':
        return 'Unit 14';
      case 'unit15':
        return 'Unit 15';
      case 'unit16':
        return 'Unit 16';
      case 'unit17':
        return 'Unit 17';
      default:
        return unitId;
    }
  }
}
