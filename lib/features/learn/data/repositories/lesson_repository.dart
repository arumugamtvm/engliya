import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../../services/lesson_content_validator.dart';
import '../../domain/entities/lesson_validation_result.dart';

class ValidatedLesson {
  final Lesson lesson;
  final LessonValidationResult validation;
  final String source;
  final String? fallbackFromLessonId;

  const ValidatedLesson({
    required this.lesson,
    required this.validation,
    this.source = 'primary',
    this.fallbackFromLessonId,
  });
}

/// Repository for loading lesson content from local JSON assets
/// Handles asset loading, JSON parsing, and caching
class LessonRepository {
  // Cache for loaded lessons to avoid repeated asset loading
  static const bool _allowFallbackInProduction = false;
  final Map<String, Lesson> _lessonCache = {};
  final Map<String, ValidatedLesson> _validatedCache = {};
  Map<String, String>? _assetPathByLessonIdCache;
  final LessonContentValidator _validator = LessonContentValidator();

  /// Load a single lesson by its ID
  /// Returns cached lesson if available, otherwise loads from assets
  /// Throws [LessonLoadException] if asset not found or JSON is invalid
  Future<Lesson> loadLesson(String lessonId) async {
    final validated = await loadLessonWithFallback(lessonId);
    if (validated.source != 'primary') {
      throw LessonFallbackException(
        'Primary lesson "$lessonId" is invalid. Fallback "${validated.lesson.id}" was selected.',
      );
    }
    return validated.lesson;
  }

  Future<ValidatedLesson> loadLessonWithFallback(String lessonId) async {
    if (_validatedCache.containsKey(lessonId)) {
      return _validatedCache[lessonId]!;
    }

    try {
      final primary = await _loadAndValidatePrimaryLesson(lessonId);
      _validatedCache[lessonId] = primary;
      _lessonCache[lessonId] = primary.lesson;
      return primary;
    } on LessonSchemaException catch (primaryError) {
      if (!_isFallbackAllowed()) {
        rethrow;
      }
      final fallback = await _tryLoadFallbackLesson(lessonId, primaryError);
      _validatedCache[lessonId] = fallback;
      _lessonCache[lessonId] = fallback.lesson;
      return fallback;
    } on LessonQualityException catch (primaryError) {
      if (!_isFallbackAllowed()) {
        rethrow;
      }
      final fallback = await _tryLoadFallbackLesson(lessonId, primaryError);
      _validatedCache[lessonId] = fallback;
      _lessonCache[lessonId] = fallback.lesson;
      return fallback;
    } on FormatException catch (e) {
      throw LessonSchemaException(
        'Invalid JSON format for lesson "$lessonId": ${e.message}',
      );
    } catch (e) {
      if (e is LessonLoadException) rethrow;
      throw LessonLoadException('Failed to load lesson "$lessonId": $e');
    }
  }

  /// Load all lessons for a specific unit (e.g., Phase 1)
  /// Returns list of lessons sorted by order
  /// Throws [LessonLoadException] if any lesson fails to load
  Future<List<Lesson>> loadUnitLessons(String unitId) async {
    try {
      final phaseMatch = RegExp(r'^phase(\d+)(?:_unit\d+)?$').firstMatch(unitId);
      if (phaseMatch != null) {
        final phaseNumber = int.parse(phaseMatch.group(1)!);
        final phaseLessons = await loadLessonsForPhase(phaseNumber);

        // "phase1" style returns all lessons in phase.
        if (!unitId.contains('_unit')) {
          return phaseLessons;
        }

        // "phaseX_unitY" style filters lessons by unit id from lesson json.
        final filtered = phaseLessons
            .where((lesson) => lesson.unitId == unitId)
            .toList(growable: false)
          ..sort((a, b) => a.order.compareTo(b.order));

        return filtered;
      }

      throw LessonLoadException('Unknown unit ID: $unitId');
    } catch (e) {
      if (e is LessonLoadException) {
        rethrow;
      }
      throw LessonLoadException(
        'Failed to load unit lessons: $unitId. Error: $e',
      );
    }
  }

