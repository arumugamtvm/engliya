/// Phase 3 Unit model representing a collection of related lessons
/// covering real-life communication skills at B1 level
class Phase3Unit {
  final String id;
  final int order;
  final String title;
  final String description;
  final int lessonCount;
  int masteredCount;

  Phase3Unit({
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
