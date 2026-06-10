import 'package:flutter/material.dart';

import '../../domain/entities/test_question.dart';
import '../../domain/entities/test_result.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/animations.dart';

class ReviewHeaderConfig {
  final String Function(int count) textBuilder;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;

  const ReviewHeaderConfig({
    required this.textBuilder,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
  });
}

class ReviewEmptyStateConfig {
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final Color iconColor;
  final bool animated;
  final bool usePulse;
  final bool showBackButton;

  const ReviewEmptyStateConfig({
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
    required this.iconColor,
    this.animated = false,
    this.usePulse = false,
    this.showBackButton = false,
  });
}

enum ReviewCardStyle {
  simple,
  detailed,
}

class ReviewUnitBadge {
  final String label;
  final Color color;

  const ReviewUnitBadge({
    required this.label,
    required this.color,
  });
}

class McqFinalTestReviewConfig {
  final ReviewHeaderConfig header;
  final ReviewEmptyStateConfig emptyState;
  final ReviewCardStyle cardStyle;
  final bool animateListItems;
  final Map<String, ReviewUnitBadge> unitBadges;

  const McqFinalTestReviewConfig({
    required this.header,
    required this.emptyState,
    required this.cardStyle,
    required this.animateListItems,
    this.unitBadges = const {},
  });

  static McqFinalTestReviewConfig phase1() {
    return McqFinalTestReviewConfig(
      header: ReviewHeaderConfig(
        textBuilder: AppStrings.questionsWrongReview,
        backgroundColor: const Color(0xFFFFEBEE),
        borderColor: AppTheme.incorrectColor.withValues(alpha: 0.3),
        textColor: AppTheme.textPrimary,
        icon: Icons.info_outline,
        iconColor: AppTheme.incorrectColor,
      ),
      emptyState: ReviewEmptyStateConfig(
        title: AppStrings.perfectScore,
        subtitle: AppStrings.noMistakes,
        semanticsLabel: 'Perfect Score! No mistakes to review',
        iconColor: AppTheme.correctColor,
        animated: false,
        usePulse: false,
        showBackButton: false,
      ),
      cardStyle: ReviewCardStyle.simple,
      animateListItems: false,
    );
  }

  static McqFinalTestReviewConfig phase2() {
    return McqFinalTestReviewConfig(
      header: ReviewHeaderConfig(
        textBuilder: AppStrings.youMadeMistakes,
        backgroundColor: AppTheme.incorrectColor.withValues(alpha: 0.1),
        borderColor: AppTheme.incorrectColor.withValues(alpha: 0.3),
        textColor: AppTheme.incorrectColor,
        icon: Icons.info_outline,
        iconColor: AppTheme.incorrectColor,
      ),
      emptyState: ReviewEmptyStateConfig(
        title: AppStrings.perfectScore,
        subtitle: AppStrings.noMistakes,
        semanticsLabel: 'Perfect Score! No mistakes to review',
        iconColor: AppTheme.correctColor,
        animated: true,
        usePulse: true,
        showBackButton: true,
      ),
      cardStyle: ReviewCardStyle.detailed,
      animateListItems: true,
      unitBadges: const {
        'unit7': ReviewUnitBadge(label: 'Unit 7', color: Color(0xFF2196F3)),
        'unit8': ReviewUnitBadge(label: 'Unit 8', color: Color(0xFF9C27B0)),
        'unit9': ReviewUnitBadge(label: 'Unit 9', color: Color(0xFFFF9800)),
        'unit10': ReviewUnitBadge(label: 'Unit 10', color: Color(0xFF009688)),
        'unit11': ReviewUnitBadge(label: 'Unit 11', color: Color(0xFFE91E63)),
      },
    );
  }

