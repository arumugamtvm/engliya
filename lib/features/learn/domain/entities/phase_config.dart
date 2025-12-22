/// Enum representing all learning phases in the application
enum PhaseType {
  phase1,
  phase2,
  phase3,
  phase4,
  phase5,
}

/// Centralized configuration for all phases
/// Contains all phase-specific settings including asset paths, scoring rules,
/// question distribution, and storage keys
class PhaseConfig {
  final PhaseType type;
  final String id;
  final String name;
  final String assetPath;
  final int passingScore;
  final int totalQuestions;
  final int maxScore;
  final Map<String, int> questionDistribution;
  final Map<String, String> unitNames;
  final Map<String, String> lessonToUnitMapping;
  final String storageKeyPrefix;
  final List<String> requiredLessonIds;

  const PhaseConfig({
    required this.type,
    required this.id,
    required this.name,
    required this.assetPath,
    required this.passingScore,
    required this.totalQuestions,
    required this.maxScore,
    required this.questionDistribution,
    required this.unitNames,
    required this.lessonToUnitMapping,
    required this.storageKeyPrefix,
    required this.requiredLessonIds,
  });

  // Storage keys derived from prefix
  String get keyTestPassed => '${storageKeyPrefix}_final_test_passed';
  String get keyTestScore => '${storageKeyPrefix}_final_test_score';
  String get keyTestDate => '${storageKeyPrefix}_final_test_date';
  String get keyTestResult => '${storageKeyPrefix}_final_test_result';
  String get keyNextPhaseUnlocked => '${_nextPhasePrefix}_unlocked';

  String get _nextPhasePrefix {
    switch (type) {
      case PhaseType.phase1:
        return 'phase2';
      case PhaseType.phase2:
        return 'phase3';
      case PhaseType.phase3:
        return 'phase4';
      case PhaseType.phase4:
        return 'phase5';
      case PhaseType.phase5:
        return 'english_mastery_completed';
    }
  }

  /// Get PhaseConfig from PhaseType
  static PhaseConfig fromType(PhaseType type) {
    switch (type) {
      case PhaseType.phase1:
        return phase1;
      case PhaseType.phase2:
        return phase2;
      case PhaseType.phase3:
        return phase3;
      case PhaseType.phase4:
        return phase4;
      case PhaseType.phase5:
        return phase5;
    }
  }

  // Phase 1 Configuration
  static const phase1 = PhaseConfig(
    type: PhaseType.phase1,
    id: 'phase1',
    name: 'Phase 1: Foundations',
    assetPath: 'assets/lessons/phase1/',
    passingScore: 16,
    totalQuestions: 20,
    maxScore: 20,
    questionDistribution: {
      'phase1_lesson1': 4, // Pronouns
      'phase1_lesson2': 4, // Be Verb
      'phase1_lesson3': 4, // Nouns & Articles
      'phase1_lesson4': 3, // Object Pronouns
      'phase1_lesson5': 3, // Action Verbs
      'phase1_lesson6': 2, // Simple Present
    },
    unitNames: {},
    lessonToUnitMapping: {
      'phase1_lesson1': 'lesson1',
      'phase1_lesson2': 'lesson2',
      'phase1_lesson3': 'lesson3',
      'phase1_lesson4': 'lesson4',
      'phase1_lesson5': 'lesson5',
      'phase1_lesson6': 'lesson6',
    },
    storageKeyPrefix: 'phase1',
    requiredLessonIds: [
      'phase1_lesson1',
      'phase1_lesson2',
      'phase1_lesson3',
      'phase1_lesson4',
      'phase1_lesson5',
      'phase1_lesson6',
    ],
  );

