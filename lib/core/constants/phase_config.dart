import 'package:flutter/foundation.dart';

@immutable
class PhaseConfig {
  final int phaseNumber;
  final String phaseId;
  final String phaseName;
  final int totalUnits;
  final int totalLessons;
  final int testQuestionCount;
  final double passingScore;
  final List<String> unitIds;
  final Map<String, List<String>> lessonsByUnit;

  const PhaseConfig({
    required this.phaseNumber,
    required this.phaseId,
    required this.phaseName,
    required this.totalUnits,
    required this.totalLessons,
    required this.testQuestionCount,
    required this.passingScore,
    required this.unitIds,
    required this.lessonsByUnit,
  });

  String get assetPath => 'assets/lessons/phase$phaseNumber/';

  List<String> get allLessonIds {
    return lessonsByUnit.values.expand((lessons) => lessons).toList();
  }

  List<String> getLessonIdsForUnit(String unitId) {
    return lessonsByUnit[unitId] ?? [];
  }
}

class PhaseConfigs {
  static const PhaseConfig phase1 = PhaseConfig(
    phaseNumber: 1,
    phaseId: 'phase1',
    phaseName: 'Foundation',
    totalUnits: 1,
    totalLessons: 6,
    testQuestionCount: 20,
    passingScore: 0.7,
    unitIds: ['unit1'],
    lessonsByUnit: {
      'unit1': [
        'lesson1_pronouns',
        'lesson2_be_verb',
        'lesson3_nouns_articles',
        'lesson4_object_pronouns',
        'lesson5_action_verbs',
        'lesson6_simple_present',
      ],
    },
  );

  static const PhaseConfig phase2 = PhaseConfig(
    phaseNumber: 2,
    phaseId: 'phase2',
    phaseName: 'Building Blocks',
    totalUnits: 5,
    totalLessons: 18,
    testQuestionCount: 30,
    passingScore: 0.7,
    unitIds: ['unit7', 'unit8', 'unit9', 'unit10', 'unit11'],
    lessonsByUnit: {
      'unit7': [
        'lesson7_1_time_prepositions',
        'lesson7_2_place_prepositions',
        'lesson7_3_time_expressions',
      ],
      'unit8': [
        'lesson8_1_present_continuous',
        'lesson8_2_past_continuous',
        'lesson8_3_future_continuous',
        'lesson8_4_continuous_conversations',
      ],
      'unit9': [
        'lesson9_1_present_perfect',
        'lesson9_2_past_perfect',
        'lesson9_3_future_perfect',
        'lesson9_4_present_perfect_continuous',
        'lesson9_5_perfect_vs_past',
      ],
      'unit10': [
        'lesson10_1_be_questions',
        'lesson10_2_do_does_did_questions',
        'lesson10_3_wh_questions',
        'lesson10_4_negatives',
        'lesson10_5_real_qa',
      ],
      'unit11': [
        'lesson11_1_possessive_pronouns',
        'lesson11_2_reflexive_pronouns',
        'lesson11_3_demonstrative_pronouns',
        'lesson11_4_adjectives',
        'lesson11_5_adverbs',
      ],
    },
  );

  static const PhaseConfig phase3 = PhaseConfig(
    phaseNumber: 3,
    phaseId: 'phase3',
    phaseName: 'Fluency & Expression',
    totalUnits: 6,
    totalLessons: 23,
    testQuestionCount: 30,
    passingScore: 0.7,
    unitIds: ['unit12', 'unit13', 'unit14', 'unit15', 'unit16', 'unit17'],
    lessonsByUnit: {
      'unit12': [
        'lesson12_1_story_listening',
        'lesson12_2_story_qa',
        'lesson12_3_story_retell',
        'lesson12_4_story_tense_change',
      ],
      'unit13': [
        'lesson13_1_connectors_and',
        'lesson13_2_because_so',
        'lesson13_3_when_while',
        'lesson13_4_although_however',
        'lesson13_5_paragraph_writing',
      ],
      'unit14': [
        'lesson14_1_passive_present',
        'lesson14_2_passive_past',
        'lesson14_3_passive_perfect_future',
        'lesson14_4_when_to_use_passive',
      ],
      'unit15': [
        'lesson15_1_reported_statements',
        'lesson15_2_reported_questions',
        'lesson15_3_reported_commands',
        'lesson15_4_dialogue_indirect',
      ],
      'unit16': [
        'lesson16_1_introductions',
        'lesson16_2_phone_calls',
        'lesson16_3_help_clarify',
        'lesson16_4_polite_requests',
        'lesson16_5_complaints_apologies',
      ],
      'unit17': [
        'lesson17_1_daily_routine_project',
        'lesson17_2_description_project',
        'lesson17_3_opinion_writing',
        'lesson17_4_mock_interview',
        'lesson17_5_mini_presentation',
      ],
    },
  );