  static McqFinalTestReviewConfig phase3() {
    return McqFinalTestReviewConfig(
      header: ReviewHeaderConfig(
        textBuilder: AppStrings.youMadeMistakes,
        backgroundColor: AppTheme.incorrectColor.withValues(alpha: 0.1),
        borderColor: AppTheme.incorrectColor.withValues(alpha: 0.3),
        textColor: AppTheme.incorrectColor,
        icon: Icons.info_outline,
        iconColor: AppTheme.incorrectColor,
      ),
      emptyState: ReviewEmptyStateConfig(
        title: AppStrings.perfectScore,
        subtitle: AppStrings.noMistakes,
        semanticsLabel: 'Perfect Score! No mistakes to review',
        iconColor: AppTheme.correctColor,
        animated: true,
        usePulse: true,
        showBackButton: true,
      ),
      cardStyle: ReviewCardStyle.detailed,
      animateListItems: true,
      unitBadges: const {
        'unit12': ReviewUnitBadge(label: 'Unit 12', color: Color(0xFF2196F3)),
        'unit13': ReviewUnitBadge(label: 'Unit 13', color: Color(0xFF9C27B0)),
        'unit14': ReviewUnitBadge(label: 'Unit 14', color: Color(0xFFFF9800)),
        'unit15': ReviewUnitBadge(label: 'Unit 15', color: Color(0xFF009688)),
        'unit16': ReviewUnitBadge(label: 'Unit 16', color: Color(0xFFE91E63)),
        'unit17': ReviewUnitBadge(label: 'Unit 17', color: Color(0xFF4CAF50)),
      },
    );
  }
}

class McqFinalTestReviewScreen extends StatelessWidget {
  final List<IncorrectAnswer> incorrectAnswers;
  final McqFinalTestReviewConfig config;

  const McqFinalTestReviewScreen({
    super.key,
    required this.incorrectAnswers,
    required this.config,
  });

  factory McqFinalTestReviewScreen.phase1({
    Key? key,
    required List<IncorrectAnswer> incorrectAnswers,
  }) {
    return McqFinalTestReviewScreen(
      key: key,
      incorrectAnswers: incorrectAnswers,
      config: McqFinalTestReviewConfig.phase1(),
    );
  }

  factory McqFinalTestReviewScreen.phase2({
    Key? key,
    required List<IncorrectAnswer> incorrectAnswers,
  }) {
    return McqFinalTestReviewScreen(
      key: key,
      incorrectAnswers: incorrectAnswers,
      config: McqFinalTestReviewConfig.phase2(),
    );
  }