  Future<List<Lesson>> loadLessonsForPhase(int phaseNumber) async {
    final prefix = 'phase${phaseNumber}_';
    final assetIndex = await _getLessonAssetIndex();
    final lessonIds = assetIndex.keys
        .where((lessonId) => lessonId.startsWith(prefix))
        .toList(growable: false);

    final lessons = <Lesson>[];
    for (final lessonId in lessonIds) {
      try {
        final validated = await loadLessonWithFallback(lessonId);
        lessons.add(validated.lesson);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }

    lessons.sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }

  Future<Map<String, String>> _getLessonAssetIndex() async {
    if (_assetPathByLessonIdCache != null) {
      return _assetPathByLessonIdCache!;
    }

    final assetPaths = await _loadLessonAssetPathsFromManifest();

    final index = <String, String>{};
    for (final path in assetPaths) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        final lessonId = jsonData['id'];
        if (lessonId is String && lessonId.isNotEmpty) {
          index[lessonId] = path;
        }
      } catch (_) {
        // Ignore malformed assets here; they will fail validation when loaded directly.
      }
    }

    _assetPathByLessonIdCache = index;
    return index;
  }

  Future<List<String>> _loadLessonAssetPathsFromManifest() async {
    // Older Flutter builds expose AssetManifest.json directly.
    try {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      return manifest.keys
          .where(
            (path) =>
                path.startsWith('assets/lessons/phase') &&
                path.endsWith('.json'),
          )
          .toList(growable: false);
    } catch (_) {
      // Fall through to newer manifest variants.
    }

    // Newer Flutter builds often provide AssetManifest.bin.json.
    try {
      final manifestRaw = await rootBundle.loadString('AssetManifest.bin.json');
      final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      return manifest.keys
          .where(
            (path) =>
                path.startsWith('assets/lessons/phase') &&
                path.endsWith('.json'),
          )
          .toList(growable: false);
    } catch (_) {
      // Fall through to deterministic fallback list.
    }

    // Last resort: deterministic phase directory scan using known names.
    final fallback = <String>[];
    for (int phase = 1; phase <= 5; phase++) {
      final candidates = _allKnownLessonIds
          .where((id) => id.startsWith('phase${phase}_'))
          .toList(growable: false);
      for (final lessonId in candidates) {
        try {
          final path = _getAssetPath(lessonId);
          await rootBundle.loadString(path);
          fallback.add(path);
        } catch (_) {
          // Ignore missing assets; only keep existing files.
        }
      }
    }
    return fallback;
  }

  /// Load Phase 2 unit lessons
  /// Returns list of lessons for the specified Phase 2 unit
  Future<List<Lesson>> _loadPhase2UnitLessons(String unitId) async {
    final lessons = <Lesson>[];
    final lessonIds = _getPhase2LessonIds(unitId);

    for (final lessonId in lessonIds) {
      try {
        final validated = await loadLessonWithFallback(lessonId);
        lessons.add(validated.lesson);
      } catch (e) {
        // Log error but continue loading other lessons
        print('Warning: Failed to load $lessonId: $e');
      }
    }

    // Sort by order to ensure correct sequence
    lessons.sort((a, b) => a.order.compareTo(b.order));

    return lessons;
  }

  /// Get lesson IDs for a Phase 2 unit
  List<String> _getPhase2LessonIds(String unitId) {
    switch (unitId) {
      case 'phase2_unit7':
        return ['phase2_lesson7_1', 'phase2_lesson7_2', 'phase2_lesson7_3'];
      case 'phase2_unit8':
        return [
          'phase2_lesson8_1',
          'phase2_lesson8_2',
          'phase2_lesson8_3',
          'phase2_lesson8_4',
        ];
      case 'phase2_unit9':
        return [
          'phase2_lesson9_1',
          'phase2_lesson9_2',
          'phase2_lesson9_3',
          'phase2_lesson9_4',
          'phase2_lesson9_5',
        ];
      case 'phase2_unit10':
        return [
          'phase2_lesson10_1',
          'phase2_lesson10_2',
          'phase2_lesson10_3',
          'phase2_lesson10_4',
          'phase2_lesson10_5',
        ];
      case 'phase2_unit11':
        return [
          'phase2_lesson11_1',
          'phase2_lesson11_2',
          'phase2_lesson11_3',
          'phase2_lesson11_4',
          'phase2_lesson11_5',
        ];
      default:
        throw LessonLoadException('Unknown Phase 2 unit: $unitId');
    }
  }

  /// Load Phase 3 unit lessons
  /// Returns list of lessons for the specified Phase 3 unit
  Future<List<Lesson>> _loadPhase3UnitLessons(String unitId) async {
    final lessons = <Lesson>[];
    final lessonIds = _getPhase3LessonIds(unitId);

    for (final lessonId in lessonIds) {
      try {
        final validated = await loadLessonWithFallback(lessonId);
        lessons.add(validated.lesson);
      } catch (e) {
        // Log error but continue loading other lessons
        print('Warning: Failed to load $lessonId: $e');
      }
    }

    // Sort by order to ensure correct sequence
    lessons.sort((a, b) => a.order.compareTo(b.order));

    return lessons;
  }

  /// Get lesson IDs for a Phase 3 unit
  List<String> _getPhase3LessonIds(String unitId) {
    switch (unitId) {
      case 'phase3_unit12':
        return [
          'phase3_lesson12_1',
          'phase3_lesson12_2',
          'phase3_lesson12_3',
          'phase3_lesson12_4',
        ];
      case 'phase3_unit13':
        return [
          'phase3_lesson13_1',
          'phase3_lesson13_2',
          'phase3_lesson13_3',
          'phase3_lesson13_4',
          'phase3_lesson13_5',
        ];
      case 'phase3_unit14':
        return [
          'phase3_lesson14_1',
          'phase3_lesson14_2',
          'phase3_lesson14_3',
          'phase3_lesson14_4',
        ];
      case 'phase3_unit15':
        return [
          'phase3_lesson15_1',
          'phase3_lesson15_2',
          'phase3_lesson15_3',
          'phase3_lesson15_4',
        ];
      case 'phase3_unit16':
        return [
          'phase3_lesson16_1',
          'phase3_lesson16_2',
          'phase3_lesson16_3',
          'phase3_lesson16_4',
          'phase3_lesson16_5',
        ];
      case 'phase3_unit17':
        return [
          'phase3_lesson17_1',
          'phase3_lesson17_2',
          'phase3_lesson17_3',
          'phase3_lesson17_4',
          'phase3_lesson17_5',
        ];
      default:
        throw LessonLoadException('Unknown Phase 3 unit: $unitId');
    }
  }

  /// Construct asset path from lesson ID
  /// Example: phase1_lesson1 -> assets/lessons/phase1/lesson1_pronouns.json
  /// Example: phase2_lesson7_1 -> assets/lessons/phase2/lesson7_1_time_prepositions.json
  /// Example: phase3_lesson12_1 -> assets/lessons/phase3/lesson12_1_story_listening.json
  /// Example: phase4_lesson18_1 -> assets/lessons/phase4/lesson18_1_sounds_syllables.json
  String _getAssetPath(String lessonId) {
    if (lessonId.startsWith('phase5_')) {
      return _getPhase5AssetPath(lessonId);
    }

    // Handle Phase 4 lessons
    if (lessonId.startsWith('phase4_')) {
      return _getPhase4AssetPath(lessonId);
    }

    // Handle Phase 3 lessons
    if (lessonId.startsWith('phase3_')) {
      return _getPhase3AssetPath(lessonId);
    }

    // Handle Phase 2 lessons
    if (lessonId.startsWith('phase2_')) {
      return _getPhase2AssetPath(lessonId);
    }

    // Handle Phase 1 lessons
    // Extract unit and lesson number from ID
    // Expected format: phase1_lesson1, phase1_lesson2, etc.
    final parts = lessonId.split('_');
    if (parts.length != 2) {
      throw LessonLoadException('Invalid lesson ID format: $lessonId');
    }

    final unit = parts[0]; // e.g., "phase1"
    final lessonNumber = parts[1]; // e.g., "lesson1"

    // Map lesson numbers to file names
    final lessonFileNames = {
      'lesson1': 'lesson1_pronouns.json',
      'lesson2': 'lesson2_be_verb.json',
      'lesson3': 'lesson3_nouns_articles.json',
      'lesson4': 'lesson4_object_pronouns.json',
      'lesson5': 'lesson5_action_verbs.json',
      'lesson6': 'lesson6_simple_present.json',
    };

    final fileName = lessonFileNames[lessonNumber];
    if (fileName == null) {
      throw LessonLoadException('Unknown lesson number: $lessonNumber');
    }

    return 'assets/lessons/$unit/$fileName';
  }

  /// Map Phase 2 lesson IDs to file names
  /// Returns the asset path for a Phase 2 lesson
  String _getPhase2AssetPath(String lessonId) {
    final lessonFileMap = {
      // Unit 7 - Time & Place Language
      'phase2_lesson7_1': 'lesson7_1_time_prepositions.json',
      'phase2_lesson7_2': 'lesson7_2_place_prepositions.json',
      'phase2_lesson7_3': 'lesson7_3_time_expressions.json',

      // Unit 8 - Continuous Tenses
      'phase2_lesson8_1': 'lesson8_1_present_continuous.json',
      'phase2_lesson8_2': 'lesson8_2_past_continuous.json',
      'phase2_lesson8_3': 'lesson8_3_future_continuous.json',
      'phase2_lesson8_4': 'lesson8_4_continuous_conversations.json',

      // Unit 9 - Perfect & Perfect Continuous
      'phase2_lesson9_1': 'lesson9_1_present_perfect.json',
      'phase2_lesson9_2': 'lesson9_2_past_perfect.json',
      'phase2_lesson9_3': 'lesson9_3_future_perfect.json',
      'phase2_lesson9_4': 'lesson9_4_present_perfect_continuous.json',
      'phase2_lesson9_5': 'lesson9_5_perfect_vs_past.json',

      // Unit 10 - Questions & Negatives
      'phase2_lesson10_1': 'lesson10_1_be_questions.json',
      'phase2_lesson10_2': 'lesson10_2_do_does_did_questions.json',
      'phase2_lesson10_3': 'lesson10_3_wh_questions.json',
      'phase2_lesson10_4': 'lesson10_4_negatives.json',
      'phase2_lesson10_5': 'lesson10_5_real_qa.json',

      // Unit 11 - Advanced Pronouns, Adjectives & Adverbs
      'phase2_lesson11_1': 'lesson11_1_possessive_pronouns.json',
      'phase2_lesson11_2': 'lesson11_2_reflexive_pronouns.json',
      'phase2_lesson11_3': 'lesson11_3_demonstrative_pronouns.json',
      'phase2_lesson11_4': 'lesson11_4_adjectives.json',
      'phase2_lesson11_5': 'lesson11_5_adverbs.json',
    };

    final fileName = lessonFileMap[lessonId];
    if (fileName == null) {
      throw LessonLoadException('Unknown Phase 2 lesson: $lessonId');
    }

    return 'assets/lessons/phase2/$fileName';
  }

  /// Map Phase 3 lesson IDs to file names
  /// Returns the asset path for a Phase 3 lesson
  String _getPhase3AssetPath(String lessonId) {
    final lessonFileMap = {
      // Unit 12 - Story Listening & Retelling
      'phase3_lesson12_1': 'lesson12_1_story_listening.json',
      'phase3_lesson12_2': 'lesson12_2_story_qa.json',
      'phase3_lesson12_3': 'lesson12_3_story_retell.json',
      'phase3_lesson12_4': 'lesson12_4_story_tense_change.json',

      // Unit 13 - Complex Sentences & Connectors
      'phase3_lesson13_1': 'lesson13_1_connectors_and.json',
      'phase3_lesson13_2': 'lesson13_2_because_so.json',
      'phase3_lesson13_3': 'lesson13_3_when_while.json',
      'phase3_lesson13_4': 'lesson13_4_although_however.json',
      'phase3_lesson13_5': 'lesson13_5_paragraph_writing.json',

      // Unit 14 - Passive Voice
      'phase3_lesson14_1': 'lesson14_1_passive_present.json',
      'phase3_lesson14_2': 'lesson14_2_passive_past.json',
      'phase3_lesson14_3': 'lesson14_3_passive_perfect_future.json',
      'phase3_lesson14_4': 'lesson14_4_when_to_use_passive.json',

      // Unit 15 - Reported Speech
      'phase3_lesson15_1': 'lesson15_1_reported_statements.json',
      'phase3_lesson15_2': 'lesson15_2_reported_questions.json',
      'phase3_lesson15_3': 'lesson15_3_reported_commands.json',
      'phase3_lesson15_4': 'lesson15_4_dialogue_indirect.json',

      // Unit 16 - Functional English
      'phase3_lesson16_1': 'lesson16_1_introductions.json',
      'phase3_lesson16_2': 'lesson16_2_phone_calls.json',
      'phase3_lesson16_3': 'lesson16_3_help_clarify.json',
      'phase3_lesson16_4': 'lesson16_4_polite_requests.json',
      'phase3_lesson16_5': 'lesson16_5_complaints_apologies.json',

      // Unit 17 - Speaking & Writing Projects
      'phase3_lesson17_1': 'lesson17_1_daily_routine_project.json',
      'phase3_lesson17_2': 'lesson17_2_description_project.json',
      'phase3_lesson17_3': 'lesson17_3_opinion_writing.json',
      'phase3_lesson17_4': 'lesson17_4_mock_interview.json',
      'phase3_lesson17_5': 'lesson17_5_mini_presentation.json',
    };

    final fileName = lessonFileMap[lessonId];
    if (fileName == null) {
      throw LessonLoadException('Unknown Phase 3 lesson: $lessonId');
    }

    return 'assets/lessons/phase3/$fileName';
  }

  /// Load Phase 4 unit lessons
  /// Returns list of lessons for the specified Phase 4 unit
  Future<List<Lesson>> _loadPhase4UnitLessons(String unitId) async {
    final lessons = <Lesson>[];
    final lessonIds = _getPhase4LessonIds(unitId);

    for (final lessonId in lessonIds) {
      try {
        final validated = await loadLessonWithFallback(lessonId);
        lessons.add(validated.lesson);
      } catch (e) {
        // Log error but continue loading other lessons
        print('Warning: Failed to load $lessonId: $e');
      }
    }

    // Sort by order to ensure correct sequence
    lessons.sort((a, b) => a.order.compareTo(b.order));

    return lessons;
  }

  /// Get lesson IDs for a Phase 4 unit
  List<String> _getPhase4LessonIds(String unitId) {
    switch (unitId) {
      case 'phase4_unit18':
        return [
          'phase4_lesson18_1',
          'phase4_lesson18_2',
          'phase4_lesson18_3',
          'phase4_lesson18_4',
        ];
      case 'phase4_unit19':
        return [
          'phase4_lesson19_1',
          'phase4_lesson19_2',
          'phase4_lesson19_3',
          'phase4_lesson19_4',
        ];
      case 'phase4_unit20':
        return [
          'phase4_lesson20_1',
          'phase4_lesson20_2',
          'phase4_lesson20_3',
          'phase4_lesson20_4',
          'phase4_lesson20_5',
        ];
      case 'phase4_unit21':
        return [
          'phase4_lesson21_1',
          'phase4_lesson21_2',
          'phase4_lesson21_3',
          'phase4_lesson21_4',
        ];
      default:
        throw LessonLoadException('Unknown Phase 4 unit: $unitId');
    }
  }

  /// Map Phase 4 lesson IDs to file names
  /// Returns the asset path for a Phase 4 lesson
  String _getPhase4AssetPath(String lessonId) {
    final lessonFileMap = {
      // Unit 18 - Pronunciation & Sound
      'phase4_lesson18_1': 'lesson18_1_sounds_syllables.json',
      'phase4_lesson18_2': 'lesson18_2_word_stress.json',
      'phase4_lesson18_3': 'lesson18_3_sentence_stress.json',
      'phase4_lesson18_4': 'lesson18_4_pronunciation_problems.json',

      // Unit 19 - Fluency Techniques
      'phase4_lesson19_1': 'lesson19_1_keep_talking.json',
      'phase4_lesson19_2': 'lesson19_2_sentence_expansion.json',
      'phase4_lesson19_3': 'lesson19_3_paraphrasing.json',
      'phase4_lesson19_4': 'lesson19_4_hesitation_fillers.json',

      // Unit 20 - Real-Life Conversations
      'phase4_lesson20_1': 'lesson20_1_shopping.json',
      'phase4_lesson20_2': 'lesson20_2_restaurant.json',
      'phase4_lesson20_3': 'lesson20_3_travel_hotel.json',
      'phase4_lesson20_4': 'lesson20_4_workplace.json',
      'phase4_lesson20_5': 'lesson20_5_emergencies.json',

      // Unit 21 - Discussion & Opinion Skills
      'phase4_lesson21_1': 'lesson21_1_agree_disagree.json',
      'phase4_lesson21_2': 'lesson21_2_opinions_reasons.json',
      'phase4_lesson21_3': 'lesson21_3_follow_up_questions.json',
      'phase4_lesson21_4': 'lesson21_4_mini_discussion.json',
    };

    final fileName = lessonFileMap[lessonId];
    if (fileName == null) {
      throw LessonLoadException('Unknown Phase 4 lesson: $lessonId');
    }

    return 'assets/lessons/phase4/$fileName';
  }

  Future<List<Lesson>> _loadPhase5UnitLessons(String unitId) async {
    final lessons = <Lesson>[];
    final lessonIds = _getPhase5LessonIds(unitId);

    for (final lessonId in lessonIds) {
      try {
        final validated = await loadLessonWithFallback(lessonId);
        lessons.add(validated.lesson);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }

    lessons.sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }

  List<String> _getPhase5LessonIds(String unitId) {
    switch (unitId) {
      case 'phase5_unit22':
        return [
          'phase5_lesson22_1',
          'phase5_lesson22_2',
          'phase5_lesson22_3',
          'phase5_lesson22_4',
        ];
      case 'phase5_unit23':
        return [
          'phase5_lesson23_1',
          'phase5_lesson23_2',
          'phase5_lesson23_3',
          'phase5_lesson23_4',
        ];
      case 'phase5_unit24':
        return [
          'phase5_lesson24_1',
          'phase5_lesson24_2',
          'phase5_lesson24_3',
          'phase5_lesson24_4',
        ];
      case 'phase5_unit25':
        return [
          'phase5_lesson25_1',
          'phase5_lesson25_2',
          'phase5_lesson25_3',
          'phase5_lesson25_4',
        ];
      default:
        throw LessonLoadException('Unknown Phase 5 unit: $unitId');
    }
  }

  String _getPhase5AssetPath(String lessonId) {
    final lessonFileMap = {
      'phase5_lesson22_1': 'lesson22_1_professional_email.json',
      'phase5_lesson22_2': 'lesson22_2_formal_meetings.json',
      'phase5_lesson22_3': 'lesson22_3_negotiation_language.json',
      'phase5_lesson22_4': 'lesson22_4_register_shift.json',
      'phase5_lesson23_1': 'lesson23_1_interview_opening.json',
      'phase5_lesson23_2': 'lesson23_2_strengths_weaknesses.json',
      'phase5_lesson23_3': 'lesson23_3_behavioral_answers.json',
      'phase5_lesson23_4': 'lesson23_4_follow_up_questions.json',
      'phase5_lesson24_1': 'lesson24_1_presentation_opening.json',
      'phase5_lesson24_2': 'lesson24_2_signposting_transitions.json',
      'phase5_lesson24_3': 'lesson24_3_data_commentary.json',
      'phase5_lesson24_4': 'lesson24_4_qna_handling.json',
      'phase5_lesson25_1': 'lesson25_1_argument_essay.json',
      'phase5_lesson25_2': 'lesson25_2_synthesis_summary.json',
      'phase5_lesson25_3': 'lesson25_3_paraphrase_precision.json',
      'phase5_lesson25_4': 'lesson25_4_critical_response.json',
    };

    final fileName = lessonFileMap[lessonId];
    if (fileName == null) {
      throw LessonLoadException('Unknown Phase 5 lesson: $lessonId');
    }

    return 'assets/lessons/phase5/$fileName';
  }

  Future<ValidatedLesson> _loadAndValidatePrimaryLesson(String lessonId) async {
    final dynamicAssetPath = (await _getLessonAssetIndex())[lessonId];
    final assetPath = dynamicAssetPath ?? _getAssetPath(lessonId);
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    final schemaResult = _validator.validateSchema(jsonData);
    if (!schemaResult.isValid) {
      throw LessonSchemaException(
        'Invalid lesson schema for "$lessonId": ${schemaResult.errors.join(' ')}',
      );
    }

    final lesson = Lesson.fromJson(jsonData);
    final validation = _validator.validateForRuntime(jsonData, lesson);
    if (!validation.isValid) {
      throw LessonQualityException(
        'Lesson quality check failed for "$lessonId": ${validation.errors.join(' ')}',
      );
    }

    return ValidatedLesson(
      lesson: lesson,
      validation: validation,
      source: 'primary',
    );
  }

  Future<ValidatedLesson> _tryLoadFallbackLesson(
    String lessonId,
    LessonLoadException primaryError,
  ) async {
    final candidates = await _buildFallbackCandidates(lessonId);
    for (final candidate in candidates) {
      if (candidate == lessonId) continue;
      try {
        final validated = await _loadAndValidatePrimaryLesson(candidate);
        return ValidatedLesson(
          lesson: validated.lesson,
          validation: validated.validation,
          source: 'fallback',
          fallbackFromLessonId: lessonId,
        );
      } catch (_) {
        continue;
      }
    }
    throw LessonFallbackException(
      'No validated fallback found for "$lessonId". Root cause: ${primaryError.message}',
    );
  }

  Future<List<String>> _buildFallbackCandidates(String lessonId) async {
    final parts = lessonId.split('_');
    if (parts.isEmpty) return const [];
    final phasePrefix = parts.first;
    final phaseLessons = (await _getLessonAssetIndex()).keys
        .where((id) => id.startsWith('${phasePrefix}_'))
        .toList();
    final preferred = <String>[];
    final sameUnitPrefix = _extractUnitPrefix(lessonId);
    if (sameUnitPrefix != null) {
      preferred.addAll(
        phaseLessons.where(
          (id) => id.startsWith('${phasePrefix}_$sameUnitPrefix'),
        ),
      );
    }
    preferred.addAll(phaseLessons.where((id) => !preferred.contains(id)));
    return preferred;
  }

  String? _extractUnitPrefix(String lessonId) {
    final parts = lessonId.split('_');
    if (parts.length < 2) return null;
    final lessonToken = parts[1];
    final match = RegExp(r'lesson(\d+)').firstMatch(lessonToken);
    if (match == null) return null;
    return 'lesson${match.group(1)}';
  }

  List<String> get _allKnownLessonIds => const [
    'phase1_lesson1',
    'phase1_lesson2',
    'phase1_lesson3',
    'phase1_lesson4',
    'phase1_lesson5',
    'phase1_lesson6',
    'phase2_lesson7_1',
    'phase2_lesson7_2',
    'phase2_lesson7_3',
    'phase2_lesson8_1',
    'phase2_lesson8_2',
    'phase2_lesson8_3',
    'phase2_lesson8_4',
    'phase2_lesson9_1',
    'phase2_lesson9_2',
    'phase2_lesson9_3',
    'phase2_lesson9_4',
    'phase2_lesson9_5',
    'phase2_lesson10_1',
    'phase2_lesson10_2',
    'phase2_lesson10_3',
    'phase2_lesson10_4',
    'phase2_lesson10_5',
    'phase2_lesson11_1',
    'phase2_lesson11_2',
    'phase2_lesson11_3',
    'phase2_lesson11_4',
    'phase2_lesson11_5',
    'phase3_lesson12_1',
    'phase3_lesson12_2',
    'phase3_lesson12_3',
    'phase3_lesson12_4',
    'phase3_lesson13_1',
    'phase3_lesson13_2',
    'phase3_lesson13_3',
    'phase3_lesson13_4',
    'phase3_lesson13_5',
    'phase3_lesson14_1',
    'phase3_lesson14_2',
    'phase3_lesson14_3',
    'phase3_lesson14_4',
    'phase3_lesson15_1',
    'phase3_lesson15_2',
    'phase3_lesson15_3',
    'phase3_lesson15_4',
    'phase3_lesson16_1',
    'phase3_lesson16_2',
    'phase3_lesson16_3',
    'phase3_lesson16_4',
    'phase3_lesson16_5',
    'phase3_lesson17_1',
    'phase3_lesson17_2',
    'phase3_lesson17_3',
    'phase3_lesson17_4',
    'phase3_lesson17_5',
    'phase4_lesson18_1',
    'phase4_lesson18_2',
    'phase4_lesson18_3',
    'phase4_lesson18_4',
    'phase4_lesson19_1',
    'phase4_lesson19_2',
    'phase4_lesson19_3',
    'phase4_lesson19_4',
    'phase4_lesson20_1',
    'phase4_lesson20_2',
    'phase4_lesson20_3',
    'phase4_lesson20_4',
    'phase4_lesson20_5',
    'phase4_lesson21_1',
    'phase4_lesson21_2',
    'phase4_lesson21_3',
    'phase4_lesson21_4',
    'phase5_lesson22_1',
    'phase5_lesson22_2',
    'phase5_lesson22_3',
    'phase5_lesson22_4',
    'phase5_lesson23_1',
    'phase5_lesson23_2',
    'phase5_lesson23_3',
    'phase5_lesson23_4',
    'phase5_lesson24_1',
    'phase5_lesson24_2',
    'phase5_lesson24_3',
    'phase5_lesson24_4',
    'phase5_lesson25_1',
    'phase5_lesson25_2',
    'phase5_lesson25_3',
    'phase5_lesson25_4',
  ];

  bool _isFallbackAllowed() => _allowFallbackInProduction || kDebugMode;

  /// Clear the lesson cache
  /// Useful for memory management or testing
  void clearCache() {
    _lessonCache.clear();
    _validatedCache.clear();
    _assetPathByLessonIdCache = null;
  }

  /// Get cached lesson count
  int get cachedLessonCount => _lessonCache.length;

  /// Check if a lesson is cached
  bool isCached(String lessonId) => _lessonCache.containsKey(lessonId);
}

/// Custom exception for lesson loading errors
class LessonLoadException implements Exception {
  final String message;

  LessonLoadException(this.message);

  @override
  String toString() => 'LessonLoadException: $message';
}

class LessonSchemaException extends LessonLoadException {
  LessonSchemaException(super.message);
}

class LessonQualityException extends LessonLoadException {
  LessonQualityException(super.message);
}

class LessonFallbackException extends LessonLoadException {
  LessonFallbackException(super.message);
}
