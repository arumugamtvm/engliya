import '../data/models/user_lesson_status.dart';
import '../data/models/lesson.dart';
import '../data/models/quiz_question.dart';

/// Service for calculating mastery status and lesson unlocking logic
/// Requirements: 11.6 (mastery test scoring), 4.2 (lesson unlocking), 4.3 (unlock persistence)
class MasteryService {
  /// Mastery threshold - learner must score 80% or higher
  static const double masteryThreshold = 0.8;

  /// Check if a lesson is mastered
  /// Requirement 11.6: Lesson is mastered when masteryBestScore >= 80%
  bool isLessonMastered(UserLessonStatus status) {
    return status.isMastered && status.masteryBestScore >= masteryThreshold;
  }

  /// Calculate overall progress across all lessons
  /// Returns a value between 0.0 and 1.0 representing percentage of mastered lessons
  double calculateOverallProgress(List<UserLessonStatus> statuses) {
    if (statuses.isEmpty) return 0.0;

    final masteredCount = statuses.where((status) => status.isMastered).length;
    return masteredCount / statuses.length;
  }

  /// Determine if a lesson should be unlocked based on sequential mastery
  /// Requirement 4.2: Lessons unlock sequentially when previous lesson is mastered
  /// Requirement 4.3: First lesson (order 1) is unlocked by default
  /// 
  /// [lessonOrder] - The order number of the lesson to check (1-based)
  /// [allStatuses] - List of all lesson statuses
  bool shouldUnlockLesson(int lessonOrder, List<UserLessonStatus> allStatuses) {
    // First lesson is always unlocked
    if (lessonOrder == 1) return true;

    // Find the previous lesson (order - 1)
    final previousLessonOrder = lessonOrder - 1;
    
    // Check if previous lesson is mastered
    for (final status in allStatuses) {
      // Extract order from lessonId (format: "phase1_lesson1" -> 1)
      final lessonIdParts = status.lessonId.split('_');
      if (lessonIdParts.length >= 2) {
        final orderStr = lessonIdParts.last.replaceAll('lesson', '');
        final order = int.tryParse(orderStr);
        
        if (order == previousLessonOrder) {
          return status.isMastered;
        }
      }
    }

    // If previous lesson status not found, keep locked
    return false;
  }

  /// Generate a mastery test by combining questions from practice and listening pools
  /// Requirement 11.4: Mastery test includes 8-10 mixed questions
  /// 
  /// [lesson] - The lesson containing question pools
  /// Returns a list of 8-10 questions mixed from practice and listening
  List<QuizQuestion> generateMasteryTest(Lesson lesson) {
    final List<QuizQuestion> masteryQuestions = [];

    // Use mastery questions if available
    if (lesson.masteryQuestions.isNotEmpty) {
      masteryQuestions.addAll(lesson.masteryQuestions);
    } else {
      // Otherwise, mix questions from practice and listening pools
      final practiceQuestions = lesson.practiceQuestions;
      final listeningQuestions = lesson.listeningQuestions;

      // Convert listening questions to quiz questions
      final listeningAsQuiz = listeningQuestions.map((lq) => QuizQuestion(
        type: 'listening',
        promptEn: 'Listen and choose the correct answer',
        promptTa: 'கேட்டு சரியான பதிலைத் தேர்ந்தெடுக்கவும்',
        options: lq.options,
        correctIndex: lq.correctIndex,
      )).toList();

      // Combine and shuffle
      final allQuestions = [...practiceQuestions, ...listeningAsQuiz];
      allQuestions.shuffle();

      // Take 8-10 questions
      final targetCount = allQuestions.length >= 10 ? 10 : (allQuestions.length >= 8 ? 8 : allQuestions.length);
      masteryQuestions.addAll(allQuestions.take(targetCount));
    }

    return masteryQuestions;
  }
}
