class AppConstants {
  // App info
  static const String appName = 'Engliya';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String userProgressKey = 'user_progress';
  static const String userSettingsKey = 'user_settings';
  static const String hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String selectedLevelKey = 'selected_level';
  static const String lastAccessedLessonKey = 'last_accessed_lesson_id';

  // Lesson paths
  static const String lessonAssetPath = 'assets/lessons/phase1/';

  // Phase 1 configuration
  static const String phase1UnitId = 'phase1';
  static const int phase1TotalLessons = 6;

  // Scoring thresholds
  static const double listeningPassThreshold = 0.7;
  static const double speakingPassThreshold = 0.7;
  static const double practicePassThreshold = 0.6;
  static const double masteryPassThreshold = 0.8;

  // Completion requirements
  static const int minExamplesPlayed = 3;
  static const int minListeningQuestions = 3;
  static const int minSpeakingExercises = 3;

  // TTS configuration
  static const String defaultLanguage = 'en-US';
  static const double defaultTtsRate = 0.5;
  static const double defaultTtsPitch = 1.0;
  static const double defaultTtsVolume = 1.0;

  // UI constants
  static const double minTouchTarget = 48.0;
  static const int tabTransitionDuration = 300;
  static const int buttonPressDuration = 100;
  static const int feedbackAnimationDuration = 200;
  static const int progressAnimationDuration = 500;
}
