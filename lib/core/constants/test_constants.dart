class TestConstants {
  TestConstants._();

  static const double defaultPassingScore = 0.7;
  static const int defaultRetryAttempts = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);
  
  static const int phase1QuestionCount = 20;
  static const int phase2QuestionCount = 30;
  static const int phase3QuestionCount = 30;
  static const int phase4QuestionCount = 25;
  static const int phase5QuestionCount = 30;

  static const Map<String, int> phase1Distribution = {
    'lesson1_pronouns': 3,
    'lesson2_be_verb': 4,
    'lesson3_nouns_articles': 3,
    'lesson4_object_pronouns': 4,
    'lesson5_action_verbs': 3,
    'lesson6_simple_present': 3,
  };

  static const int masteryQuestionCount = 10;
  static const int minQuestionsForMastery = 8;
  static const double masteryThreshold = 0.8;

  static const double speakingPassingScore = 0.6;
  static const int minSpeakingWordCount = 5;
  static const int optimalSpeakingWordCount = 10;
}
