import 'dart:math';

import '../data/models/lesson.dart';
import '../data/models/phase4_final_test_question.dart';
import '../data/models/phase4_test_result.dart';
import '../data/models/phase5_final_test_question.dart';
import '../data/models/phase5_test_result.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../../../services/local_storage/storage_service.dart';
import 'debug_service.dart';

abstract class _FinalTestServiceDelegate<Q, S, R> {
  int get totalQuestions;
  int get phaseNumber;
  String get phaseLabel;

  bool isMcq(Q question);
  bool isSpeakingTask(Q question);
  String questionId(Q question);
  S createEmptySpeakingResult(Q question);

  Future<bool> canTakeTest();
  Future<bool> hasPassedTest();
  Future<int?> getLastTestScore();
  Future<List<Q>> generateTest();
  R calculateResult({
    required List<Q> questions,
    required Map<String, int> mcqAnswers,
    required List<S> speakingResults,
  });
  Future<void> saveTestResult(R result);
}

class FinalTestService<Q, S, R> {
  final _FinalTestServiceDelegate<Q, S, R> _delegate;

  FinalTestService._(this._delegate);

  static FinalTestService<
    Phase4FinalTestQuestion,
    SpeakingResult,
    Phase4TestResult
  >
  phase4({
    required StorageService storageService,
    required ProgressRepository progressRepository,
    required DebugService debugService,
    LessonRepository? lessonRepository,
  }) {
    return FinalTestService._(
      Phase4FinalTestService(
        storageService: storageService,
        progressRepository: progressRepository,
        debugService: debugService,
        lessonRepository: lessonRepository,
      ),
    );
  }

  static FinalTestService<
    Phase5FinalTestQuestion,
    Phase5SpeakingResult,
    Phase5TestResult
  >
  phase5({
    required StorageService storageService,
    required ProgressRepository progressRepository,
    required DebugService debugService,
    LessonRepository? lessonRepository,
  }) {
    return FinalTestService._(
      Phase5FinalTestService(
        storageService: storageService,
        progressRepository: progressRepository,
        debugService: debugService,
        lessonRepository: lessonRepository,
      ),
    );
  }

  int get totalQuestions => _delegate.totalQuestions;
  int get phaseNumber => _delegate.phaseNumber;
  String get phaseLabel => _delegate.phaseLabel;

  bool isMcq(Q question) => _delegate.isMcq(question);
  bool isSpeakingTask(Q question) => _delegate.isSpeakingTask(question);
  String questionId(Q question) => _delegate.questionId(question);
  S createEmptySpeakingResult(Q question) =>
      _delegate.createEmptySpeakingResult(question);

  Future<bool> canTakeTest() => _delegate.canTakeTest();
  Future<bool> hasPassedTest() => _delegate.hasPassedTest();
  Future<int?> getLastTestScore() => _delegate.getLastTestScore();
  Future<List<Q>> generateTest() => _delegate.generateTest();
  R calculateResult({
    required List<Q> questions,
    required Map<String, int> mcqAnswers,
    required List<S> speakingResults,
  }) {
    return _delegate.calculateResult(
      questions: questions,
      mcqAnswers: mcqAnswers,
      speakingResults: speakingResults,
    );
  }

  Future<void> saveTestResult(R result) => _delegate.saveTestResult(result);
}