  static const PhaseConfig phase4 = PhaseConfig(
    phaseNumber: 4,
    phaseId: 'phase4',
    phaseName: 'Pronunciation & Speaking',
    totalUnits: 4,
    totalLessons: 17,
    testQuestionCount: 25,
    passingScore: 0.7,
    unitIds: ['unit18', 'unit19', 'unit20', 'unit21'],
    lessonsByUnit: {
      'unit18': [
        'lesson18_1_sounds_syllables',
        'lesson18_2_word_stress',
        'lesson18_3_sentence_stress',
        'lesson18_4_pronunciation_problems',
      ],
      'unit19': [
        'lesson19_1_keep_talking',
        'lesson19_2_sentence_expansion',
        'lesson19_3_paraphrasing',
        'lesson19_4_hesitation_fillers',
      ],
      'unit20': [
        'lesson20_1_shopping',
        'lesson20_2_restaurant',
        'lesson20_3_travel_hotel',
        'lesson20_4_workplace',
        'lesson20_5_emergencies',
      ],
      'unit21': [
        'lesson21_1_agree_disagree',
        'lesson21_2_opinions_reasons',
        'lesson21_3_follow_up_questions',
        'lesson21_4_mini_discussion',
      ],
    },
  );

  static const PhaseConfig phase5 = PhaseConfig(
    phaseNumber: 5,
    phaseId: 'phase5',
    phaseName: 'Advanced Mastery',
    totalUnits: 4,
    totalLessons: 16,
    testQuestionCount: 35,
    passingScore: 0.7,
    unitIds: ['unit22', 'unit23', 'unit24', 'unit25'],
    lessonsByUnit: {
      'unit22': [
        'lesson22_1_professional_email',
        'lesson22_2_formal_meetings',
        'lesson22_3_negotiation_language',
        'lesson22_4_register_shift',
      ],
      'unit23': [
        'lesson23_1_interview_opening',
        'lesson23_2_strengths_weaknesses',
        'lesson23_3_behavioral_answers',
        'lesson23_4_follow_up_questions',
      ],
      'unit24': [
        'lesson24_1_presentation_opening',
        'lesson24_2_signposting_transitions',
        'lesson24_3_data_commentary',
        'lesson24_4_qna_handling',
      ],
      'unit25': [
        'lesson25_1_argument_essay',
        'lesson25_2_synthesis_summary',
        'lesson25_3_paraphrase_precision',
        'lesson25_4_critical_response',
      ],
    },
  );

  static PhaseConfig getConfig(int phaseNumber) {
    switch (phaseNumber) {
      case 1:
        return phase1;
      case 2:
        return phase2;
      case 3:
        return phase3;
      case 4:
        return phase4;
      case 5:
        return phase5;
      default:
        throw ArgumentError('Invalid phase number: $phaseNumber');
    }
  }

  static PhaseConfig? getConfigById(String phaseId) {
    switch (phaseId) {
      case 'phase1':
        return phase1;
      case 'phase2':
        return phase2;
      case 'phase3':
        return phase3;
      case 'phase4':
        return phase4;
      case 'phase5':
        return phase5;
      default:
        return null;
    }
  }

  static List<PhaseConfig> get all => [phase1, phase2, phase3, phase4, phase5];

  static int get totalPhases => 4;

  static List<String> getAllLessonIds() {
    return all.expand((config) => config.allLessonIds).toList();
  }

  static int? getPhaseForLesson(String lessonId) {
    for (final config in all) {
      if (config.allLessonIds.contains(lessonId)) {
        return config.phaseNumber;
      }
    }
    return null;
  }

  static String? getUnitForLesson(String lessonId) {
    for (final config in all) {
      for (final entry in config.lessonsByUnit.entries) {
        if (entry.value.contains(lessonId)) {
          return entry.key;
        }
      }
    }
    return null;
  }
}
