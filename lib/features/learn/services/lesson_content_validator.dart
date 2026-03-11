import '../data/models/lesson.dart';
import '../domain/entities/lesson_validation_result.dart';

class LessonContentValidator {
  static const int _minExplainWords = 12;
  static const int _minExamples = 1;
  static const int _minListening = 1;
  static const int _minSpeaking = 1;
  static const int _minPractice = 1;
  static const int _minMastery = 1;
  static const int _phase5MinPractice = 5;
  static const int _phase5MinMastery = 5;
  static const double _minOverallQuality = 0.35;
  static const double _phase5MinOverallQuality = 0.65;
  static const Set<String> _allowedQuestionTypes = {
    'mcq',
    'short_answer',
    'rewrite',
    'ordering',
    'speaking_rubric_scored',
    'writing_rubric_scored',
  };

  LessonValidationResult validateSchema(Map<String, dynamic> rawJson) {
    final errors = <String>[];

    _requireString(rawJson, 'id', errors);
    _requireString(rawJson, 'unitId', errors);
    _requireString(rawJson, 'title', errors);
    _requireString(rawJson, 'description', errors);
    _requireString(rawJson, 'level', errors);

    final order = rawJson['order'];
    if (order is! int || order <= 0) {
      errors.add('Field "order" must be a positive integer.');
    }

    final explain = rawJson['explain'];
    if (explain is! Map<String, dynamic>) {
      errors.add('Field "explain" must be an object.');
    } else {
      _requireString(explain, 'en', errors, parent: 'explain');
      _requireString(explain, 'ta', errors, parent: 'explain');
    }

    _requireList(rawJson, 'examples', errors);
    _requireList(rawJson, 'listeningQuestions', errors);
    _requireList(rawJson, 'speakSentences', errors);
    _requireList(rawJson, 'practiceQuestions', errors);
    _requireList(rawJson, 'masteryQuestions', errors);

    if (_isPhase5(rawJson['id'] as String?)) {
      _requireList(rawJson, 'writingTasks', errors);
      _requireList(rawJson, 'rolePlayTasks', errors);
      _requireList(rawJson, 'errorCorrectionItems', errors);
      _requireList(rawJson, 'targetVocabulary', errors);
      _requireList(rawJson, 'canDoOutcomes', errors);
    }

    return errors.isEmpty
        ? const LessonValidationResult.valid()
        : LessonValidationResult.invalid(
            errors: errors,
            fallbackEligible: false,
          );
  }

  LessonValidationResult validatePedagogy(Lesson lesson) {
    final errors = <String>[];
    final warnings = <String>[];

    final explainWordCount = _countWords(lesson.explain.en);
    if (explainWordCount < _minExplainWords) {
      errors.add('Explanation is too short to teach effectively.');
    }

    if (lesson.examples.length < _minExamples) {
      errors.add('At least $_minExamples example sentence is required.');
    }
    if (lesson.listeningQuestions.length < _minListening) {
      errors.add('At least $_minListening listening question is required.');
    }
    if (lesson.speakSentences.length < _minSpeaking) {
      errors.add('At least $_minSpeaking speaking sentence is required.');
    }
    if (lesson.practiceQuestions.length < _minPractice) {
      errors.add('At least $_minPractice practice questions are required.');
    }
    if (lesson.masteryQuestions.length < _minMastery) {
      errors.add('At least $_minMastery mastery questions are required.');
    }

    final distinctTypes = {
      ...lesson.practiceQuestions.map((q) => q.type.trim().toLowerCase()),
      ...lesson.masteryQuestions.map((q) => q.type.trim().toLowerCase()),
    };
    final unsupported = distinctTypes.where(
      (type) => !_allowedQuestionTypes.contains(type),
    );
    if (unsupported.isNotEmpty) {
      errors.add('Unsupported question type(s): ${unsupported.join(', ')}');
    }
    if (_isPhase5(lesson.id)) {
      if (lesson.practiceQuestions.length < _phase5MinPractice) {
        errors.add(
          'Phase 5 lesson requires at least $_phase5MinPractice practice questions.',
        );
      }
      if (lesson.masteryQuestions.length < _phase5MinMastery) {
        errors.add(
          'Phase 5 lesson requires at least $_phase5MinMastery mastery questions.',
        );
      }
      if (distinctTypes.length < 3) {
        errors.add(
          'Phase 5 lessons must include at least 3 question types across practice and mastery.',
        );
      }
      if (lesson.writingTasks.length < 2) {
        errors.add('Phase 5 lesson requires at least 2 writing tasks.');
      }
      if (lesson.rolePlayTasks.length < 2) {
        errors.add('Phase 5 lesson requires at least 2 role-play tasks.');
      }
      if (lesson.errorCorrectionItems.length < 2) {
        errors.add(
          'Phase 5 lesson requires at least 2 error correction items.',
        );
      }
      if (lesson.targetVocabulary.length < 6) {
        errors.add(
          'Phase 5 lesson requires at least 6 target vocabulary items.',
        );
      }
      if (lesson.canDoOutcomes.isEmpty) {
        errors.add('Phase 5 lesson requires at least one CEFR can-do outcome.');
      }
    } else {
      if (distinctTypes.length < 3) {
        warnings.add(
          'Add more question variety (at least 3 types) for stronger skill coverage.',
        );
      }
      if (lesson.canDoOutcomes.isEmpty || lesson.targetVocabulary.isEmpty) {
        warnings.add(
          'Add CEFR can-do outcomes and target vocabulary for stronger progression.',
        );
      }
    }

    if (!_hasTamilSupport(lesson)) {
      warnings.add('Tamil support is limited for this lesson.');
    }

    final scores = _buildQualityScores(lesson);
    final overall = scores['overall'] ?? 0;
    final minOverall = _isPhase5(lesson.id)
        ? _phase5MinOverallQuality
        : _minOverallQuality;
    if (overall < minOverall) {
      errors.add('Overall lesson quality is below minimum threshold.');
    }

    return errors.isEmpty
        ? LessonValidationResult.valid(
            warnings: warnings,
            qualityScores: scores,
          )
        : LessonValidationResult.invalid(
            errors: errors,
            warnings: warnings,
            qualityScores: scores,
            fallbackEligible: false,
          );
  }

