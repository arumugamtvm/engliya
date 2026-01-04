import 'phase_config.dart';
import 'unit.dart';

class PhaseUnits {
  static const List<Unit> phase2 = [
    Unit(
      id: 'phase2_unit7',
      order: 7,
      title: 'Time & Place Language',
      description: 'Learn prepositions and time expressions',
      lessonCount: 3,
    ),
    Unit(
      id: 'phase2_unit8',
      order: 8,
      title: 'Continuous Tenses',
      description: 'Present, past, and future continuous',
      lessonCount: 4,
    ),
    Unit(
      id: 'phase2_unit9',
      order: 9,
      title: 'Perfect & Perfect Continuous',
      description: 'Master perfect tenses',
      lessonCount: 5,
    ),
    Unit(
      id: 'phase2_unit10',
      order: 10,
      title: 'Questions & Negatives',
      description: 'Ask questions and form negatives',
      lessonCount: 5,
    ),
    Unit(
      id: 'phase2_unit11',
      order: 11,
      title: 'Advanced Pronouns, Adjectives & Adverbs',
      description: 'Enrich your sentences',
      lessonCount: 5,
    ),
  ];

  static const List<Unit> phase3 = [
    Unit(
      id: 'phase3_unit12',
      order: 12,
      title: 'Story Listening & Retelling',
      description: 'Understand and retell stories',
      lessonCount: 4,
    ),
    Unit(
      id: 'phase3_unit13',
      order: 13,
      title: 'Complex Sentences & Connectors',
      description: 'Join ideas with connectors',
      lessonCount: 5,
    ),
    Unit(
      id: 'phase3_unit14',
      order: 14,
      title: 'Passive Voice',
      description: 'Use passive constructions',
      lessonCount: 4,
    ),
    Unit(
      id: 'phase3_unit15',
      order: 15,
      title: 'Reported Speech',
      description: 'Report what others said',
      lessonCount: 4,
    ),
    Unit(
      id: 'phase3_unit16',
      order: 16,
      title: 'Functional English',
      description: 'Handle everyday situations',
      lessonCount: 5,
    ),
    Unit(
      id: 'phase3_unit17',
      order: 17,
      title: 'Speaking & Writing Projects',
      description: 'Demonstrate communication skills',
      lessonCount: 5,
    ),
  ];

  static const List<Unit> phase4 = [
    Unit(
      id: 'phase4_unit18',
      order: 18,
      title: 'Pronunciation & Sound',
      description: 'Learn English sounds, syllables, and stress patterns',
      lessonCount: 4,
    ),
    Unit(
      id: 'phase4_unit19',
      order: 19,
      title: 'Fluency Techniques',
      description: 'Speak more smoothly and naturally',
      lessonCount: 4,
    ),
    Unit(
      id: 'phase4_unit20',
      order: 20,
      title: 'Real-Life Conversations',
      description: 'Practice everyday communication scenarios',
      lessonCount: 5,
    ),
    Unit(
      id: 'phase4_unit21',
      order: 21,
      title: 'Discussion & Opinion Skills',
      description: 'Express opinions and engage in discussions',
      lessonCount: 4,
    ),
  ];

  static List<Unit> get all => [
        ...phase2,
        ...phase3,
        ...phase4,
      ];

  static Unit? findById(String unitId) {
    for (final unit in all) {
      if (unit.id == unitId) return unit;
    }
    return null;
  }

  static List<Unit> forType(PhaseType type) {
    switch (type) {
      case PhaseType.phase2:
        return phase2;
      case PhaseType.phase3:
        return phase3;
      case PhaseType.phase4:
        return phase4;
      case PhaseType.phase1:
      case PhaseType.phase5:
        throw ArgumentError('No unit list configured for $type');
    }
  }
}
