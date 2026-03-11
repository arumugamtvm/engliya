import '../domain/entities/tab_validation_result.dart';

class TabProgressSnapshot {
  final int answeredCount;
  final int totalCount;
  final int playedCount;
  final int practicedCount;
  final double accuracy;
  final double averageScore;
  final bool explainScrolledToBottom;

  const TabProgressSnapshot({
    this.answeredCount = 0,
    this.totalCount = 0,
    this.playedCount = 0,
    this.practicedCount = 0,
    this.accuracy = 0,
    this.averageScore = 0,
    this.explainScrolledToBottom = false,
  });
}

class LessonFlowValidationService {
  static const double listeningThreshold = 0.7;
  static const double speakingThreshold = 0.7;
  static const double practiceThreshold = 0.6;
  static const double masteryThreshold = 0.8;

  TabValidationResult validateExplain({
    required bool explainDone,
    required TabProgressSnapshot snapshot,
  }) {
    if (explainDone || snapshot.explainScrolledToBottom) {
      return const TabValidationResult.valid(message: 'Explanation completed.');
    }
    return const TabValidationResult.invalid(
      message: 'Scroll to the bottom of Explain tab to continue.',
      actionLabel: 'Scroll to complete',
    );
  }

  TabValidationResult validateExamples({
    required bool examplesDone,
    required TabProgressSnapshot snapshot,
  }) {
    if (examplesDone || snapshot.playedCount >= 3) {
      return const TabValidationResult.valid(message: 'Examples completed.');
    }
    final remaining = 3 - snapshot.playedCount;
    return TabValidationResult.invalid(
      message: 'Listen to $remaining more example${remaining > 1 ? 's' : ''} to continue.',
      actionLabel: 'Play examples',
    );
  }

  TabValidationResult validateListen({
    required double listeningScore,
    required TabProgressSnapshot snapshot,
  }) {
    final currentAccuracy = snapshot.answeredCount > 0 ? snapshot.accuracy : listeningScore;
    if ((snapshot.answeredCount >= 3 && currentAccuracy >= listeningThreshold) || listeningScore >= listeningThreshold) {
      return const TabValidationResult.valid(message: 'Listening completed.');
    }
    if (snapshot.answeredCount < 3) {
      final remaining = 3 - snapshot.answeredCount;
      return TabValidationResult.invalid(
        message: 'Answer $remaining more listening question${remaining > 1 ? 's' : ''}.',
        actionLabel: 'Answer questions',
      );
    }
    return const TabValidationResult.invalid(
      message: 'Reach at least 70% listening accuracy to continue.',
      actionLabel: 'Improve accuracy',
    );
  }

  TabValidationResult validateSpeak({
    required double speakingScore,
    required TabProgressSnapshot snapshot,
  }) {
    final currentAverage = snapshot.practicedCount > 0 ? snapshot.averageScore : speakingScore;
    if ((snapshot.practicedCount >= 3 && currentAverage >= speakingThreshold) || speakingScore >= speakingThreshold) {
      return const TabValidationResult.valid(message: 'Speaking completed.');
    }
    if (snapshot.practicedCount < 3) {
      final remaining = 3 - snapshot.practicedCount;
      return TabValidationResult.invalid(
        message: 'Practice $remaining more speaking sentence${remaining > 1 ? 's' : ''}.',
        actionLabel: 'Practice speaking',
      );
    }
    return const TabValidationResult.invalid(
      message: 'Reach at least 70% speaking average to continue.',
      actionLabel: 'Improve speaking score',
    );
  }

  TabValidationResult validatePractice({
    required double quizBestScore,
    required TabProgressSnapshot snapshot,
  }) {
    if ((snapshot.totalCount > 0 && snapshot.answeredCount >= snapshot.totalCount && snapshot.accuracy >= practiceThreshold) ||
        quizBestScore >= practiceThreshold) {
      return const TabValidationResult.valid(message: 'Practice completed.');
    }
    if (snapshot.totalCount > 0 && snapshot.answeredCount < snapshot.totalCount) {
      final remaining = snapshot.totalCount - snapshot.answeredCount;
      return TabValidationResult.invalid(
        message: 'Answer $remaining more practice question${remaining > 1 ? 's' : ''}.',
        actionLabel: 'Answer all questions',
      );
    }
    return const TabValidationResult.invalid(
      message: 'Reach at least 60% in Practice to continue.',
      actionLabel: 'Retake practice',
    );
  }

  TabValidationResult validateMastery({
    required bool isMastered,
    required double masteryBestScore,
    required TabProgressSnapshot snapshot,
  }) {
    if ((snapshot.totalCount > 0 && snapshot.answeredCount >= snapshot.totalCount && snapshot.accuracy >= masteryThreshold) ||
        isMastered ||
        masteryBestScore >= masteryThreshold) {
      return const TabValidationResult.valid(message: 'Mastery completed.');
    }
    if (snapshot.totalCount > 0 && snapshot.answeredCount < snapshot.totalCount) {
      final remaining = snapshot.totalCount - snapshot.answeredCount;
      return TabValidationResult.invalid(
        message: 'Answer $remaining more mastery question${remaining > 1 ? 's' : ''}.',
        actionLabel: 'Complete mastery test',
      );
    }
    return const TabValidationResult.invalid(
      message: 'Score at least 80% in Mastery to finish this lesson.',
      actionLabel: 'Try again',
    );
  }
}