  // Phase 2 Configuration
  static const phase2 = PhaseConfig(
    type: PhaseType.phase2,
    id: 'phase2',
    name: 'Phase 2: Grammar Expansion',
    assetPath: 'assets/lessons/phase2/',
    passingScore: 20,
    totalQuestions: 25,
    maxScore: 25,
    questionDistribution: {
      'unit7': 5,  // Time & Place Prepositions
      'unit8': 6,  // Continuous Tenses
      'unit9': 5,  // Perfect Tenses
      'unit10': 5, // Questions & Negatives
      'unit11': 4, // Advanced Pronouns, Adjectives & Adverbs
    },
    unitNames: {
      'unit7': 'Time & Place',
      'unit8': 'Continuous Tenses',
      'unit9': 'Perfect Tenses',
      'unit10': 'Questions/Neg',
      'unit11': 'Adj/Adv/Pronouns',
    },
    lessonToUnitMapping: {
      // Unit 7 - Time & Place Language
      'phase2_lesson7_1': 'unit7',
      'phase2_lesson7_2': 'unit7',
      'phase2_lesson7_3': 'unit7',
      // Unit 8 - Continuous Tenses
      'phase2_lesson8_1': 'unit8',
      'phase2_lesson8_2': 'unit8',
      'phase2_lesson8_3': 'unit8',
      'phase2_lesson8_4': 'unit8',
      // Unit 9 - Perfect & Perfect Continuous
      'phase2_lesson9_1': 'unit9',
      'phase2_lesson9_2': 'unit9',
      'phase2_lesson9_3': 'unit9',
      'phase2_lesson9_4': 'unit9',
      'phase2_lesson9_5': 'unit9',
      // Unit 10 - Questions & Negatives
      'phase2_lesson10_1': 'unit10',
      'phase2_lesson10_2': 'unit10',
      'phase2_lesson10_3': 'unit10',
      'phase2_lesson10_4': 'unit10',
      'phase2_lesson10_5': 'unit10',
      // Unit 11 - Advanced Pronouns, Adjectives & Adverbs
      'phase2_lesson11_1': 'unit11',
      'phase2_lesson11_2': 'unit11',
      'phase2_lesson11_3': 'unit11',
      'phase2_lesson11_4': 'unit11',
      'phase2_lesson11_5': 'unit11',
    },
    storageKeyPrefix: 'phase2',
    requiredLessonIds: [
      'phase2_lesson7_1', 'phase2_lesson7_2', 'phase2_lesson7_3',
      'phase2_lesson8_1', 'phase2_lesson8_2', 'phase2_lesson8_3', 'phase2_lesson8_4',
      'phase2_lesson9_1', 'phase2_lesson9_2', 'phase2_lesson9_3', 'phase2_lesson9_4', 'phase2_lesson9_5',
      'phase2_lesson10_1', 'phase2_lesson10_2', 'phase2_lesson10_3', 'phase2_lesson10_4', 'phase2_lesson10_5',
      'phase2_lesson11_1', 'phase2_lesson11_2', 'phase2_lesson11_3', 'phase2_lesson11_4', 'phase2_lesson11_5',
    ],
  );