  LessonValidationResult validateForRuntime(
    Map<String, dynamic> rawJson,
    Lesson lesson,
  ) {
    final schema = validateSchema(rawJson);
    if (!schema.isValid) return schema;

    final pedagogy = validatePedagogy(lesson);
    if (!pedagogy.isValid) return pedagogy;

    return LessonValidationResult.valid(
      warnings: pedagogy.warnings,
      qualityScores: pedagogy.qualityScores,
    );
  }

  void _requireString(
    Map<String, dynamic> data,
    String key,
    List<String> errors, {
    String? parent,
  }) {
    final value = data[key];
    if (value is! String || value.trim().isEmpty) {
      final scopedKey = parent == null ? key : '$parent.$key';
      errors.add('Field "$scopedKey" must be a non-empty string.');
    }
  }

  void _requireList(
    Map<String, dynamic> data,
    String key,
    List<String> errors,
  ) {
    final value = data[key];
    if (value is! List || value.isEmpty) {
      errors.add('Field "$key" must be a non-empty list.');
    }
  }

  bool _hasTamilSupport(Lesson lesson) {
    if (lesson.explain.ta.trim().isNotEmpty) return true;
    if (lesson.examples.any((e) => e.ta.trim().isNotEmpty)) return true;
    if (lesson.speakSentences.any((s) => (s.ta ?? '').trim().isNotEmpty)) {
      return true;
    }
    if (lesson.practiceQuestions.any(
      (q) => (q.promptTa ?? '').trim().isNotEmpty,
    )) {
      return true;
    }
    if (lesson.writingTasks.any((q) => (q.promptTa ?? '').trim().isNotEmpty)) {
      return true;
    }
    if (lesson.rolePlayTasks.any(
      (q) => (q.scenarioTa ?? '').trim().isNotEmpty,
    )) {
      return true;
    }
    return false;
  }

  bool _isPhase5(String? lessonId) {
    return lessonId != null && lessonId.startsWith('phase5_');
  }

  int _countWords(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .length;
  }

  Map<String, double> _buildQualityScores(Lesson lesson) {
    final explainScore = (_countWords(lesson.explain.en) / 50).clamp(0.0, 1.0);
    final examplesScore = (lesson.examples.length / 6).clamp(0.0, 1.0);
    final listenScore = (lesson.listeningQuestions.length / 4).clamp(0.0, 1.0);
    final speakScore = (lesson.speakSentences.length / 4).clamp(0.0, 1.0);
    final practiceScore = (lesson.practiceQuestions.length / 6).clamp(0.0, 1.0);
    final masteryScore = (lesson.masteryQuestions.length / 6).clamp(0.0, 1.0);
    final productiveScore =
        ((lesson.writingTasks.length +
                    lesson.rolePlayTasks.length +
                    lesson.errorCorrectionItems.length) /
                6)
            .clamp(0.0, 1.0);

    final includeProductive = lesson.id.startsWith('phase5_');
    final overall = includeProductive
        ? (explainScore +
                  examplesScore +
                  listenScore +
                  speakScore +
                  practiceScore +
                  masteryScore +
                  productiveScore) /
              7
        : (explainScore +
                  examplesScore +
                  listenScore +
                  speakScore +
                  practiceScore +
                  masteryScore) /
              6;

    return {
      'explain': explainScore,
      'examples': examplesScore,
      'listen': listenScore,
      'speak': speakScore,
      'practice': practiceScore,
      'mastery': masteryScore,
      'productive': includeProductive ? productiveScore : 0,
      'overall': overall,
    };
  }
}
