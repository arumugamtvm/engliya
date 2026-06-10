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

  /// Matches lesson IDs of the form `phaseN_lessonM` (group 1 = M) and
  /// `phaseN_lessonM_K` (group 2 = K, the sub-lesson order within the unit).
  static final RegExp _lessonIdPattern = RegExp(
    r'^phase\d+_lesson(\d+)(?:_(\d+))?$',
  );

  /// Extract the 1-based order of a lesson from its id.
  ///
  /// - `phase1_lesson3` -> 3 (lesson number is the order)
  /// - `phase2_lesson7_2` -> 2 (sub-lesson number is the order within the unit)
  ///
  /// Returns null if the id does not match either format.
  static int? lessonOrderFromId(String lessonId) {
    final match = _lessonIdPattern.firstMatch(lessonId);
    if (match == null) return null;

    final subLesson = match.group(2);
    if (subLesson != null) {
      // 'phaseN_lessonM_K' format: K is the order within the unit.
      return int.tryParse(subLesson);
    }
    // 'phaseN_lessonM' format (e.g. phase 1): M is the order.
    return int.tryParse(match.group(1)!);
  }

  /// Determine if a lesson should be unlocked based on sequential mastery
  /// Requirement 4.2: Lessons unlock sequentially when previous lesson is mastered
  /// Requirement 4.3: First lesson (order 1) is unlocked by default
  ///
  /// [lessonOrder] - The order number of the lesson to check (1-based)
  /// [allStatuses] - List of all lesson statuses
  /// [previousLessonId] - When provided, the previous lesson is located by
  /// exact id match instead of by parsing lesson ids. Prefer passing this when
  /// the caller knows the expected previous lesson id.
  bool shouldUnlockLesson(
    int lessonOrder,
    List<UserLessonStatus> allStatuses, {
    String? previousLessonId,
  }) {
    // First lesson is always unlocked
    if (lessonOrder == 1) return true;

    // Preferred path: match the previous lesson by its exact id.
    if (previousLessonId != null) {
      for (final status in allStatuses) {
        if (status.lessonId == previousLessonId) {
          return status.isMastered;
        }
      }
      // Previous lesson status not found, keep locked.
      return false;
    }

    // Fallback path: find the previous lesson (order - 1) by parsing ids.
    final previousLessonOrder = lessonOrder - 1;

    for (final status in allStatuses) {
      final order = lessonOrderFromId(status.lessonId);
      if (order == previousLessonOrder) {
        return status.isMastered;
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