  // Phase 3 Configuration
  static const phase3 = PhaseConfig(
    type: PhaseType.phase3,
    id: 'phase3',
    name: 'Phase 3: Real-Life Communication',
    assetPath: 'assets/lessons/phase3/',
    passingScore: 24,
    totalQuestions: 30,
    maxScore: 30,
    questionDistribution: {
      'unit12': 6, // Story Listening & Retelling
      'unit13': 7, // Complex Sentences & Connectors
      'unit14': 5, // Passive Voice
      'unit15': 5, // Reported Speech
      'unit16': 4, // Functional English
      'unit17': 3, // Speaking & Writing Projects
    },
    unitNames: {
      'unit12': 'Stories & Retelling',
      'unit13': 'Connectors & Complex Sent.',
      'unit14': 'Passive Voice',
      'unit15': 'Reported Speech',
      'unit16': 'Functional English',
      'unit17': 'Projects & General Use',
    },
    lessonToUnitMapping: {
      // Unit 12 - Story Listening & Retelling
      'phase3_lesson12_1': 'unit12',
      'phase3_lesson12_2': 'unit12',
      'phase3_lesson12_3': 'unit12',
      'phase3_lesson12_4': 'unit12',
      // Unit 13 - Complex Sentences & Connectors
      'phase3_lesson13_1': 'unit13',
      'phase3_lesson13_2': 'unit13',
      'phase3_lesson13_3': 'unit13',
      'phase3_lesson13_4': 'unit13',
      'phase3_lesson13_5': 'unit13',
      // Unit 14 - Passive Voice
      'phase3_lesson14_1': 'unit14',
      'phase3_lesson14_2': 'unit14',
      'phase3_lesson14_3': 'unit14',
      'phase3_lesson14_4': 'unit14',
      // Unit 15 - Reported Speech
      'phase3_lesson15_1': 'unit15',
      'phase3_lesson15_2': 'unit15',
      'phase3_lesson15_3': 'unit15',
      'phase3_lesson15_4': 'unit15',
      // Unit 16 - Functional English
      'phase3_lesson16_1': 'unit16',
      'phase3_lesson16_2': 'unit16',
      'phase3_lesson16_3': 'unit16',
      'phase3_lesson16_4': 'unit16',
      'phase3_lesson16_5': 'unit16',
      // Unit 17 - Speaking & Writing Projects
      'phase3_lesson17_1': 'unit17',
      'phase3_lesson17_2': 'unit17',
      'phase3_lesson17_3': 'unit17',
      'phase3_lesson17_4': 'unit17',
      'phase3_lesson17_5': 'unit17',
    },
    storageKeyPrefix: 'phase3',
    requiredLessonIds: [
      // Units 12-16 are required, Unit 17 is optional
      'phase3_lesson12_1', 'phase3_lesson12_2', 'phase3_lesson12_3', 'phase3_lesson12_4',
      'phase3_lesson13_1', 'phase3_lesson13_2', 'phase3_lesson13_3', 'phase3_lesson13_4', 'phase3_lesson13_5',
      'phase3_lesson14_1', 'phase3_lesson14_2', 'phase3_lesson14_3', 'phase3_lesson14_4',
      'phase3_lesson15_1', 'phase3_lesson15_2', 'phase3_lesson15_3', 'phase3_lesson15_4',
      'phase3_lesson16_1', 'phase3_lesson16_2', 'phase3_lesson16_3', 'phase3_lesson16_4', 'phase3_lesson16_5',
    ],
  );

  // Phase 4 Configuration
  static const phase4 = PhaseConfig(
    type: PhaseType.phase4,
    id: 'phase4',
    name: 'Phase 4: Fluency & Pronunciation',
    assetPath: 'assets/lessons/phase4/',
    passingScore: 18,
    totalQuestions: 20,
    maxScore: 24, // 16 MCQ + 12 speaking (4 tasks × 3 points)
    questionDistribution: {
      'pronunciation': 6,
      'dialogue': 6,
      'listening': 4,
      'speaking': 4,
    },
    unitNames: {
      'unit18': 'Pronunciation & Sound',
      'unit19': 'Fluency Techniques',
      'unit20': 'Real-Life Conversations',
      'unit21': 'Discussion & Opinion',
    },
    lessonToUnitMapping: {
      // Unit 18 - Pronunciation & Sound
      'phase4_lesson18_1': 'unit18',
      'phase4_lesson18_2': 'unit18',
      'phase4_lesson18_3': 'unit18',
      'phase4_lesson18_4': 'unit18',
      // Unit 19 - Fluency Techniques
      'phase4_lesson19_1': 'unit19',
      'phase4_lesson19_2': 'unit19',
      'phase4_lesson19_3': 'unit19',
      'phase4_lesson19_4': 'unit19',
      // Unit 20 - Real-Life Conversations
      'phase4_lesson20_1': 'unit20',
      'phase4_lesson20_2': 'unit20',
      'phase4_lesson20_3': 'unit20',
      'phase4_lesson20_4': 'unit20',
      'phase4_lesson20_5': 'unit20',
      // Unit 21 - Discussion & Opinion Skills
      'phase4_lesson21_1': 'unit21',
      'phase4_lesson21_2': 'unit21',
      'phase4_lesson21_3': 'unit21',
      'phase4_lesson21_4': 'unit21',
    },
    storageKeyPrefix: 'phase4',
    requiredLessonIds: [
      'phase4_lesson18_1', 'phase4_lesson18_2', 'phase4_lesson18_3', 'phase4_lesson18_4',
      'phase4_lesson19_1', 'phase4_lesson19_2', 'phase4_lesson19_3', 'phase4_lesson19_4',
      'phase4_lesson20_1', 'phase4_lesson20_2', 'phase4_lesson20_3', 'phase4_lesson20_4', 'phase4_lesson20_5',
      'phase4_lesson21_1', 'phase4_lesson21_2', 'phase4_lesson21_3', 'phase4_lesson21_4',
    ],
  );

