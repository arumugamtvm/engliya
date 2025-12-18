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
  static const List<UserLevel> availableLevels = [
    beginner,
    schoolStudent,
  ];

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      id: json['id'] as String,
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
