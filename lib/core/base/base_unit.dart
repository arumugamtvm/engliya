import 'package:flutter/foundation.dart';

enum UnitStatus {
  locked,
  unlocked,
  inProgress,
  completed,
  mastered;

  bool get isAccessible => this != locked;
  bool get isCompleted => this == completed || this == mastered;
}

@immutable
class BaseUnit {
  final String id;
  final String title;
  final String? description;
  final int lessonCount;
  final int completedLessons;
  final int masteredLessons;
  final UnitStatus status;
  final int order;

  const BaseUnit({
    required this.id,
    required this.title,
    this.description,
    required this.lessonCount,
    this.completedLessons = 0,
    this.masteredLessons = 0,
    this.status = UnitStatus.locked,
    this.order = 0,
  });

  double get progress {
    if (lessonCount == 0) return 0.0;
    return completedLessons / lessonCount;
  }

  double get progressPercentage => progress * 100;

  double get masteryProgress {
    if (lessonCount == 0) return 0.0;
    return masteredLessons / lessonCount;
  }

  bool get isComplete => completedLessons >= lessonCount;
  bool get isMastered => masteredLessons >= lessonCount;

  factory BaseUnit.fromJson(Map<String, dynamic> json) {
    return BaseUnit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      lessonCount: json['lessonCount'] as int? ?? 0,
      completedLessons: json['completedLessons'] as int? ?? 0,
      masteredLessons: json['masteredLessons'] as int? ?? 0,
      status: UnitStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'locked'),
        orElse: () => UnitStatus.locked,
      ),
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    'lessonCount': lessonCount,
    'completedLessons': completedLessons,
    'masteredLessons': masteredLessons,
    'status': status.name,
    'order': order,
  };

  BaseUnit copyWith({
    String? id,
    String? title,
    String? description,
    int? lessonCount,
    int? completedLessons,
    int? masteredLessons,
    UnitStatus? status,
    int? order,
  }) {
    return BaseUnit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lessonCount: lessonCount ?? this.lessonCount,
      completedLessons: completedLessons ?? this.completedLessons,
      masteredLessons: masteredLessons ?? this.masteredLessons,
      status: status ?? this.status,
      order: order ?? this.order,
    );
  }

  BaseUnit withProgress({
    required int completedLessons,
    required int masteredLessons,
  }) {
    UnitStatus newStatus = status;
    if (completedLessons >= lessonCount) {
      newStatus = masteredLessons >= lessonCount 
          ? UnitStatus.mastered 
          : UnitStatus.completed;
    } else if (completedLessons > 0) {
      newStatus = UnitStatus.inProgress;
    }

    return copyWith(
      completedLessons: completedLessons,
      masteredLessons: masteredLessons,
      status: newStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseUnit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BaseUnit($id: $title, ${progressPercentage.toStringAsFixed(0)}%)';
}
