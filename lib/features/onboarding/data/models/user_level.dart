import '../../../../core/constants/app_strings.dart';

/// Model representing a user's learning level
class UserLevel {
  final String id;
  final String name;
  final String description;

  const UserLevel({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Bilingual display name (English / Tamil) for UI only.
  /// Stored [name] and serialized values are unchanged.
  String get displayName {
    switch (id) {
      case 'beginner':
        return AppStrings.inline(
          AppStrings.levelBeginnerEn,
          AppStrings.levelBeginnerTa,
        );
      case 'school_student':
        return AppStrings.inline(
          AppStrings.levelSchoolStudentEn,
          AppStrings.levelSchoolStudentTa,
        );
      default:
        return name;
    }
  }

  /// Bilingual display description (English + Tamil on two lines) for UI
  /// only. Stored [description] and serialized values are unchanged.
  String get displayDescription {
    switch (id) {
      case 'beginner':
        return AppStrings.bilingual(
          AppStrings.levelBeginnerDescEn,
          AppStrings.levelBeginnerDescTa,
        );
      case 'school_student':
        return AppStrings.bilingual(
          AppStrings.levelSchoolStudentDescEn,
          AppStrings.levelSchoolStudentDescTa,
        );
      default:
        return description;
    }
  }

  // Predefined levels
  static const UserLevel beginner = UserLevel(
    id: 'beginner',
    name: 'Beginner',
    description: 'Start from the basics',
  );

  static const UserLevel schoolStudent = UserLevel(
    id: 'school_student',
    name: 'School Student',
    description: 'Learn English for school',
  );

  // Available levels
  static const List<UserLevel> availableLevels = [beginner, schoolStudent];

  static UserLevel? fromId(String id) {
    for (final level in availableLevels) {
      if (level.id == id) return level;
    }
    return null;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final predefined = fromId(id);
    if (predefined != null) {
      return predefined;
    }
    return UserLevel(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLevel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
