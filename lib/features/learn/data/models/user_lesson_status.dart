class UserLessonStatus {
  final String lessonId;
  bool explainDone;
  bool examplesDone;
  double listeningScore;
  double speakingScore;
  double quizBestScore;
  double masteryBestScore;
  bool isMastered;
  DateTime? lastAccessed;

  UserLessonStatus({
    required this.lessonId,
    this.explainDone = false,
    this.examplesDone = false,
    this.listeningScore = 0.0,
    this.speakingScore = 0.0,
    this.quizBestScore = 0.0,
    this.masteryBestScore = 0.0,
    this.isMastered = false,
    this.lastAccessed,
  });

  // Computed property - lesson is unlocked if it's the first lesson or if previous lesson is mastered
  bool get isUnlocked => lessonId == 'phase1_lesson1' || isMastered;

  factory UserLessonStatus.fromJson(Map<String, dynamic> json) {
    return UserLessonStatus(
      lessonId: json['lessonId'] as String,
      explainDone: json['explainDone'] as bool? ?? false,
      examplesDone: json['examplesDone'] as bool? ?? false,
      listeningScore: (json['listeningScore'] as num?)?.toDouble() ?? 0.0,
      speakingScore: (json['speakingScore'] as num?)?.toDouble() ?? 0.0,
      quizBestScore: (json['quizBestScore'] as num?)?.toDouble() ?? 0.0,
      masteryBestScore: (json['masteryBestScore'] as num?)?.toDouble() ?? 0.0,
      isMastered: json['isMastered'] as bool? ?? false,
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.parse(json['lastAccessed'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'explainDone': explainDone,
      'examplesDone': examplesDone,
      'listeningScore': listeningScore,
      'speakingScore': speakingScore,
      'quizBestScore': quizBestScore,
      'masteryBestScore': masteryBestScore,
      'isMastered': isMastered,
      if (lastAccessed != null) 'lastAccessed': lastAccessed!.toIso8601String(),
    };
  }
}
