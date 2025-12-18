/// Phase 4 Unit model representing a collection of related lessons
/// covering fluency and pronunciation skills at B2 level
class Phase4Unit {
  final String id;
  final int order;
  final String title;
  final String description;
  final int lessonCount;
  int masteredCount;

  Phase4Unit({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.lessonCount,
    this.masteredCount = 0,
  });

  /// Calculate progress ratio (mastered/total) for this unit
  double get progress {
    if (lessonCount == 0) return 0.0;
    return masteredCount / lessonCount;
  }

  /// Calculate progress percentage for this unit
  double get progressPercentage {
    if (lessonCount == 0) return 0.0;
    return masteredCount / lessonCount;
  }

  /// Check if all lessons in this unit are mastered
  bool get isCompleted => masteredCount == lessonCount;

  /// Get progress display string (e.g., "2/5 mastered")
  String get progressDisplay => '$masteredCount/$lessonCount mastered';
}
