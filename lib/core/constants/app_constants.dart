class AppConstants {
  AppConstants._();
  
  static const String appName = 'Engliya';
  static const String appVersion = '1.0.0';

  static const String userProgressKey = 'user_progress';
  static const String userSettingsKey = 'user_settings';
  static const String hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String selectedLevelKey = 'selected_level';
  static const String lastAccessedLessonKey = 'last_accessed_lesson_id';
}

class LessonConstants {
  LessonConstants._();

  static const String phase1AssetPath = 'assets/lessons/phase1/';
  static const String phase2AssetPath = 'assets/lessons/phase2/';
  static const String phase3AssetPath = 'assets/lessons/phase3/';
  static const String phase4AssetPath = 'assets/lessons/phase4/';

  static String getAssetPath(int phaseNumber) => 'assets/lessons/phase$phaseNumber/';
}

class ScoringConstants {
  ScoringConstants._();

  static const double listeningPassThreshold = 0.7;
  static const double speakingPassThreshold = 0.7;
  static const double practicePassThreshold = 0.6;
  static const double masteryPassThreshold = 0.8;
  static const double finalTestPassThreshold = 0.7;
}

class CompletionConstants {
  CompletionConstants._();

  static const int minExamplesPlayed = 3;
  static const int minListeningQuestions = 3;
  static const int minSpeakingExercises = 3;
}

class TTSConstants {
  TTSConstants._();

  static const String defaultLanguage = 'en-US';
  static const double defaultRate = 0.5;
  static const double defaultPitch = 1.0;
  static const double defaultVolume = 1.0;

  static const double minRate = 0.1;
  static const double maxRate = 1.0;
  static const double minPitch = 0.5;
  static const double maxPitch = 2.0;
}

class UIConstants {
  UIConstants._();

  static const double minTouchTarget = 48.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const int tabTransitionDurationMs = 300;
  static const int buttonPressDurationMs = 100;
  static const int feedbackAnimationDurationMs = 200;
  static const int progressAnimationDurationMs = 500;

  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}