  // Phase 5 Configuration
  static const phase5 = PhaseConfig(
    type: PhaseType.phase5,
    id: 'phase5',
    name: 'Phase 5: Professional English',
    assetPath: 'assets/lessons/phase5/',
    passingScore: 45,
    totalQuestions: 35,
    maxScore: 60, // 27 MCQ + 32 speaking (8 tasks × 4 points)
    questionDistribution: {
      'businessEnglish': 8,
      'interview': 7,
      'presentation': 6,
      'writing': 6,
      'speaking': 8,
    },
    unitNames: {
      'unit22': 'Business Communication',
      'unit23': 'Interview English',
      'unit24': 'Presentation Skills',
      'unit25': 'Advanced Writing',
    },
    lessonToUnitMapping: {
      // Unit 22 - Business Communication
      'phase5_lesson22_1': 'unit22',
      'phase5_lesson22_2': 'unit22',
      'phase5_lesson22_3': 'unit22',
      'phase5_lesson22_4': 'unit22',
      // Unit 23 - Interview English
      'phase5_lesson23_1': 'unit23',
      'phase5_lesson23_2': 'unit23',
      'phase5_lesson23_3': 'unit23',
      'phase5_lesson23_4': 'unit23',
      // Unit 24 - Presentation Skills
      'phase5_lesson24_1': 'unit24',
      'phase5_lesson24_2': 'unit24',
      'phase5_lesson24_3': 'unit24',
      'phase5_lesson24_4': 'unit24',
      // Unit 25 - Advanced Writing
      'phase5_lesson25_1': 'unit25',
      'phase5_lesson25_2': 'unit25',
      'phase5_lesson25_3': 'unit25',
      'phase5_lesson25_4': 'unit25',
    },
    storageKeyPrefix: 'phase5',
    requiredLessonIds: [
      'phase5_lesson22_1', 'phase5_lesson22_2', 'phase5_lesson22_3', 'phase5_lesson22_4',
      'phase5_lesson23_1', 'phase5_lesson23_2', 'phase5_lesson23_3', 'phase5_lesson23_4',
      'phase5_lesson24_1', 'phase5_lesson24_2', 'phase5_lesson24_3', 'phase5_lesson24_4',
      'phase5_lesson25_1', 'phase5_lesson25_2', 'phase5_lesson25_3', 'phase5_lesson25_4',
    ],
  );

  /// Check if this phase has unit-based organization
  bool get hasUnits => unitNames.isNotEmpty;

  /// Get the unit ID for a given lesson ID
  String? getUnitForLesson(String lessonId) => lessonToUnitMapping[lessonId];

  /// Get all lesson IDs for a given unit
  List<String> getLessonsForUnit(String unitId) {
    return lessonToUnitMapping.entries
        .where((entry) => entry.value == unitId)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => type.hashCode ^ id.hashCode;

  @override
  String toString() => 'PhaseConfig($id)';
}