  factory McqFinalTestReviewScreen.phase3({
    Key? key,
    required List<IncorrectAnswer> incorrectAnswers,
  }) {
    return McqFinalTestReviewScreen(
      key: key,
      incorrectAnswers: incorrectAnswers,
      config: McqFinalTestReviewConfig.phase3(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

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
        AppStrings.review,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (incorrectAnswers.isEmpty) {
      return _buildEmptyState(context);
    }

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildIncorrectAnswersList(),
          ),
          _buildBackButton(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final empty = config.emptyState;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (empty.usePulse)
          PulseAnimation(
            child: Icon(
              Icons.emoji_events,
              size: 100,
              color: empty.iconColor,
            ),
          )
        else
          Icon(
            Icons.emoji_events,
            size: 100,
            color: empty.iconColor,
          ),
        const SizedBox(height: AppTheme.spacingL),
        Text(
          empty.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: empty.iconColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          empty.subtitle,
          style: const TextStyle(
            fontSize: 18,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (empty.showBackButton) ...[
          const SizedBox(height: AppTheme.spacingXL),
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
              AppStrings.backToResults,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );

    final child = Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: empty.animated
          ? TweenAnimationBuilder<double>(
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
              child: content,
            )
          : content,
    );

    return Semantics(
      label: empty.semanticsLabel,
      readOnly: true,
      child: Center(child: child),
    );
  }

  Widget _buildHeader() {
    final header = config.header;
    final mistakeCount = incorrectAnswers.length;
    final headerText = header.textBuilder(mistakeCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: header.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: header.borderColor,
            width: 2,
          ),
        ),
      ),
      child: Semantics(
        label: headerText,
        readOnly: true,
        child: Row(
          children: [
            Icon(
              header.icon,
              color: header.iconColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                headerText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: header.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncorrectAnswersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: incorrectAnswers.length,
      itemBuilder: (context, index) {
        final card = _buildIncorrectAnswerCard(
          incorrectAnswers[index],
          index + 1,
        );
        if (!config.animateListItems) {
          return card;
        }
        return AnimatedListItem(
          index: index,
          delay: const Duration(milliseconds: 80),
          child: card,
        );
      },
    );
  }

  Widget _buildIncorrectAnswerCard(IncorrectAnswer incorrectAnswer, int questionNumber) {
    if (config.cardStyle == ReviewCardStyle.simple) {
      return _buildSimpleCard(incorrectAnswer, questionNumber);
    }
    return _buildDetailedCard(incorrectAnswer, questionNumber);
  }

  Widget _buildSimpleCard(IncorrectAnswer incorrectAnswer, int questionNumber) {
    final question = incorrectAnswer.question;
    final semanticLabel =
        'Mistake $questionNumber. Question: ${question.promptEn}. Your answer: ${incorrectAnswer.selectedAnswer}. Correct answer: ${incorrectAnswer.correctAnswer}';

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
              _buildSimpleHeader(questionNumber, question.lessonTitle),
              const SizedBox(height: AppTheme.spacingM),
              _buildQuestionTextSimple(question.promptEn),
              const SizedBox(height: AppTheme.spacingL),
              _buildAnswerOption(
                label: AppStrings.yourAnswer,
                answer: incorrectAnswer.selectedAnswer,
                isCorrect: false,
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildAnswerOption(
                label: AppStrings.correctAnswer,
                answer: incorrectAnswer.correctAnswer,
                isCorrect: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedCard(IncorrectAnswer incorrectAnswer, int questionNumber) {
    final question = incorrectAnswer.question;
    final unitBadge = _resolveUnitBadge(question.unitId);
    final semanticLabel =
        'Question $questionNumber. ${question.promptEn}. Your answer: ${incorrectAnswer.selectedAnswer}. Correct answer: ${incorrectAnswer.correctAnswer}. From ${unitBadge.label}, ${question.lessonTitle}';

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
              _buildDetailedHeader(question, questionNumber, unitBadge),
              const SizedBox(height: AppTheme.spacingM),
              _buildQuestionTextDetailed(question),
              const SizedBox(height: AppTheme.spacingL),
              _buildYourAnswer(incorrectAnswer),
              const SizedBox(height: AppTheme.spacingM),
              _buildCorrectAnswer(incorrectAnswer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHeader(int questionNumber, String lessonTitle) {
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
              AppStrings.questionNumberLabel(questionNumber),
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

  Widget _buildQuestionTextSimple(String questionText) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
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

  Widget _buildAnswerOption({
    required String label,
    required String answer,
    required bool isCorrect,
  }) {
    final color = isCorrect ? AppTheme.correctColor : AppTheme.incorrectColor;
    final background = isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;

    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
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
                      color: color,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    answer,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
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

  Widget _buildDetailedHeader(
    TestQuestion question,
    int questionNumber,
    ReviewUnitBadge unitBadge,
  ) {
    return ExcludeSemantics(
      child: Row(
        children: [
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
          _buildUnitBadge(unitBadge),
          const SizedBox(width: AppTheme.spacingS),
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

  Widget _buildUnitBadge(ReviewUnitBadge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: badge.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        badge.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badge.color,
        ),
      ),
    );
  }

  ReviewUnitBadge _resolveUnitBadge(String? unitId) {
    if (unitId != null && config.unitBadges.containsKey(unitId)) {
      return config.unitBadges[unitId]!;
    }
    return ReviewUnitBadge(
      label: unitId ?? 'Unit',
      color: AppTheme.primaryColor,
    );
  }

  Widget _buildQuestionTextDetailed(TestQuestion question) {
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

  Widget _buildYourAnswer(IncorrectAnswer incorrectAnswer) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.incorrectColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.close,
              color: AppTheme.incorrectColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.yourAnswer,
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

  Widget _buildCorrectAnswer(IncorrectAnswer incorrectAnswer) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.correctColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check,
              color: AppTheme.correctColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.correctAnswer,
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
              AppStrings.backToResults,
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
}
