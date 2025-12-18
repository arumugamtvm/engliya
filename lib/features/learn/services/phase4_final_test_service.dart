import 'dart:math';
import '../data/models/phase4_final_test_question.dart';
import '../data/models/phase4_test_result.dart';
import '../data/models/lesson.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/lesson_repository.dart';
import '../../../services/local_storage/storage_service.dart';
import 'debug_service.dart';
import 'test_exceptions.dart';

/// Service for managing Phase 4 Final Test operations
/// Handles test generation, answer validation, result calculation, and persistence
/// 
/// Phase 4 covers Units 18-21:
/// - Unit 18: Pronunciation & Sound (4 lessons) - 6 pronunciation MCQs
/// - Unit 19: Fluency Techniques (4 lessons) - 4 speaking tasks
/// - Unit 20: Real-Life Conversations (5 lessons) - 6 dialogue MCQs, 4 listening MCQs
/// - Unit 21: Discussion & Opinion Skills (4 lessons) - dialogue MCQs
/// 
/// Test composition:
/// - 6 Pronunciation MCQs (1 point each = 6 points max)
/// - 6 Dialogue Response MCQs (1 point each = 6 points max)
/// - 4 Listening MCQs (1 point each = 4 points max)
/// - 4 Speaking Tasks (0-3 points each = 12 points max)
/// Total: 20 questions, 24 points max, 18 points (75%) to pass
class Phase4FinalTestService {
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
  static const int totalQuestions = 20;

  // Scoring constants
  static const int passingScore = 18;
  static const int maxScore = 24;
  static const int maxMcqScore = 16;  // 6 + 6 + 4 = 16 MCQs
  static const int maxSpeakingScore = 12;  // 4 tasks × 3 points

  // Required lessons for test access (all Phase 4 lessons from Units 18-21)
  static const List<String> requiredLessonIds = [
    // Unit 18: Pronunciation & Sound (4 lessons)
    'phase4_lesson18_1', 'phase4_lesson18_2', 'phase4_lesson18_3', 'phase4_lesson18_4',
    // Unit 19: Fluency Techniques (4 lessons)
    'phase4_lesson19_1', 'phase4_lesson19_2', 'phase4_lesson19_3', 'phase4_lesson19_4',
    // Unit 20: Real-Life Conversations (5 lessons)
    'phase4_lesson20_1', 'phase4_lesson20_2', 'phase4_lesson20_3', 'phase4_lesson20_4', 'phase4_lesson20_5',
    // Unit 21: Discussion & Opinion Skills (4 lessons)
    'phase4_lesson21_1', 'phase4_lesson21_2', 'phase4_lesson21_3', 'phase4_lesson21_4',
  ];

  Phase4FinalTestService({
    required StorageService storageService,
    required ProgressRepository progressRepository,
    required DebugService debugService,
    LessonRepository? lessonRepository,
  })  : _storageService = storageService,
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

      print('All required Phase 4 lessons mastered: $masteredCount/$totalRequired');
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
      questions.add(Phase4FinalTestQuestion.pronunciation(
        id: '${lesson.id}_pron_practice_$questionIndex',
        unitId: lesson.unitId,
        lessonId: lesson.id,
        prompt: q.promptEn,
        options: q.options,
        correctIndex: q.correctIndex,
      ));
      questionIndex++;
    }
    
    // Extract from mastery questions
    for (final q in lesson.masteryQuestions) {
      questions.add(Phase4FinalTestQuestion.pronunciation(
        id: '${lesson.id}_pron_mastery_$questionIndex',
        unitId: lesson.unitId,
        lessonId: lesson.id,
        prompt: q.promptEn,
        options: q.options,
        correctIndex: q.correctIndex,
      ));
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
      questions.add(Phase4FinalTestQuestion.dialogue(
        id: '${lesson.id}_dial_practice_$questionIndex',
        unitId: lesson.unitId,
        lessonId: lesson.id,
        prompt: q.promptEn,
        options: q.options,
        correctIndex: q.correctIndex,
      ));
      questionIndex++;
    }
    
    // Extract from mastery questions
    for (final q in lesson.masteryQuestions) {
      questions.add(Phase4FinalTestQuestion.dialogue(
        id: '${lesson.id}_dial_mastery_$questionIndex',
        unitId: lesson.unitId,
        lessonId: lesson.id,
        prompt: q.promptEn,
        options: q.options,
        correctIndex: q.correctIndex,
      ));
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
      questions.add(Phase4FinalTestQuestion.listening(
        id: '${lesson.id}_listen_$questionIndex',
        unitId: lesson.unitId,
        lessonId: lesson.id,
        prompt: 'Based on the dialogue, answer the question:',
        options: q.options,
        correctIndex: q.correctIndex,
        audioText: q.audioText,
      ));
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
      prompts.add(Phase4FinalTestQuestion.speaking(
        id: '${lesson.id}_speak_$promptIndex',
        unitId: lesson.unitId,
        lessonId: lesson.id,
        prompt: 'Speak about this topic in 3-4 sentences: ${s.en}',
      ));
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
        options: [
          'What is this?',
          'How much is this?',
          'Where is this?',
        ],
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
        audioText: 'Customer: "Excuse me, how much is this blue shirt?" Shopkeeper: "That one is 800 rupees."',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_2',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'Where is the fitting room?',
        options: [
          'On the left',
          'On the right',
          'Upstairs',
        ],
        correctIndex: 1,
        audioText: 'Customer: "Can I try this on?" Shopkeeper: "Of course. The fitting room is on your right."',
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
        audioText: 'I like reading books. I read every day. My favorite books are novels.',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_4',
        unitId: 'phase4_unit20',
        lessonId: 'fallback',
        prompt: 'What payment methods does the shop accept?',
        options: [
          'Only cash',
          'Cards and UPI',
          'Only credit cards',
        ],
        correctIndex: 1,
        audioText: 'Customer: "Can I pay by card?" Shopkeeper: "Yes, we accept cards and UPI."',
      ),
      Phase4FinalTestQuestion.listening(
        id: 'fallback_listen_5',
        unitId: 'phase4_unit18',
        lessonId: 'fallback',
        prompt: 'How many syllables does "happy" have?',
        options: [
          '1 syllable',
          '2 syllables',
          '3 syllables',
        ],
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
        audioText: 'To speak fluently, use connecting words like "and", "but", "so", and "because".',
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
            incorrectMcqAnswers.add(Phase4IncorrectAnswer(
              question: question,
              selectedIndex: selectedIndex,
              selectedAnswer: question.options![selectedIndex],
              correctAnswer: question.options![question.correctIndex!],
            ));
          }
        } else if (selectedIndex == null && question.correctIndex != null) {
          // Question was skipped - treat as incorrect
          incorrectMcqAnswers.add(Phase4IncorrectAnswer(
            question: question,
            selectedIndex: -1, // Indicates skipped
            selectedAnswer: 'Skipped',
            correctAnswer: question.options![question.correctIndex!],
          ));
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
        print('Phase 5 unlocked! Test passed with score: ${result.totalScore}/${result.maxScore}');
      } else {
        print('Test not passed. Score: ${result.totalScore}/${result.maxScore} (need $passingScore to pass)');
      }
      
      // Save the full result JSON for later retrieval
      final resultJson = result.toJson();
      await _storageService.setString(keyTestResult, resultJson.toString());
      
      // Save the completion timestamp
      await _storageService.setString(keyTestDate, result.completedAt.toIso8601String());
      
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