class Phase4FinalTestService
    implements
        _FinalTestServiceDelegate<
          Phase4FinalTestQuestion,
          SpeakingResult,
          Phase4TestResult
        > {
  final StorageService _storageService;
  final ProgressRepository _progressRepository;
  final DebugService _debugService;
  final LessonRepository _lessonRepository;

  // Storage keys for Phase 4 test data
  static const String keyTestPassed = 'phase4_final_test_passed';
  static const String keyTestScore = 'phase4_final_test_score';
  static const String keyPhase5Unlocked = 'phase5_unlocked';
  static const String keyTestResult = 'phase4_final_test_result';
  static const String keyTestDate = 'phase4_final_test_taken_at';

  // Question distribution constants
  static const int pronunciationCount = 6;
  static const int dialogueCount = 6;
  static const int listeningCount = 4;
  static const int speakingCount = 4;
  static const int totalQuestionCount = 20;

  // Scoring constants
  static const int passingScore = 18;
  static const int maxScore = 24;
  static const int maxMcqScore = 16; // 6 + 6 + 4 = 16 MCQs
  static const int maxSpeakingScore = 12; // 4 tasks × 3 points

  // Required lessons for test access (all Phase 4 lessons from Units 18-21)
  static const List<String> requiredLessonIds = [
    // Unit 18: Pronunciation & Sound (4 lessons)
    'phase4_lesson18_1',
    'phase4_lesson18_2',
    'phase4_lesson18_3',
    'phase4_lesson18_4',
    // Unit 19: Fluency Techniques (4 lessons)
    'phase4_lesson19_1',
    'phase4_lesson19_2',
    'phase4_lesson19_3',
    'phase4_lesson19_4',
    // Unit 20: Real-Life Conversations (5 lessons)
    'phase4_lesson20_1',
    'phase4_lesson20_2',
    'phase4_lesson20_3',
    'phase4_lesson20_4',
    'phase4_lesson20_5',
    // Unit 21: Discussion & Opinion Skills (4 lessons)
    'phase4_lesson21_1',
    'phase4_lesson21_2',
    'phase4_lesson21_3',
    'phase4_lesson21_4',
  ];

  @override
  int get totalQuestions => Phase4FinalTestService.totalQuestionCount;

  @override
  int get phaseNumber => 4;

  @override
  String get phaseLabel => 'Phase 4';

  @override
  bool isMcq(Phase4FinalTestQuestion question) => question.isMcq;

  @override
  bool isSpeakingTask(Phase4FinalTestQuestion question) =>
      question.isSpeakingTask;

  @override
  String questionId(Phase4FinalTestQuestion question) => question.id;

  @override
  SpeakingResult createEmptySpeakingResult(Phase4FinalTestQuestion question) {
    return SpeakingResult(
      taskId: question.id,
      prompt: question.prompt,
      recognizedText: null,
      wordCount: 0,
      score: 0,
      feedback: 'No speech recorded.',
    );
  }

  Phase4FinalTestService({
    required StorageService storageService,
    required ProgressRepository progressRepository,
    required DebugService debugService,
    LessonRepository? lessonRepository,
  }) : _storageService = storageService,
       _progressRepository = progressRepository,
       _debugService = debugService,
       _lessonRepository = lessonRepository ?? LessonRepository();

  /// Check if the user can take the Phase 4 Final Test
  ///
  /// Returns true if:
  /// - Debug mode is enabled (bypasses all checks), OR
  /// - All Phase 4 lessons (Units 18-21) are mastered
  ///
  /// Returns false on error to prevent test access when mastery cannot be verified
  Future<bool> canTakeTest() async {
    try {
      // Check if debug mode is enabled - bypasses all requirements
      final isDebugEnabled = await _debugService.isDebugModeEnabled();
      if (isDebugEnabled) {
        print('Debug mode enabled - Phase 4 Final Test access granted');
        return true;
      }

      // Check if all Phase 4 lessons are mastered
      return await areAllPhase4LessonsMastered();
    } catch (e) {
      print('Error: Failed to check test access: $e');
      // Return false to prevent test access when verification fails
      return false;
    }
  }

  /// Check if all required Phase 4 lessons are mastered
  /// Required before taking the final test
  ///
  /// Returns false on error to prevent test access when mastery cannot be verified
  Future<bool> areAllPhase4LessonsMastered() async {
    try {
      final allProgress = await _progressRepository.loadAllProgress();

      int masteredCount = 0;
      int totalRequired = requiredLessonIds.length;

      // Check if all required Phase 4 lessons are mastered
      for (final lessonId in requiredLessonIds) {
        final progress = allProgress[lessonId];

        // If lesson has no progress or is not mastered, return false
        if (progress == null || !progress.isMastered) {
          print('Lesson $lessonId is not mastered');
          return false;
        }

        masteredCount++;
      }

      print(
        'All required Phase 4 lessons mastered: $masteredCount/$totalRequired',
      );
      return true;
    } catch (e) {
      print('Error: Failed to check Phase 4 lesson mastery: $e');
      // Return false to prevent test access when verification fails
      return false;
    }
  }

  /// Check if student has passed the test
  Future<bool> hasPassedTest() async {
    try {
      return _storageService.getBool(keyTestPassed) ?? false;
    } catch (e) {
      print('Warning: Failed to check test pass status: $e');
      return false;
    }
  }

  /// Get the last test score
  /// Returns null if no test has been taken
  Future<int?> getLastTestScore() async {
    try {
      return _storageService.getInt(keyTestScore);
    } catch (e) {
      print('Warning: Failed to get last test score: $e');
      return null;
    }
  }

  /// Generate a Phase 4 Final Test with 20 questions
  ///
  /// Question distribution:
  /// - 6 Pronunciation MCQs from Unit 18 lessons
  /// - 6 Dialogue Response MCQs from Unit 20-21 lessons
  /// - 4 Listening MCQs from Phase 4 lessons
  /// - 4 Speaking Tasks from Unit 19 lessons
  ///
  /// Uses fallback hardcoded questions when lesson content is insufficient
  Future<List<Phase4FinalTestQuestion>> generateTest() async {
    final random = Random();
    final questions = <Phase4FinalTestQuestion>[];

    // Collect questions from lessons
    final pronunciationQuestions = <Phase4FinalTestQuestion>[];
    final dialogueQuestions = <Phase4FinalTestQuestion>[];
    final listeningQuestions = <Phase4FinalTestQuestion>[];
    final speakingPrompts = <Phase4FinalTestQuestion>[];

    try {
      // Load Unit 18 lessons for pronunciation questions
      await _loadUnit18Questions(pronunciationQuestions, listeningQuestions);

      // Load Unit 19 lessons for speaking prompts
      await _loadUnit19SpeakingPrompts(speakingPrompts);

      // Load Unit 20-21 lessons for dialogue questions
      await _loadUnit20And21Questions(dialogueQuestions, listeningQuestions);
    } catch (e) {
      print('Warning: Error loading lesson content: $e');
      // Continue with fallback questions
    }

    // Select pronunciation questions (6 needed)
    _selectQuestions(
      questions,
      pronunciationQuestions,
      pronunciationCount,
      _getFallbackPronunciationQuestions(),
      random,
    );

    // Select dialogue questions (6 needed)
    _selectQuestions(
      questions,
      dialogueQuestions,
      dialogueCount,
      _getFallbackDialogueQuestions(),
      random,
    );

    // Select listening questions (4 needed)
    _selectQuestions(
      questions,
      listeningQuestions,
      listeningCount,
      _getFallbackListeningQuestions(),
      random,
    );

    // Select speaking prompts (4 needed)
    _selectQuestions(
      questions,
      speakingPrompts,
      speakingCount,
      _getFallbackSpeakingPrompts(),
      random,
    );

    // Shuffle all questions for variety
    questions.shuffle(random);

    return questions;
  }

  /// Load Unit 18 lessons and extract pronunciation and listening questions
  Future<void> _loadUnit18Questions(
    List<Phase4FinalTestQuestion> pronunciationQuestions,
    List<Phase4FinalTestQuestion> listeningQuestions,
  ) async {
    final unit18LessonIds = [
      'phase4_lesson18_1',
      'phase4_lesson18_2',
      'phase4_lesson18_3',
      'phase4_lesson18_4',
    ];

    for (final lessonId in unit18LessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);

        // Extract pronunciation questions from practice and mastery questions
        _extractPronunciationQuestions(lesson, pronunciationQuestions);

        // Extract listening questions
        _extractListeningQuestions(lesson, listeningQuestions);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
  }

  /// Load Unit 19 lessons and extract speaking prompts
  Future<void> _loadUnit19SpeakingPrompts(
    List<Phase4FinalTestQuestion> speakingPrompts,
  ) async {
    final unit19LessonIds = [
      'phase4_lesson19_1',
      'phase4_lesson19_2',
      'phase4_lesson19_3',
      'phase4_lesson19_4',
    ];

    for (final lessonId in unit19LessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);

        // Extract speaking prompts from speakSentences
        _extractSpeakingPrompts(lesson, speakingPrompts);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
  }

  /// Load Unit 20-21 lessons and extract dialogue and listening questions
  Future<void> _loadUnit20And21Questions(
    List<Phase4FinalTestQuestion> dialogueQuestions,
    List<Phase4FinalTestQuestion> listeningQuestions,
  ) async {
    final unitLessonIds = [
      // Unit 20
      'phase4_lesson20_1',
      'phase4_lesson20_2',
      'phase4_lesson20_3',
      'phase4_lesson20_4',
      'phase4_lesson20_5',
      // Unit 21
      'phase4_lesson21_1',
      'phase4_lesson21_2',
      'phase4_lesson21_3',
      'phase4_lesson21_4',
    ];

    for (final lessonId in unitLessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);

        // Extract dialogue questions from practice and mastery questions
        _extractDialogueQuestions(lesson, dialogueQuestions);

        // Extract listening questions
        _extractListeningQuestions(lesson, listeningQuestions);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
  }

  /// Extract pronunciation questions from a lesson
  void _extractPronunciationQuestions(
    Lesson lesson,
    List<Phase4FinalTestQuestion> questions,
  ) {
    int questionIndex = 0;

    // Extract from practice questions
    for (final q in lesson.practiceQuestions) {
      questions.add(
        Phase4FinalTestQuestion.pronunciation(
          id: '${lesson.id}_pron_practice_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }

    // Extract from mastery questions
    for (final q in lesson.masteryQuestions) {
      questions.add(
        Phase4FinalTestQuestion.pronunciation(
          id: '${lesson.id}_pron_mastery_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }
  }

  /// Extract dialogue questions from a lesson
  void _extractDialogueQuestions(
    Lesson lesson,
    List<Phase4FinalTestQuestion> questions,
  ) {
    int questionIndex = 0;

    // Extract from practice questions
    for (final q in lesson.practiceQuestions) {
      questions.add(
        Phase4FinalTestQuestion.dialogue(
          id: '${lesson.id}_dial_practice_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }

    // Extract from mastery questions
    for (final q in lesson.masteryQuestions) {
      questions.add(
        Phase4FinalTestQuestion.dialogue(
          id: '${lesson.id}_dial_mastery_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }
  }

  /// Extract listening questions from a lesson
  void _extractListeningQuestions(
    Lesson lesson,
    List<Phase4FinalTestQuestion> questions,
  ) {
    int questionIndex = 0;

    for (final q in lesson.listeningQuestions) {
      questions.add(
        Phase4FinalTestQuestion.listening(
          id: '${lesson.id}_listen_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: 'Based on the dialogue, answer the question:',
          options: q.options,
          correctIndex: q.correctIndex,
          audioText: q.audioText,
        ),
      );
      questionIndex++;
    }
  }

  /// Extract speaking prompts from a lesson
  void _extractSpeakingPrompts(
    Lesson lesson,
    List<Phase4FinalTestQuestion> prompts,
  ) {
    int promptIndex = 0;

    // Create speaking prompts from speakSentences
    // Group sentences into speaking tasks
    for (final s in lesson.speakSentences) {
      prompts.add(
        Phase4FinalTestQuestion.speaking(
          id: '${lesson.id}_speak_$promptIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: 'Speak about this topic in 3-4 sentences: ${s.en}',
        ),
      );
      promptIndex++;
    }
  }

  /// Select questions from available pool, using fallback if needed
  void _selectQuestions(
    List<Phase4FinalTestQuestion> target,
    List<Phase4FinalTestQuestion> available,
    int count,
    List<Phase4FinalTestQuestion> fallback,
    Random random,
  ) {
    // Shuffle available questions
    available.shuffle(random);

    // Take up to 'count' questions from available
    final selected = available.take(count).toList();

    // If not enough, add from fallback
    if (selected.length < count) {
      final needed = count - selected.length;
      fallback.shuffle(random);
      selected.addAll(fallback.take(needed));
    }

    target.addAll(selected);
  }

  /// Fallback pronunciation questions when lesson content is insufficient
  List<Phase4FinalTestQuestion> _getFallbackPronunciationQuestions() {
    return [
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_1',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'How many syllables does "beautiful" have?',
        options: ['2', '3', '4'],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_2',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'Which word has the stress on the first syllable?',
        options: ['beLIEVE', 'HAPpy', 'aGREE'],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_3',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'How many syllables does "computer" have?',
        options: ['2', '3', '4'],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_4',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'Which sentence has correct stress?',
        options: [
          'I WANT to GO to the STORE.',
          'i want to go to the store.',
          'I want TO go TO the store.',
        ],
        correctIndex: 0,
      ),
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_5',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'Which word has 1 syllable?',
        options: ['water', 'book', 'happy'],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_6',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'How many vowel sounds are there in English?',
        options: ['5', '20', '24'],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_7',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'Which word has the stress on the second syllable?',
        options: ['TAble', 'comPUter', 'HAPpy'],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.pronunciation(
        id: 'fallback_pron_8',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'How many syllables does "university" have?',
        options: ['3', '4', '5'],
        correctIndex: 2,
      ),
    ];
  }

  /// Fallback dialogue questions when lesson content is insufficient
  List<Phase4FinalTestQuestion> _getFallbackDialogueQuestions() {
    return [
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_1',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'Shopkeeper: "Can I help you?" You say:',
        options: [
          'Yes, I\'m looking for a blue shirt.',
          'No, go away.',
          'Maybe tomorrow.',
        ],
        correctIndex: 0,
      ),
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_2',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'Waiter: "Would you like anything else?" You say:',
        options: [
          'I don\'t know you.',
          'No, thank you. Just the bill, please.',
          'Yes, I want everything.',
        ],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_3',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'Receptionist: "Do you have a reservation?" You say:',
        options: [
          'What is a reservation?',
          'Yes, under the name Smith.',
          'No, I don\'t like hotels.',
        ],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_4',
        unitId: 'phase4_unit21',
        lessonId: 'fallback',
        prompt: 'Friend: "What do you think about this movie?" You say:',
        options: [
          'I think it was really interesting.',
          'I don\'t think.',
          'Movies are movies.',
        ],
        correctIndex: 0,
      ),
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_5',
        unitId: 'phase4_unit21',
        lessonId: 'fallback',
        prompt: 'Colleague: "I believe we should start earlier." You say:',
        options: [
          'I don\'t care.',
          'I agree. That would give us more time.',
          'Believe what you want.',
        ],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_6',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'How do you ask for the price of something?',
        options: ['What is this?', 'How much is this?', 'Where is this?'],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_7',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'How do you politely ask for a discount?',
        options: [
          'Give me free!',
          'Can you give me a discount?',
          'I want more.',
        ],
        correctIndex: 1,
      ),
      Phase4FinalTestQuestion.dialogue(
        id: 'fallback_dial_8',
        unitId: 'phase4_unit21',
        lessonId: 'fallback',
        prompt: 'How do you express disagreement politely?',
        options: [
          'You\'re wrong!',
          'I see your point, but I think differently.',
          'That\'s stupid.',
        ],
        correctIndex: 1,
      ),
    ];
  }

  /// Fallback listening questions when lesson content is insufficient
  List<Phase4FinalTestQuestion> _getFallbackListeningQuestions() {
    return [
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_1',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'What does the customer want?',
        options: [
          'The customer wants to return an item.',
          'The customer wants to buy a shirt.',
          'The customer wants to leave.',
        ],
        correctIndex: 1,
        audioText:
            'Customer: "Excuse me, how much is this blue shirt?" Shopkeeper: "That one is 800 rupees."',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_2',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'Where is the fitting room?',
        options: ['On the left', 'On the right', 'Upstairs'],
        correctIndex: 1,
        audioText:
            'Customer: "Can I try this on?" Shopkeeper: "Of course. The fitting room is on your right."',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_3',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'What is the speaker\'s hobby?',
        options: [
          'The speaker likes cooking.',
          'The speaker likes reading.',
          'The speaker likes swimming.',
        ],
        correctIndex: 1,
        audioText:
            'I like reading books. I read every day. My favorite books are novels.',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_4',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'What payment methods does the shop accept?',
        options: ['Only cash', 'Cards and UPI', 'Only credit cards'],
        correctIndex: 1,
        audioText:
            'Customer: "Can I pay by card?" Shopkeeper: "Yes, we accept cards and UPI."',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_5',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'How many syllables does "happy" have?',
        options: ['1 syllable', '2 syllables', '3 syllables'],
        correctIndex: 1,
        audioText: 'The word "happy" has two syllables: hap-py.',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_6',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'What helps you speak more fluently?',
        options: [
          'Using complex words',
          'Using connecting words',
          'Speaking very fast',
        ],
        correctIndex: 1,
        audioText:
            'To speak fluently, use connecting words like "and", "but", "so", and "because".',
      ),
    ];
  }

  /// Fallback speaking prompts when lesson content is insufficient
  List<Phase4FinalTestQuestion> _getFallbackSpeakingPrompts() {
    return [
      Phase4FinalTestQuestion.speaking(
        id: 'fallback_speak_1',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'Describe your daily routine in 3-4 sentences.',
      ),
      Phase4FinalTestQuestion.speaking(
        id: 'fallback_speak_2',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'Talk about your favorite hobby and why you enjoy it.',
      ),
      Phase4FinalTestQuestion.speaking(
        id: 'fallback_speak_3',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'Describe your last shopping experience.',
      ),
      Phase4FinalTestQuestion.speaking(
        id: 'fallback_speak_4',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'Talk about a place you would like to visit and why.',
      ),
      Phase4FinalTestQuestion.speaking(
        id: 'fallback_speak_5',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'Describe your family in 3-4 sentences.',
      ),
      Phase4FinalTestQuestion.speaking(
        id: 'fallback_speak_6',
        unitId: 'phase4_unit19',
        lessonId: 'fallback',
        prompt: 'Talk about what you like to do on weekends.',
      ),
    ];
  }

  /// Validate an MCQ answer by comparing selected index with correct index
  ///
  /// Returns true if the selected answer matches the correct answer, false otherwise.
  /// For speaking tasks (which have null correctIndex), always returns false.
  ///
  /// Requirements: 2.3, 3.3, 4.3
  bool validateMcqAnswer(Phase4FinalTestQuestion question, int selectedIndex) {
    // Speaking tasks don't have a correct index - they're scored differently
    if (question.correctIndex == null) {
      return false;
    }

    // Compare selected index with correct index
    return selectedIndex == question.correctIndex;
  }

  /// Score a speaking task based on word count in recognized text
  ///
  /// Scoring tiers:
  /// - 3 points: 20+ words (good fluency, clear recognition)
  /// - 2 points: 10-19 words (okay but short)
  /// - 1 point: 1-9 words (very short)
  /// - 0 points: 0 words (no output)
  ///
  /// Returns a SpeakingScoreResult with score and feedback message.
  ///
  /// Requirements: 5.3, 5.4, 5.5
  SpeakingScoreResult scoreSpeakingTask(String? recognizedText) {
    // Handle null or empty text
    if (recognizedText == null || recognizedText.trim().isEmpty) {
      return SpeakingScoreResult(
        score: 0,
        wordCount: 0,
        feedback: 'No speech detected. Please try again.',
      );
    }

    // Count words by splitting on whitespace
    final words = recognizedText.trim().split(RegExp(r'\s+'));
    final wordCount = words.where((w) => w.isNotEmpty).length;

    // Determine score based on word count tiers
    int score;
    String feedback;

    if (wordCount >= 20) {
      score = 3;
      feedback = 'Great fluency! Clear and natural speech.';
    } else if (wordCount >= 10) {
      score = 2;
      feedback = 'Good effort! Try to expand your response.';
    } else if (wordCount >= 1) {
      score = 1;
      feedback = 'Keep practicing! Try to speak more.';
    } else {
      score = 0;
      feedback = 'No speech detected. Please try again.';
    }

    return SpeakingScoreResult(
      score: score,
      wordCount: wordCount,
      feedback: feedback,
    );
  }

  /// Calculate the final test result from questions and answers
  ///
  /// Parameters:
  /// - questions: List of all 20 test questions
  /// - mcqAnswers: Map of question ID to selected answer index (for MCQ questions)
  /// - speakingResults: List of SpeakingResult for speaking tasks
  ///
  /// Returns a Phase4TestResult with:
  /// - Total score (MCQ correct + speaking scores)
  /// - Percentage (totalScore / 24 * 100)
  /// - Pass/fail status (>= 18 points to pass)
  /// - List of incorrect MCQ answers for review
  ///
  /// Requirements: 6.1, 6.2, 6.3, 7.1
  Phase4TestResult calculateResult({
    required List<Phase4FinalTestQuestion> questions,
    required Map<String, int> mcqAnswers,
    required List<SpeakingResult> speakingResults,
  }) {
    int mcqCorrect = 0;
    int speakingScore = 0;
    final incorrectMcqAnswers = <Phase4IncorrectAnswer>[];

    // Process each question
    for (final question in questions) {
      if (question.isMcq) {
        // MCQ question - check if answer is correct
        final selectedIndex = mcqAnswers[question.id];

        if (selectedIndex != null && question.correctIndex != null) {
          if (selectedIndex == question.correctIndex) {
            // Correct answer - add 1 point
            mcqCorrect++;
          } else {
            // Incorrect answer - add to review list
            incorrectMcqAnswers.add(
              Phase4IncorrectAnswer(
                question: question,
                selectedIndex: selectedIndex,
                selectedAnswer: question.options![selectedIndex],
                correctAnswer: question.options![question.correctIndex!],
              ),
            );
          }
        } else if (selectedIndex == null && question.correctIndex != null) {
          // Question was skipped - treat as incorrect
          incorrectMcqAnswers.add(
            Phase4IncorrectAnswer(
              question: question,
              selectedIndex: -1, // Indicates skipped
              selectedAnswer: 'Skipped',
              correctAnswer: question.options![question.correctIndex!],
            ),
          );
        }
      }
    }

    // Sum speaking scores (0-3 each, max 12 total)
    for (final result in speakingResults) {
      speakingScore += result.score;
    }

    // Create and return the result using the factory constructor
    return Phase4TestResult.calculate(
      mcqCorrect: mcqCorrect,
      speakingScore: speakingScore,
      completedAt: DateTime.now(),
      incorrectMcqAnswers: incorrectMcqAnswers,
      speakingResults: speakingResults,
    );
  }

  /// Save the test result to persistent storage
  ///
  /// Persists:
  /// - phase4FinalTestPassed: true if passed, false otherwise
  /// - phase4FinalTestScore: the total score achieved
  /// - phase5Unlocked: true if test was passed (unlocks Phase 5)
  /// - phase4FinalTestResult: full result JSON for later retrieval
  /// - phase4FinalTestTakenAt: timestamp of when test was completed
  ///
  /// Requirements: 8.1, 8.2, 8.3
  Future<void> saveTestResult(Phase4TestResult result) async {
    try {
      // Save pass/fail status
      await _storageService.setBool(keyTestPassed, result.passed);

      // Save the total score
      await _storageService.setInt(keyTestScore, result.totalScore);

      // If passed, unlock Phase 5
      if (result.passed) {
        await _storageService.setBool(keyPhase5Unlocked, true);
        print(
          'Phase 5 unlocked! Test passed with score: ${result.totalScore}/${result.maxScore}',
        );
      } else {
        print(
          'Test not passed. Score: ${result.totalScore}/${result.maxScore} (need $passingScore to pass)',
        );
      }

      // Save the full result JSON for later retrieval
      final resultJson = result.toJson();
      await _storageService.setString(keyTestResult, resultJson.toString());

      // Save the completion timestamp
      await _storageService.setString(
        keyTestDate,
        result.completedAt.toIso8601String(),
      );

      print('Phase 4 Final Test result saved successfully');
    } catch (e) {
      print('Error: Failed to save test result: $e');
      rethrow;
    }
  }

  /// Check if Phase 5 is unlocked
  ///
  /// Returns true if and only if phase4FinalTestPassed is true in storage.
  ///
  /// Requirements: 8.4
  Future<bool> isPhase5Unlocked() async {
    try {
      // Phase 5 is unlocked only if the Phase 4 Final Test was passed
      return _storageService.getBool(keyTestPassed) ?? false;
    } catch (e) {
      print('Warning: Failed to check Phase 5 unlock status: $e');
      return false;
    }
  }

  /// Get incorrect MCQ answers from a test result for review
  ///
  /// Filters out speaking tasks from the incorrect answers list.
  /// Returns only MCQ questions (pronunciation, dialogue, listening) where
  /// the user selected an incorrect answer.
  ///
  /// This method is used by the review screen to display only reviewable
  /// mistakes - speaking tasks are excluded as they cannot be reviewed
  /// in the same way as MCQs.
  ///
  /// Requirements: 7.1, 7.3
  List<Phase4IncorrectAnswer> getIncorrectMcqAnswers(Phase4TestResult result) {
    // The incorrectMcqAnswers list in Phase4TestResult already contains
    // only MCQ questions (speaking tasks are never added to this list
    // in calculateResult). However, we add an explicit filter here for
    // safety and to satisfy the requirement that speaking tasks are excluded.
    return result.incorrectMcqAnswers
        .where((answer) => answer.question.isMcq)
        .toList();
  }
}

/// Result of scoring a speaking task
class SpeakingScoreResult {
  final int score;
  final int wordCount;
  final String feedback;

  const SpeakingScoreResult({
    required this.score,
    required this.wordCount,
    required this.feedback,
  });
}

class Phase5FinalTestService
    implements
        _FinalTestServiceDelegate<
          Phase5FinalTestQuestion,
          Phase5SpeakingResult,
          Phase5TestResult
        > {
  final StorageService _storageService;
  final ProgressRepository _progressRepository;
  final DebugService _debugService;
  final LessonRepository _lessonRepository;

  // Storage keys for Phase 5 test data
  static const String keyTestPassed = 'phase5_final_test_passed';
  static const String keyTestScore = 'phase5_final_test_score';
  static const String keyTestDate = 'phase5_final_test_date';
  static const String keyMasteryCompleted = 'english_mastery_completed';
  static const String keyTestResult = 'phase5_final_test_result';

  // Question distribution constants
  static const int businessEnglishCount = 8;
  static const int interviewCount = 7;
  static const int presentationCount = 6;
  static const int writingCount = 6;
  static const int speakingCount = 8;
  static const int totalQuestionCount = 35;

  // Scoring constants
  static const int passingScore = 42;
  static const int maxScore = 60;
  static const int maxMcqScore = 27; // 8 + 7 + 6 + 6 = 27 MCQs
  static const int maxSpeakingScore = 32; // 8 tasks × 4 points

  // Required lessons for test access (all Phase 5 lessons from Units 22-25)
  static const List<String> requiredLessonIds = [
    // Unit 22: Business Communication (4 lessons)
    'phase5_lesson22_1',
    'phase5_lesson22_2',
    'phase5_lesson22_3',
    'phase5_lesson22_4',
    // Unit 23: Interview English (4 lessons)
    'phase5_lesson23_1',
    'phase5_lesson23_2',
    'phase5_lesson23_3',
    'phase5_lesson23_4',
    // Unit 24: Presentation Skills (4 lessons)
    'phase5_lesson24_1',
    'phase5_lesson24_2',
    'phase5_lesson24_3',
    'phase5_lesson24_4',
    // Unit 25: Advanced Writing (4 lessons)
    'phase5_lesson25_1',
    'phase5_lesson25_2',
    'phase5_lesson25_3',
    'phase5_lesson25_4',
  ];

  @override
  int get totalQuestions => Phase5FinalTestService.totalQuestionCount;

  @override
  int get phaseNumber => 5;

  @override
  String get phaseLabel => 'Phase 5';

  @override
  bool isMcq(Phase5FinalTestQuestion question) => question.isMcq;

  @override
  bool isSpeakingTask(Phase5FinalTestQuestion question) =>
      question.isSpeakingTask;

  @override
  String questionId(Phase5FinalTestQuestion question) => question.id;

  @override
  Phase5SpeakingResult createEmptySpeakingResult(
    Phase5FinalTestQuestion question,
  ) {
    return Phase5SpeakingResult(
      taskId: question.id,
      prompt: question.prompt,
      recognizedText: null,
      wordCount: 0,
      score: 0,
      feedback: 'No speech recorded.',
    );
  }

  Phase5FinalTestService({
    required StorageService storageService,
    required ProgressRepository progressRepository,
    required DebugService debugService,
    LessonRepository? lessonRepository,
  }) : _storageService = storageService,
       _progressRepository = progressRepository,
       _debugService = debugService,
       _lessonRepository = lessonRepository ?? LessonRepository();

  /// Check if the user can take the Phase 5 Final Test
  ///
  /// Returns true if:
  /// - Debug mode is enabled (bypasses all checks), OR
  /// - All Phase 5 lessons (Units 22-25) are mastered
  ///
  /// Returns false on error to prevent test access when mastery cannot be verified
  Future<bool> canTakeTest() async {
    try {
      // Check if debug mode is enabled - bypasses all requirements
      final isDebugEnabled = await _debugService.isDebugModeEnabled();
      if (isDebugEnabled) {
        print('Debug mode enabled - Phase 5 Final Test access granted');
        return true;
      }

      // Check if all Phase 5 lessons are mastered
      return await areAllPhase5LessonsMastered();
    } catch (e) {
      print('Error: Failed to check test access: $e');
      // Return false to prevent test access when verification fails
      return false;
    }
  }

  /// Check if all required Phase 5 lessons are mastered
  /// Required before taking the final test
  ///
  /// Returns false on error to prevent test access when mastery cannot be verified
  Future<bool> areAllPhase5LessonsMastered() async {
    try {
      final allProgress = await _progressRepository.loadAllProgress();

      int masteredCount = 0;
      int totalRequired = requiredLessonIds.length;

      // Check if all required Phase 5 lessons are mastered
      for (final lessonId in requiredLessonIds) {
        final progress = allProgress[lessonId];

        // If lesson has no progress or is not mastered, return false
        if (progress == null || !progress.isMastered) {
          print('Lesson $lessonId is not mastered');
          return false;
        }

        masteredCount++;
      }

      print(
        'All required Phase 5 lessons mastered: $masteredCount/$totalRequired',
      );
      return true;
    } catch (e) {
      print('Error: Failed to check Phase 5 lesson mastery: $e');
      // Return false to prevent test access when verification fails
      return false;
    }
  }

  /// Check if student has passed the test
  Future<bool> hasPassedTest() async {
    try {
      return _storageService.getBool(keyTestPassed) ?? false;
    } catch (e) {
      print('Warning: Failed to check test pass status: $e');
      return false;
    }
  }

  /// Check if English Mastery is completed
  Future<bool> isEnglishMasteryCompleted() async {
    try {
      return _storageService.getBool(keyMasteryCompleted) ?? false;
    } catch (e) {
      print('Warning: Failed to check English mastery status: $e');
      return false;
    }
  }

  /// Get the last test score
  /// Returns null if no test has been taken
  Future<int?> getLastTestScore() async {
    try {
      return _storageService.getInt(keyTestScore);
    } catch (e) {
      print('Warning: Failed to get last test score: $e');
      return null;
    }
  }

  /// Get the last test date
  /// Returns null if no test has been taken
  Future<DateTime?> getLastTestDate() async {
    try {
      final dateStr = _storageService.getString(keyTestDate);
      if (dateStr != null) {
        return DateTime.parse(dateStr);
      }
      return null;
    } catch (e) {
      print('Warning: Failed to get last test date: $e');
      return null;
    }
  }

  /// Generate a Phase 5 Final Test with 35 tasks
  ///
  /// Question distribution:
  /// - 8 Business English MCQs from Unit 22 lessons
  /// - 7 Interview Response MCQs from Unit 23 lessons
  /// - 6 Presentation Language MCQs from Unit 24 lessons
  /// - 6 Writing Logic MCQs from Unit 25 lessons
  /// - 8 Professional Speaking Tasks from all Phase 5 lessons
  ///
  /// Uses fallback hardcoded questions when lesson content is insufficient
  Future<List<Phase5FinalTestQuestion>> generateTest() async {
    final random = Random();
    final questions = <Phase5FinalTestQuestion>[];

    // Collect questions from lessons
    final businessQuestions = <Phase5FinalTestQuestion>[];
    final interviewQuestions = <Phase5FinalTestQuestion>[];
    final presentationQuestions = <Phase5FinalTestQuestion>[];
    final writingQuestions = <Phase5FinalTestQuestion>[];
    final speakingPrompts = <Phase5FinalTestQuestion>[];

    try {
      // Load Unit 22 lessons for business English questions
      await _loadUnit22Questions(businessQuestions, speakingPrompts);

      // Load Unit 23 lessons for interview questions
      await _loadUnit23Questions(interviewQuestions, speakingPrompts);

      // Load Unit 24 lessons for presentation questions
      await _loadUnit24Questions(presentationQuestions, speakingPrompts);

      // Load Unit 25 lessons for writing questions and speaking prompts
      await _loadUnit25Questions(writingQuestions, speakingPrompts);
    } catch (e) {
      print('Warning: Error loading lesson content: $e');
      // Continue with fallback questions
    }

    // Select business English questions (8 needed)
    _selectQuestions(
      questions,
      businessQuestions,
      businessEnglishCount,
      _getFallbackBusinessEnglishQuestions(),
      random,
    );

    // Select interview questions (7 needed)
    _selectQuestions(
      questions,
      interviewQuestions,
      interviewCount,
      _getFallbackInterviewQuestions(),
      random,
    );

    // Select presentation questions (6 needed)
    _selectQuestions(
      questions,
      presentationQuestions,
      presentationCount,
      _getFallbackPresentationQuestions(),
      random,
    );

    // Select writing questions (6 needed)
    _selectQuestions(
      questions,
      writingQuestions,
      writingCount,
      _getFallbackWritingQuestions(),
      random,
    );

    // Select speaking prompts (8 needed)
    _selectQuestions(
      questions,
      speakingPrompts,
      speakingCount,
      _getFallbackSpeakingPrompts(),
      random,
    );

    // Shuffle all questions for variety
    questions.shuffle(random);

    return questions;
  }

  /// Load Unit 22 lessons and extract business English questions
  Future<void> _loadUnit22Questions(
    List<Phase5FinalTestQuestion> businessQuestions,
    List<Phase5FinalTestQuestion> speakingPrompts,
  ) async {
    final unit22LessonIds = [
      'phase5_lesson22_1',
      'phase5_lesson22_2',
      'phase5_lesson22_3',
      'phase5_lesson22_4',
    ];

    for (final lessonId in unit22LessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);
        _extractBusinessEnglishQuestions(lesson, businessQuestions);
        _extractSpeakingPrompts(lesson, speakingPrompts);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
  }

  /// Load Unit 23 lessons and extract interview questions
  Future<void> _loadUnit23Questions(
    List<Phase5FinalTestQuestion> interviewQuestions,
    List<Phase5FinalTestQuestion> speakingPrompts,
  ) async {
    final unit23LessonIds = [
      'phase5_lesson23_1',
      'phase5_lesson23_2',
      'phase5_lesson23_3',
      'phase5_lesson23_4',
    ];

    for (final lessonId in unit23LessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);
        _extractInterviewQuestions(lesson, interviewQuestions);
        _extractSpeakingPrompts(lesson, speakingPrompts);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
  }

  /// Load Unit 24 lessons and extract presentation questions
  Future<void> _loadUnit24Questions(
    List<Phase5FinalTestQuestion> presentationQuestions,
    List<Phase5FinalTestQuestion> speakingPrompts,
  ) async {
    final unit24LessonIds = [
      'phase5_lesson24_1',
      'phase5_lesson24_2',
      'phase5_lesson24_3',
      'phase5_lesson24_4',
    ];

    for (final lessonId in unit24LessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);
        _extractPresentationQuestions(lesson, presentationQuestions);
        _extractSpeakingPrompts(lesson, speakingPrompts);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
  }

  /// Load Unit 25 lessons and extract writing questions and speaking prompts
  Future<void> _loadUnit25Questions(
    List<Phase5FinalTestQuestion> writingQuestions,
    List<Phase5FinalTestQuestion> speakingPrompts,
  ) async {
    final unit25LessonIds = [
      'phase5_lesson25_1',
      'phase5_lesson25_2',
      'phase5_lesson25_3',
      'phase5_lesson25_4',
    ];

    for (final lessonId in unit25LessonIds) {
      try {
        final lesson = await _lessonRepository.loadLesson(lessonId);
        _extractWritingQuestions(lesson, writingQuestions);
        _extractSpeakingPrompts(lesson, speakingPrompts);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
  }

  /// Extract business English questions from a lesson
  void _extractBusinessEnglishQuestions(
    Lesson lesson,
    List<Phase5FinalTestQuestion> questions,
  ) {
    int questionIndex = 0;

    // Extract from practice questions
    for (final q in lesson.practiceQuestions) {
      questions.add(
        Phase5FinalTestQuestion.businessEnglish(
          id: '${lesson.id}_business_practice_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }

    // Extract from mastery questions
    for (final q in lesson.masteryQuestions) {
      questions.add(
        Phase5FinalTestQuestion.businessEnglish(
          id: '${lesson.id}_business_mastery_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }
  }

  /// Extract interview questions from a lesson
  void _extractInterviewQuestions(
    Lesson lesson,
    List<Phase5FinalTestQuestion> questions,
  ) {
    int questionIndex = 0;

    for (final q in lesson.practiceQuestions) {
      questions.add(
        Phase5FinalTestQuestion.interview(
          id: '${lesson.id}_interview_practice_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }

    for (final q in lesson.masteryQuestions) {
      questions.add(
        Phase5FinalTestQuestion.interview(
          id: '${lesson.id}_interview_mastery_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }
  }

  /// Extract presentation questions from a lesson
  void _extractPresentationQuestions(
    Lesson lesson,
    List<Phase5FinalTestQuestion> questions,
  ) {
    int questionIndex = 0;

    for (final q in lesson.practiceQuestions) {
      questions.add(
        Phase5FinalTestQuestion.presentation(
          id: '${lesson.id}_presentation_practice_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }

    for (final q in lesson.masteryQuestions) {
      questions.add(
        Phase5FinalTestQuestion.presentation(
          id: '${lesson.id}_presentation_mastery_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }
  }

  /// Extract writing questions from a lesson
  void _extractWritingQuestions(
    Lesson lesson,
    List<Phase5FinalTestQuestion> questions,
  ) {
    int questionIndex = 0;

    for (final q in lesson.practiceQuestions) {
      questions.add(
        Phase5FinalTestQuestion.writing(
          id: '${lesson.id}_writing_practice_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }

    for (final q in lesson.masteryQuestions) {
      questions.add(
        Phase5FinalTestQuestion.writing(
          id: '${lesson.id}_writing_mastery_$questionIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: q.promptEn,
          options: q.options,
          correctIndex: q.correctIndex,
        ),
      );
      questionIndex++;
    }
  }

  /// Extract speaking prompts from a lesson
  void _extractSpeakingPrompts(
    Lesson lesson,
    List<Phase5FinalTestQuestion> prompts,
  ) {
    int promptIndex = 0;

    for (final s in lesson.speakSentences) {
      prompts.add(
        Phase5FinalTestQuestion.speakingRubricScored(
          id: '${lesson.id}_speak_$promptIndex',
          unitId: lesson.unitId,
          lessonId: lesson.id,
          prompt: s.en,
        ),
      );
      promptIndex++;
    }
  }

  /// Select questions from available pool, using fallback if needed
  void _selectQuestions(
    List<Phase5FinalTestQuestion> target,
    List<Phase5FinalTestQuestion> available,
    int count,
    List<Phase5FinalTestQuestion> fallback,
    Random random,
  ) {
    // Shuffle available questions
    available.shuffle(random);

    // Take up to 'count' questions from available
    final selected = available.take(count).toList();

    // If not enough, add from fallback
    if (selected.length < count) {
      final needed = count - selected.length;
      fallback.shuffle(random);
      selected.addAll(fallback.take(needed));
    }

    target.addAll(selected);
  }

  /// Fallback business English questions when lesson content is insufficient
  List<Phase5FinalTestQuestion> _getFallbackBusinessEnglishQuestions() {
    return [
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_1',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt: 'Choose the most professional sentence for a business email:',
        options: [
          'Send me the files ASAP.',
          'Please send the files quickly.',
          'Kindly send the files at your earliest convenience.',
          'I need the files now.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_2',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt: 'Which is the most appropriate way to start a formal email?',
        options: ['Hey there!', 'Dear Mr. Johnson,', 'Hi buddy,', 'Yo!'],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_3',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt: 'Select the most professional closing for a business email:',
        options: ['Later!', 'See ya!', 'Best regards,', 'Bye bye!'],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_4',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt: 'How should you politely decline a meeting request?',
        options: [
          'No, I can\'t come.',
          'I\'m busy, forget it.',
          'Unfortunately, I have a prior commitment. Could we reschedule?',
          'Not interested.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_5',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt: 'Which phrase is most appropriate for requesting information?',
        options: [
          'Tell me about the project.',
          'I want to know everything.',
          'Could you please provide more details about the project?',
          'Give me the info.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_6',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt: 'How do you professionally acknowledge receipt of an email?',
        options: [
          'Got it.',
          'Thank you for your email. I will review and respond shortly.',
          'OK.',
          'Received.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_7',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt:
            'Which is the best way to introduce yourself in a business meeting?',
        options: [
          'I\'m John.',
          'Hello, I\'m John Smith from the Marketing Department.',
          'Hey, call me John.',
          'John here.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_8',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt:
            'How should you professionally follow up on an unanswered email?',
        options: [
          'Why haven\'t you replied?',
          'Hello? Anyone there?',
          'I wanted to follow up on my previous email regarding the project proposal.',
          'Answer me!',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_9',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt:
            'Which phrase is best for expressing disagreement professionally?',
        options: [
          'You\'re wrong.',
          'That\'s stupid.',
          'I see your point, however, I have a different perspective.',
          'No way!',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.businessEnglish(
        id: 'fallback_business_10',
        unitId: 'phase5_unit22',
        lessonId: 'fallback',
        prompt: 'How do you professionally ask for a deadline extension?',
        options: [
          'I need more time.',
          'Can\'t finish on time.',
          'Would it be possible to extend the deadline by two days?',
          'The deadline is too soon.',
        ],
        correctIndex: 2,
      ),
    ];
  }

  /// Fallback interview questions when lesson content is insufficient
  List<Phase5FinalTestQuestion> _getFallbackInterviewQuestions() {
    return [
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_1',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "What is your biggest strength?" Choose the best answer:',
        options: [
          'I am very hardworking.',
          'I don\'t know.',
          'My strength is my ability to learn quickly and adapt to new challenges.',
          'I have no weaknesses.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_2',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "Tell me about yourself." Choose the best response:',
        options: [
          'I like movies and pizza.',
          'I\'m a software developer with 3 years of experience in web development.',
          'I\'m 28 years old.',
          'What do you want to know?',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_3',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "Why do you want to work here?" Choose the best answer:',
        options: [
          'I need money.',
          'Your company\'s innovative approach aligns with my career goals.',
          'It\'s close to my house.',
          'I don\'t know much about your company.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_4',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "What is your biggest weakness?" Choose the best answer:',
        options: [
          'I have no weaknesses.',
          'I\'m terrible at everything.',
          'I sometimes focus too much on details, but I\'m working on balancing thoroughness with efficiency.',
          'I\'m always late.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_5',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "Where do you see yourself in 5 years?" Choose the best answer:',
        options: [
          'I don\'t know.',
          'In your position.',
          'I see myself growing into a leadership role while continuing to develop my technical skills.',
          'Probably at a different company.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_6',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "Do you have any questions for us?" Choose the best response:',
        options: [
          'No, I\'m good.',
          'How much vacation time do I get?',
          'Could you tell me more about the team I would be working with?',
          'When do I start?',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_7',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "Why did you leave your last job?" Choose the best answer:',
        options: [
          'My boss was terrible.',
          'I was looking for new challenges and opportunities for professional growth.',
          'I got fired.',
          'The pay was too low.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_8',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "How do you handle stress?" Choose the best answer:',
        options: [
          'I don\'t get stressed.',
          'I panic.',
          'I prioritize tasks and break them into manageable steps to stay focused.',
          'I avoid stressful situations.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.interview(
        id: 'fallback_interview_9',
        unitId: 'phase5_unit23',
        lessonId: 'fallback',
        prompt:
            'Interviewer: "Describe a challenge you faced at work." Choose the best answer:',
        options: [
          'I never had any challenges.',
          'When our project deadline was moved up, I reorganized priorities and led the team to deliver on time.',
          'My coworkers were difficult.',
          'I don\'t remember.',
        ],
        correctIndex: 1,
      ),
    ];
  }

  /// Fallback presentation questions when lesson content is insufficient
  List<Phase5FinalTestQuestion> _getFallbackPresentationQuestions() {
    return [
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_1',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt: 'Choose the best opening sentence for a presentation:',
        options: [
          'Today I talk about my project.',
          'I will explain my project.',
          'Good morning everyone. Today, I would like to present our quarterly results.',
          'Let me start fast.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_2',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt: 'Which is the best transition phrase between topics?',
        options: [
          'OK, next thing.',
          'Moving on to our second point, let\'s discuss the market analysis.',
          'Now something else.',
          'Anyway...',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_3',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt: 'Choose the best concluding sentence for a presentation:',
        options: [
          'That\'s all.',
          'I stop here.',
          'In conclusion, our data shows a clear path forward for growth.',
          'Bye.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_4',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt: 'How should you introduce a visual aid in a presentation?',
        options: [
          'Look at this.',
          'As you can see in this chart, our sales increased by 20%.',
          'Here\'s a picture.',
          'This is a graph.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_5',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt: 'Which phrase is best for inviting questions?',
        options: [
          'Any questions?',
          'I\'d be happy to answer any questions you may have.',
          'Questions?',
          'Ask me stuff.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_6',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt:
            'How should you handle a question you don\'t know the answer to?',
        options: [
          'I don\'t know.',
          'That\'s a great question. Let me research that and get back to you.',
          'No idea.',
          'Ask someone else.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_7',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt: 'Which is the best way to emphasize a key point?',
        options: [
          'This is important.',
          'I want to highlight that customer satisfaction increased by 30%.',
          'Remember this.',
          'Pay attention.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.presentation(
        id: 'fallback_presentation_8',
        unitId: 'phase5_unit24',
        lessonId: 'fallback',
        prompt: 'How should you summarize your presentation?',
        options: [
          'So that\'s it.',
          'To summarize, we\'ve covered three main points: market trends, our strategy, and expected outcomes.',
          'I said a lot.',
          'Done.',
        ],
        correctIndex: 1,
      ),
    ];
  }

  /// Fallback writing questions when lesson content is insufficient
  List<Phase5FinalTestQuestion> _getFallbackWritingQuestions() {
    return [
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_1',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Which is the best concluding sentence for an essay?',
        options: [
          'That\'s all.',
          'I stop here.',
          'In conclusion, this approach provides an effective solution to the problem.',
          'Bye.',
        ],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_2',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt:
            'Which is the best topic sentence for a paragraph about climate change?',
        options: [
          'Climate change is bad.',
          'Climate change poses significant challenges to global food security.',
          'I will talk about climate.',
          'Climate is changing.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_3',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'How should you express your opinion in formal writing?',
        options: [
          'I think this is stupid.',
          'In my view, this policy requires further consideration.',
          'This is obviously wrong.',
          'Everyone knows this is bad.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_4',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Which transition word best shows contrast?',
        options: ['And', 'Also', 'However', 'Then'],
        correctIndex: 2,
      ),
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_5',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Which is the best way to introduce evidence in an essay?',
        options: [
          'Look at this.',
          'According to recent research, 70% of consumers prefer sustainable products.',
          'Here\'s proof.',
          'This shows it.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_6',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'How should you structure a persuasive paragraph?',
        options: [
          'Just write your opinion.',
          'Topic sentence, supporting evidence, explanation, and concluding sentence.',
          'Start with the conclusion.',
          'Write whatever comes to mind.',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_7',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Which phrase best introduces a counterargument?',
        options: [
          'But...',
          'Some may argue that this approach has limitations; however...',
          'Wrong people think...',
          'Others are stupid because...',
        ],
        correctIndex: 1,
      ),
      Phase5FinalTestQuestion.writing(
        id: 'fallback_writing_8',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'What is the best way to end a formal letter?',
        options: [
          'Bye!',
          'See ya!',
          'I look forward to your response. Sincerely,',
          'Later!',
        ],
        correctIndex: 2,
      ),
    ];
  }

  /// Fallback speaking prompts when lesson content is insufficient
  List<Phase5FinalTestQuestion> _getFallbackSpeakingPrompts() {
    return [
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_1',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Introduce yourself as a software developer in 30 seconds.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_2',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Explain a project you worked on recently.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_3',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Give a short opinion on remote work.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_4',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Describe your strengths and weaknesses.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_5',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Explain why you are interested in this position.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_6',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt:
            'Describe a challenging situation at work and how you handled it.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_7',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Present the main benefits of your product or service.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_8',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt: 'Summarize your career goals for the next five years.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_9',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt:
            'Explain how you prioritize tasks when you have multiple deadlines.',
      ),
      Phase5FinalTestQuestion.speakingRubricScored(
        id: 'fallback_speak_10',
        unitId: 'phase5_unit25',
        lessonId: 'fallback',
        prompt:
            'Describe a time when you had to work with a difficult team member.',
      ),
    ];
  }

  /// Validate an MCQ answer by comparing selected index with correct index
  ///
  /// Returns true if the selected answer matches the correct answer, false otherwise.
  /// For speaking tasks (which have null correctIndex), always returns false.
  ///
  /// Requirements: 2.3, 3.3, 4.3, 5.3
  bool validateMcqAnswer(Phase5FinalTestQuestion question, int selectedIndex) {
    // Speaking tasks don't have a correct index - they're scored differently
    if (question.correctIndex == null) {
      return false;
    }

    // Compare selected index with correct index
    return selectedIndex == question.correctIndex;
  }

  /// Score a speaking task based on word count in recognized text
  ///
  /// Scoring tiers (enhanced for professional level):
  /// - 4 points: 40-80 words (clear, confident, well-structured)
  /// - 3 points: 25-39 words (good but slightly short)
  /// - 2 points: 10-24 words (basic, lacks structure)
  /// - 1 point: 1-9 words (very weak)
  /// - 0 points: 0 words (no output)
  ///
  /// Returns a Phase5SpeakingScoreResult with score and feedback message.
  ///
  /// Requirements: 6.3, 6.4, 6.5
  Phase5SpeakingScoreResult scoreSpeakingTask(String? recognizedText) {
    // Handle null or empty text
    if (recognizedText == null || recognizedText.trim().isEmpty) {
      return Phase5SpeakingScoreResult(
        score: 0,
        wordCount: 0,
        feedback: 'No speech detected. Please try again.',
      );
    }

    // Count words by splitting on whitespace
    final words = recognizedText.trim().split(RegExp(r'\s+'));
    final wordCount = words.where((w) => w.isNotEmpty).length;

    // Determine score based on word count tiers (enhanced for professional level)
    int score;
    String feedback;

    if (wordCount >= 40 && wordCount <= 80) {
      score = 4;
      feedback = 'Excellent! Clear, confident, and well-structured response.';
    } else if (wordCount >= 25) {
      score = 3;
      feedback = 'Good response! Try to expand with more details.';
    } else if (wordCount >= 10) {
      score = 2;
      feedback = 'Basic response. Work on structure and confidence.';
    } else if (wordCount >= 1) {
      score = 1;
      feedback = 'Very brief. Practice speaking in complete sentences.';
    } else {
      score = 0;
      feedback = 'No speech detected. Please try again.';
    }

    return Phase5SpeakingScoreResult(
      score: score,
      wordCount: wordCount,
      feedback: feedback,
    );
  }

  /// Calculate the final test result from questions and answers
  ///
  /// Parameters:
  /// - questions: List of all 35 test questions
  /// - mcqAnswers: Map of question ID to selected answer index (for MCQ questions)
  /// - speakingResults: List of Phase5SpeakingResult for speaking tasks
  ///
  /// Returns a Phase5TestResult with:
  /// - Total score (MCQ correct + speaking scores)
  /// - Percentage (totalScore / 60 * 100)
  /// - Pass/fail status (>= 45 points to pass)
  /// - List of incorrect MCQ answers for review
  ///
  /// Requirements: 7.1, 7.2, 7.3, 8.1
  Phase5TestResult calculateResult({
    required List<Phase5FinalTestQuestion> questions,
    required Map<String, int> mcqAnswers,
    required List<Phase5SpeakingResult> speakingResults,
  }) {
    int mcqCorrect = 0;
    int speakingScore = 0;
    final incorrectMcqAnswers = <Phase5IncorrectAnswer>[];
    int listeningTotal = 0;
    int listeningCorrect = 0;
    int readingTotal = 0;
    int readingCorrect = 0;
    int writingTotal = 0;
    int writingCorrect = 0;

    // Process each question
    for (final question in questions) {
      if (question.isMcq) {
        switch (question.type) {
          case Phase5QuestionType.presentation:
            listeningTotal++;
            break;
          case Phase5QuestionType.writing:
          case Phase5QuestionType.shortAnswer:
          case Phase5QuestionType.rewrite:
          case Phase5QuestionType.ordering:
          case Phase5QuestionType.writingRubricScored:
            writingTotal++;
            break;
          case Phase5QuestionType.businessEnglish:
          case Phase5QuestionType.interview:
          case Phase5QuestionType.speakingRubricScored:
            readingTotal++;
            break;
        }

        // MCQ question - check if answer is correct
        final selectedIndex = mcqAnswers[question.id];

        if (selectedIndex != null && question.correctIndex != null) {
          if (selectedIndex == question.correctIndex) {
            // Correct answer - add 1 point
            mcqCorrect++;
            switch (question.type) {
              case Phase5QuestionType.presentation:
                listeningCorrect++;
                break;
              case Phase5QuestionType.writing:
              case Phase5QuestionType.shortAnswer:
              case Phase5QuestionType.rewrite:
              case Phase5QuestionType.ordering:
              case Phase5QuestionType.writingRubricScored:
                writingCorrect++;
                break;
              case Phase5QuestionType.businessEnglish:
              case Phase5QuestionType.interview:
              case Phase5QuestionType.speakingRubricScored:
                readingCorrect++;
                break;
            }
          } else {
            // Incorrect answer - add to review list
            incorrectMcqAnswers.add(
              Phase5IncorrectAnswer(
                question: question,
                selectedIndex: selectedIndex,
                selectedAnswer: question.options![selectedIndex],
                correctAnswer: question.options![question.correctIndex!],
              ),
            );
          }
        } else if (selectedIndex == null && question.correctIndex != null) {
          // Question was skipped - treat as incorrect
          incorrectMcqAnswers.add(
            Phase5IncorrectAnswer(
              question: question,
              selectedIndex: -1, // Indicates skipped
              selectedAnswer: 'Skipped',
              correctAnswer: question.options![question.correctIndex!],
            ),
          );
        }
      }
    }

    // Sum speaking scores (0-4 each, max 32 total)
    for (final result in speakingResults) {
      speakingScore += result.score;
    }

    final double listeningPercent = listeningTotal == 0
        ? 0.0
        : (listeningCorrect / listeningTotal) * 100.0;
    final double readingGrammarPercent = readingTotal == 0
        ? 0.0
        : (readingCorrect / readingTotal) * 100.0;
    final double writingMcqPercent = writingTotal == 0
        ? 0.0
        : (writingCorrect / writingTotal) * 100.0;
    final double speakingPercent = speakingResults.isEmpty
        ? 0.0
        : (speakingResults
                      .map((result) => result.rubricScore100)
                      .fold<int>(0, (sum, score) => sum + score) /
                  speakingResults.length)
              .clamp(0, 100)
              .toDouble();

    // For current UI, writing productive tasks are not yet captured in final test input.
    // Use the writing section objective score as writing section baseline.
    final double writingPercent = writingMcqPercent;

    // Create and return the result using the factory constructor
    return Phase5TestResult.calculate(
      mcqCorrect: mcqCorrect,
      speakingScore: speakingScore,
      completedAt: DateTime.now(),
      incorrectMcqAnswers: incorrectMcqAnswers,
      speakingResults: speakingResults,
      listeningPercent: listeningPercent,
      readingGrammarPercent: readingGrammarPercent,
      speakingPercent: speakingPercent,
      writingPercent: writingPercent,
    );
  }

  /// Save the test result to persistent storage
  ///
  /// Persists:
  /// - phase5FinalTestPassed: true if passed, false otherwise
  /// - phase5FinalTestScore: the total score achieved
  /// - phase5FinalTestDate: timestamp of when test was completed
  /// - englishMasteryCompleted: true if test was passed (marks program completion)
  ///
  /// Requirements: 9.1, 9.2, 9.3, 9.4
  Future<void> saveTestResult(Phase5TestResult result) async {
    try {
      // Save pass/fail status
      await _storageService.setBool(keyTestPassed, result.passed);

      // Save the total score
      await _storageService.setInt(keyTestScore, result.totalScore);

      // Save the test date
      await _storageService.setString(
        keyTestDate,
        result.completedAt.toIso8601String(),
      );

      // If passed, mark English Mastery as completed
      if (result.passed) {
        await _storageService.setBool(keyMasteryCompleted, true);
        print(
          'English Mastery Completed! Test passed with score: ${result.totalScore}/${result.maxScore}',
        );
      } else {
        print(
          'Test not passed. Score: ${result.totalScore}/${result.maxScore}',
        );
      }
    } catch (e) {
      print('Error: Failed to save test result: $e');
      rethrow;
    }
  }
}

/// Result of scoring a speaking task
class Phase5SpeakingScoreResult {
  final int score;
  final int wordCount;
  final String feedback;

  Phase5SpeakingScoreResult({
    required this.score,
    required this.wordCount,
    required this.feedback,
  });
}
