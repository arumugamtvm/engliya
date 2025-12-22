import 'package:flutter/foundation.dart';

/// Immutable domain entity representing a learning unit
/// A unit is a collection of related lessons within a phase
@immutable
class Unit {
  final String id;
  final int order;
  final String title;
  final String description;
  final int lessonCount;
  final int masteredCount;

  const Unit({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.lessonCount,
    this.masteredCount = 0,
  });

  /// Calculate progress percentage for this unit (0.0 to 1.0)
  double get progressPercentage {
    if (lessonCount == 0) return 0.0;
    return masteredCount / lessonCount;
  }

  /// Calculate progress percentage as a value from 0 to 100
  double get progressPercent => progressPercentage * 100;

  /// Check if all lessons in this unit are mastered
  bool get isCompleted => lessonCount > 0 && masteredCount >= lessonCount;

  /// Check if the unit has been started (at least one lesson mastered)
  bool get isStarted => masteredCount > 0;

  /// Get the number of remaining lessons to master
  int get remainingLessons => lessonCount - masteredCount;

  /// Get progress display string (e.g., "2 / 5 lessons mastered")
  String get progressDisplay => '$masteredCount / $lessonCount lessons mastered';

  /// Get a short progress string (e.g., "2/5")
  String get progressShort => '$masteredCount/$lessonCount';

  /// Check if this unit has valid data
  bool get isValid =>
      id.isNotEmpty &&
      title.isNotEmpty &&
      lessonCount >= 0 &&
      masteredCount >= 0 &&
      masteredCount <= lessonCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          order == other.order &&
          title == other.title &&
          description == other.description &&
          lessonCount == other.lessonCount &&
          masteredCount == other.masteredCount;

  @override
  int get hashCode =>
      id.hashCode ^
      order.hashCode ^
      title.hashCode ^
      description.hashCode ^
      lessonCount.hashCode ^
      masteredCount.hashCode;

  @override
  String toString() =>
      'Unit(id: $id, title: $title, progress: $progressShort)';

  /// Create a copy with modified fields
  Unit copyWith({
    String? id,
    int? order,
    String? title,
    String? description,
    int? lessonCount,
    int? masteredCount,
  }) {
    return Unit(
      id: id ?? this.id,
      order: order ?? this.order,
      title: title ?? this.title,
      description: description ?? this.description,
      lessonCount: lessonCount ?? this.lessonCount,
      masteredCount: masteredCount ?? this.masteredCount,
    );
  }

  /// Create a unit with updated mastered count
  Unit withMasteredCount(int newMasteredCount) {
    return copyWith(masteredCount: newMasteredCount);
  }

  /// Create a unit with one more lesson mastered
  Unit incrementMastered() {
    if (masteredCount >= lessonCount) return this;
    return copyWith(masteredCount: masteredCount + 1);
  }
}
