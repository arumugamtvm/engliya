# Design Document

## Overview

Engliya Phase 2 extends the existing Flutter application to provide intermediate English learning content for Tamil-speaking learners. Building on Phase 1's foundation of 6 basic lessons, Phase 2 adds 25 new lessons across 5 units covering continuous tenses, perfect tenses, time/place language, questions/negatives, and advanced pronouns/adjectives/adverbs. The design maintains the offline-first architecture, mastery-based progression, and reuses all existing UI components and data models.

### Key Design Principles

1. **Reuse Over Rebuild**: Leverage existing Phase 1 components, models, and services without modification
2. **Consistent User Experience**: Phase 2 screens look and behave identically to Phase 1
3. **Offline-First**: All content stored locally in JSON assets
4. **Gated Progression**: Phase 2 locked until Phase 1 Final Test passed
5. **Scalable Architecture**: Design supports future phases (Phase 3, 4, etc.)

### Phase 2 Content Structure

- **Unit 7 - Time & Place Language** (3 lessons)
  - Lesson 7.1: Time Prepositions
  - Lesson 7.2: Place & Movement Prepositions
  - Lesson 7.3: Daily Time Expressions

- **Unit 8 - Continuous Tenses** (4 lessons)
  - Lesson 8.1: Present Continuous
  - Lesson 8.2: Past Continuous
  - Lesson 8.3: Future Continuous
  - Lesson 8.4: Continuous Tenses in Conversation

- **Unit 9 - Perfect & Perfect Continuous** (5 lessons)
  - Lesson 9.1: Present Perfect
  - Lesson 9.2: Past Perfect
  - Lesson 9.3: Future Perfect
  - Lesson 9.4: Present Perfect Continuous
  - Lesson 9.5: Perfect vs Simple Past

- **Unit 10 - Questions & Negatives** (5 lessons)
  - Lesson 10.1: Be-Verb Questions
  - Lesson 10.2: Do/Does/Did Questions
  - Lesson 10.3: WH-Questions
  - Lesson 10.4: Negatives
  - Lesson 10.5: Real Q&A Practice

- **Unit 11 - Advanced Pronouns, Adjectives & Adverbs** (5 lessons)
  - Lesson 11.1: Possessive Pronouns & Adjectives
  - Lesson 11.2: Reflexive Pronouns
  - Lesson 11.3: Demonstrative Pronouns
  - Lesson 11.4: Adjectives
  - Lesson 11.5: Adverbs

## Architecture

### High-Level Architecture

Phase 2 integrates seamlessly into the existing architecture without requiring new layers or patterns:


```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                     │
│  Phase1UnitScreen | Phase2UnitScreen            │
│  Phase2LessonListScreen | LessonScreen (reused) │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│           Business Logic Layer                   │
│  LessonProvider (reused)                        │
│  ProgressProvider (extended)                    │
│  Phase2UnitProvider (new)                       │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Data Layer                          │
│  LessonRepository (extended)                    │
│  ProgressRepository (reused)                    │
│  Phase 2 JSON Assets (new)                      │
└──────────────────────────────────────────────────┘
```

### New Components for Phase 2

Only 3 new components are required:

1. **Phase2UnitScreen**: Displays list of 5 units (7-11)
2. **Phase2LessonListScreen**: Displays lessons for a selected unit
3. **Phase2UnitProvider**: Manages state for Phase2UnitScreen

All other components are reused from Phase 1.

### Updated Folder Structure


```
lib/features/learn/
├── presentation/
│   ├── screens/
│   │   ├── phase1_unit_screen.dart        # Existing
│   │   ├── phase2_unit_screen.dart        # NEW
│   │   ├── phase2_lesson_list_screen.dart # NEW
│   │   └── lesson_screen.dart             # Reused as-is
│   ├── providers/
│   │   ├── lesson_provider.dart           # Reused as-is
│   │   ├── progress_provider.dart         # Extended
│   │   └── phase2_unit_provider.dart      # NEW
│   └── widgets/
│       └── tabs/                          # All reused as-is

assets/
├── lessons/
│   ├── phase1/                            # Existing
│   │   ├── lesson1_pronouns.json
│   │   └── ...
│   └── phase2/                            # NEW
│       ├── lesson7_1_time_prepositions.json
│       ├── lesson7_2_place_prepositions.json
│       ├── lesson7_3_time_expressions.json
│       ├── lesson8_1_present_continuous.json
│       ├── lesson8_2_past_continuous.json
│       ├── lesson8_3_future_continuous.json
│       ├── lesson8_4_continuous_conversations.json
│       ├── lesson9_1_present_perfect.json
│       ├── lesson9_2_past_perfect.json
│       ├── lesson9_3_future_perfect.json
│       ├── lesson9_4_present_perfect_continuous.json
│       ├── lesson9_5_perfect_vs_past.json
│       ├── lesson10_1_be_questions.json
│       ├── lesson10_2_do_does_did_questions.json
│       ├── lesson10_3_wh_questions.json
│       ├── lesson10_4_negatives.json
│       ├── lesson10_5_real_qa.json
│       ├── lesson11_1_possessive_pronouns.json
│       ├── lesson11_2_reflexive_pronouns.json
│       ├── lesson11_3_demonstrative_pronouns.json
│       ├── lesson11_4_adjectives.json
│       └── lesson11_5_adverbs.json
```

## Components and Interfaces

### 1. New Screen Components

#### Phase2UnitScreen


```dart
class Phase2UnitScreen extends StatefulWidget {
  const Phase2UnitScreen({super.key});
  
  @override
  State<Phase2UnitScreen> createState() => _Phase2UnitScreenState();
}

class _Phase2UnitScreenState extends State<Phase2UnitScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Phase2UnitProvider>().loadUnits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 2: Intermediate English'),
      ),
      body: Consumer<Phase2UnitProvider>(
        builder: (context, provider, child) {
          // Display 5 unit cards
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return UnitCard(
                unit: provider.units[index],
                onTap: () => _navigateToLessonList(unit.id),
              );
            },
          );
        },
      ),
    );
  }
}
```

#### Phase2LessonListScreen


```dart
class Phase2LessonListScreen extends StatefulWidget {
  final String unitId;
  
  const Phase2LessonListScreen({
    super.key,
    required this.unitId,
  });
  
  @override
  State<Phase2LessonListScreen> createState() => _Phase2LessonListScreenState();
}

class _Phase2LessonListScreenState extends State<Phase2LessonListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getUnitTitle(widget.unitId)),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          final lessons = progressProvider.getUnitLessons(widget.unitId);
          
          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final status = progressProvider.getLessonStatus(lesson.id);
              final isUnlocked = progressProvider.isLessonUnlocked(lesson.id);
              
              return LessonCard(
                lesson: lesson,
                status: status,
                isUnlocked: isUnlocked,
                onTap: () => _handleLessonTap(lesson.id, isUnlocked),
              );
            },
          );
        },
      ),
    );
  }
}
```

### 2. Extended Components

#### ProgressProvider Extensions


```dart
class ProgressProvider extends ChangeNotifier {
  // Existing fields...
  
  // NEW: Phase 2 specific methods
  
  /// Get all lessons for a specific unit
  List<Lesson> getUnitLessons(String unitId) {
    return _allLessons
        .where((lesson) => lesson.unitId == unitId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
  
  /// Check if Phase 2 is unlocked
  bool get isPhase2Unlocked {
    return _storageService.getBool('phase1FinalTestPassed') ?? false;
  }
  
  /// Get Phase 2 progress summary
  Phase2Progress get phase2Progress {
    final phase2Lessons = _allLessons
        .where((l) => l.unitId.startsWith('phase2_unit'));
    
    final mastered = phase2Lessons
        .where((l) => _allProgress[l.id]?.isMastered ?? false)
        .length;
    
    return Phase2Progress(
      totalLessons: phase2Lessons.length,
      masteredLessons: mastered,
    );
  }
}
```

#### LessonRepository Extensions


```dart
class LessonRepository {
  // Existing methods...
  
  /// Load all lessons for a specific Phase 2 unit
  Future<List<Lesson>> loadUnitLessons(String unitId) async {
    // Extended to support Phase 2 units
    if (unitId == 'phase1') {
      // Existing Phase 1 logic
      return _loadPhase1Lessons();
    }
    
    if (unitId.startsWith('phase2_unit')) {
      return _loadPhase2UnitLessons(unitId);
    }
    
    throw LessonLoadException('Unknown unit ID: $unitId');
  }
  
  /// Load Phase 2 unit lessons
  Future<List<Lesson>> _loadPhase2UnitLessons(String unitId) async {
    final lessons = <Lesson>[];
    final lessonFiles = _getPhase2LessonFiles(unitId);
    
    for (final lessonId in lessonFiles.keys) {
      try {
        final lesson = await loadLesson(lessonId);
        lessons.add(lesson);
      } catch (e) {
        print('Warning: Failed to load $lessonId: $e');
      }
    }
    
    lessons.sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }
  
  /// Get asset path for Phase 2 lessons
  String _getAssetPath(String lessonId) {
    if (lessonId.startsWith('phase1_')) {
      // Existing Phase 1 logic
      return _getPhase1AssetPath(lessonId);
    }
    
    if (lessonId.startsWith('phase2_')) {
      return _getPhase2AssetPath(lessonId);
    }
    
    throw LessonLoadException('Invalid lesson ID format: $lessonId');
  }
  
  /// Map Phase 2 lesson IDs to file names
  String _getPhase2AssetPath(String lessonId) {
    final lessonFileMap = {
      'phase2_lesson7_1': 'lesson7_1_time_prepositions.json',
      'phase2_lesson7_2': 'lesson7_2_place_prepositions.json',
      'phase2_lesson7_3': 'lesson7_3_time_expressions.json',
      'phase2_lesson8_1': 'lesson8_1_present_continuous.json',
      'phase2_lesson8_2': 'lesson8_2_past_continuous.json',
      'phase2_lesson8_3': 'lesson8_3_future_continuous.json',
      'phase2_lesson8_4': 'lesson8_4_continuous_conversations.json',
      // ... all 25 lessons mapped
    };
    
    final fileName = lessonFileMap[lessonId];
    if (fileName == null) {
      throw LessonLoadException('Unknown Phase 2 lesson: $lessonId');
    }
    
    return 'assets/lessons/phase2/$fileName';
  }
}
```

### 3. New Provider

#### Phase2UnitProvider


```dart
class Phase2UnitProvider extends ChangeNotifier {
  final ProgressProvider _progressProvider;
  
  List<Phase2Unit> _units = [];
  bool _isLoading = false;
  String? _error;
  
  Phase2UnitProvider(this._progressProvider);
  
  List<Phase2Unit> get units => _units;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load all Phase 2 units with progress
  Future<void> loadUnits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _units = [
        Phase2Unit(
          id: 'phase2_unit7',
          order: 7,
          title: 'Time & Place Language',
          description: 'Learn prepositions and time expressions',
          lessonCount: 3,
        ),
        Phase2Unit(
          id: 'phase2_unit8',
          order: 8,
          title: 'Continuous Tenses',
          description: 'Present, past, and future continuous',
          lessonCount: 4,
        ),
        Phase2Unit(
          id: 'phase2_unit9',
          order: 9,
          title: 'Perfect & Perfect Continuous',
          description: 'Master perfect tenses',
          lessonCount: 5,
        ),
        Phase2Unit(
          id: 'phase2_unit10',
          order: 10,
          title: 'Questions & Negatives',
          description: 'Ask questions and form negatives',
          lessonCount: 5,
        ),
        Phase2Unit(
          id: 'phase2_unit11',
          order: 11,
          title: 'Advanced Pronouns, Adjectives & Adverbs',
          description: 'Enrich your sentences',
          lessonCount: 5,
        ),
      ];
      
      // Calculate progress for each unit
      for (final unit in _units) {
        final lessons = _progressProvider.getUnitLessons(unit.id);
        final mastered = lessons
            .where((l) => _progressProvider.getLessonStatus(l.id)?.isMastered ?? false)
            .length;
        unit.masteredCount = mastered;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load units: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}

class Phase2Unit {
  final String id;
  final int order;
  final String title;
  final String description;
  final int lessonCount;
  int masteredCount = 0;
  
  Phase2Unit({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.lessonCount,
  });
}
```

## Data Models

### Reused Models

All existing models are reused without modification:
- `Lesson`
- `LessonExplain`
- `ExampleSentence`
- `ListeningQuestion`
- `SpeakSentence`
- `QuizQuestion`
- `UserLessonStatus`

### JSON Structure for Phase 2 Lessons

Phase 2 lessons use the identical JSON schema as Phase 1. Example for Lesson 7.1:


```json
{
  "id": "phase2_lesson7_1",
  "order": 1,
  "unitId": "phase2_unit7",
  "title": "Time Prepositions",
  "description": "on / in / at / since / for / ago / before / by",
  "level": "A2",
  "explain": {
    "ta": "காலத்தை குறிப்பிட நாம் பல்வேறு prepositions பயன்படுத்துகிறோம். 'on' என்பது நாட்களுக்கு, 'in' என்பது மாதங்கள் மற்றும் வருடங்களுக்கு, 'at' என்பது குறிப்பிட்ட நேரத்திற்கு பயன்படுத்தப்படுகிறது.",
    "en": "We use different prepositions to indicate time. 'on' is used for days, 'in' for months and years, 'at' for specific times. 'since' shows a starting point, 'for' shows duration, 'ago' refers to past time, 'before' means earlier than, and 'by' means not later than.",
    "table": [
      {
        "key": "on",
        "examples": ["on Monday", "on 5th June", "on Christmas Day"]
      },
      {
        "key": "in",
        "examples": ["in July", "in 2020", "in the morning"]
      },
      {
        "key": "at",
        "examples": ["at 5 pm", "at night", "at noon"]
      },
      {
        "key": "since",
        "examples": ["since 2020", "since Monday", "since morning"]
      },
      {
        "key": "for",
        "examples": ["for 2 years", "for 3 hours", "for a week"]
      },
      {
        "key": "ago",
        "examples": ["2 years ago", "3 days ago", "an hour ago"]
      }
    ]
  },
  "examples": [
    {
      "en": "I have a class on Monday.",
      "ta": "எனக்கு திங்கள்கிழமை வகுப்பு உள்ளது.",
      "audioId": "phase2_l7_1_ex1"
    },
    {
      "en": "She was born in 2004.",
      "ta": "அவள் 2004-ல் பிறந்தாள்.",
      "audioId": "phase2_l7_1_ex2"
    },
    {
      "en": "We eat dinner at 9 pm.",
      "ta": "நாங்கள் இரவு 9 மணிக்கு இரவு உணவு சாப்பிடுகிறோம்.",
      "audioId": "phase2_l7_1_ex3"
    },
    {
      "en": "I have lived here since 2020.",
      "ta": "நான் 2020 முதல் இங்கே வசிக்கிறேன்.",
      "audioId": "phase2_l7_1_ex4"
    },
    {
      "en": "They studied for 3 hours.",
      "ta": "அவர்கள் 3 மணி நேரம் படித்தார்கள்.",
      "audioId": "phase2_l7_1_ex5"
    }
  ],
  "listeningQuestions": [
    {
      "audioText": "I go to school at 8 am.",
      "options": [
        "I go to school at 8 am.",
        "I go to school in 8 am.",
        "I go to school on 8 am."
      ],
      "correctIndex": 0
    },
    {
      "audioText": "We have a holiday on Monday.",
      "options": [
        "We have a holiday in Monday.",
        "We have a holiday on Monday.",
        "We have a holiday at Monday."
      ],
      "correctIndex": 1
    },
    {
      "audioText": "She was born in July.",
      "options": [
        "She was born at July.",
        "She was born on July.",
        "She was born in July."
      ],
      "correctIndex": 2
    }
  ],
  "speakSentences": [
    { "en": "I have English class on Friday.", "ta": "எனக்கு வெள்ளிக்கிழமை ஆங்கில வகுப்பு உள்ளது." },
    { "en": "We eat dinner at 9 pm.", "ta": "நாங்கள் இரவு 9 மணிக்கு இரவு உணவு சாப்பிடுகிறோம்." },
    { "en": "I was born in 2005.", "ta": "நான் 2005-ல் பிறந்தேன்." }
  ],
  "practiceQuestions": [
    {
      "type": "mcq",
      "promptEn": "We have a holiday ___ Monday.",
      "promptTa": "நமக்கு திங்கள்கிழமை விடுமுறை உள்ளது.",
      "options": ["in", "on", "at", "by"],
      "correctIndex": 1
    },
    {
      "type": "mcq",
      "promptEn": "She wakes up ___ 6 am.",
      "promptTa": "அவள் காலை 6 மணிக்கு எழுந்து விடுகிறாள்.",
      "options": ["in", "on", "at", "for"],
      "correctIndex": 2
    },
    {
      "type": "mcq",
      "promptEn": "I was born ___ 2004.",
      "promptTa": "நான் 2004-ல் பிறந்தேன்.",
      "options": ["in", "on", "at", "by"],
      "correctIndex": 0
    },
    {
      "type": "mcq",
      "promptEn": "I have lived here ___ 2020.",
      "promptTa": "நான் 2020 முதல் இங்கே வசிக்கிறேன்.",
      "options": ["for", "since", "ago", "before"],
      "correctIndex": 1
    },
    {
      "type": "mcq",
      "promptEn": "They studied ___ 3 hours.",
      "promptTa": "அவர்கள் 3 மணி நேரம் படித்தார்கள்.",
      "options": ["for", "since", "ago", "in"],
      "correctIndex": 0
    }
  ],
  "masteryQuestions": [
    {
      "type": "mcq",
      "promptEn": "The meeting is ___ 3 pm.",
      "promptTa": "கூட்டம் மதியம் 3 மணிக்கு உள்ளது.",
      "options": ["in", "on", "at", "by"],
      "correctIndex": 2
    },
    {
      "type": "mcq",
      "promptEn": "I will finish ___ 5 pm.",
      "promptTa": "நான் மாலை 5 மணிக்குள் முடிப்பேன்.",
      "options": ["in", "on", "at", "by"],
      "correctIndex": 3
    },
    {
      "type": "mcq",
      "promptEn": "He left 2 hours ___.",
      "promptTa": "அவர் 2 மணி நேரத்திற்கு முன் சென்றார்.",
      "options": ["for", "since", "ago", "before"],
      "correctIndex": 2
    }
  ]
}
```

## Navigation Flow

### Phase 2 Entry and Navigation


```
HomeScreen
    │
    ├─> Phase 1 Tile ──> Phase1UnitScreen ──> LessonScreen
    │
    └─> Phase 2 Tile (locked until Phase1FinalTestPassed)
            │
            └─> Phase2UnitScreen
                    │
                    ├─> Unit 7 ──> Phase2LessonListScreen ──> LessonScreen
                    ├─> Unit 8 ──> Phase2LessonListScreen ──> LessonScreen
                    ├─> Unit 9 ──> Phase2LessonListScreen ──> LessonScreen
                    ├─> Unit 10 ──> Phase2LessonListScreen ──> LessonScreen
                    └─> Unit 11 ──> Phase2LessonListScreen ──> LessonScreen
```

### Route Definitions

Add to `app/routes.dart`:

```dart
class AppRoutes {
  // Existing routes...
  static const phase1Unit = '/phase1-unit';
  static const lesson = '/lesson';
  
  // NEW Phase 2 routes
  static const phase2Unit = '/phase2-unit';
  static const phase2LessonList = '/phase2-lesson-list';
}

// Route configuration
static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // Existing routes...
    
    case AppRoutes.phase2Unit:
      return MaterialPageRoute(
        builder: (_) => const Phase2UnitScreen(),
      );
      
    case AppRoutes.phase2LessonList:
      final unitId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => Phase2LessonListScreen(unitId: unitId),
      );
      
    // lesson route reused for both Phase 1 and Phase 2
    case AppRoutes.lesson:
      final lessonId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => LessonScreen(lessonId: lessonId),
      );
  }
}
```

## Lesson Unlocking Logic

### Phase 2 Unlock Rules

1. **Phase 2 Access**: Unlocked when `phase1FinalTestPassed == true`
2. **First Lesson**: Lesson 7.1 unlocked by default when Phase 2 is unlocked
3. **Sequential Unlock**: Each lesson unlocks when previous lesson has `masteryBestScore >= 0.8`
4. **Cross-Unit Unlock**: Last lesson of Unit N unlocks first lesson of Unit N+1

### Implementation in ProgressProvider


```dart
bool isLessonUnlocked(String lessonId) {
  // Phase 1 logic (existing)
  if (lessonId.startsWith('phase1_')) {
    if (lessonId == 'phase1_lesson1') return true;
    // Check previous lesson mastery...
  }
  
  // Phase 2 logic (new)
  if (lessonId.startsWith('phase2_')) {
    // Check if Phase 2 is unlocked
    if (!isPhase2Unlocked) return false;
    
    // First lesson of Phase 2 is unlocked by default
    if (lessonId == 'phase2_lesson7_1') return true;
    
    // Find previous lesson
    final previousLessonId = _getPreviousLessonId(lessonId);
    if (previousLessonId == null) return false;
    
    // Check if previous lesson is mastered
    final previousStatus = _allProgress[previousLessonId];
    return previousStatus?.isMastered ?? false;
  }
  
  return false;
}

String? _getPreviousLessonId(String lessonId) {
  // Map of lesson progression
  final lessonSequence = {
    'phase2_lesson7_2': 'phase2_lesson7_1',
    'phase2_lesson7_3': 'phase2_lesson7_2',
    'phase2_lesson8_1': 'phase2_lesson7_3',
    'phase2_lesson8_2': 'phase2_lesson8_1',
    'phase2_lesson8_3': 'phase2_lesson8_2',
    'phase2_lesson8_4': 'phase2_lesson8_3',
    'phase2_lesson9_1': 'phase2_lesson8_4',
    // ... all 25 lessons mapped
  };
  
  return lessonSequence[lessonId];
}
```

## UI Components

### HomeScreen Extension

Add Phase 2 tile to existing HomeScreen:

```dart
// In HomeScreen build method
Column(
  children: [
    // Existing Phase 1 tile
    _buildPhaseTile(
      context,
      title: 'Phase 1: Basic English',
      description: '6 fundamental lessons',
      progress: phase1Progress,
      onTap: () => Navigator.pushNamed(context, AppRoutes.phase1Unit),
      isLocked: false,
    ),
    
    // NEW Phase 2 tile
    _buildPhaseTile(
      context,
      title: 'Phase 2: Intermediate English',
      description: '25 lessons across 5 units',
      progress: phase2Progress,
      onTap: () => _handlePhase2Tap(context),
      isLocked: !isPhase2Unlocked,
    ),
  ],
)

void _handlePhase2Tap(BuildContext context) {
  if (!isPhase2Unlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phase 2 Locked'),
        content: const Text(
          'Please complete Phase 1 Final Test before starting Phase 2.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } else {
    Navigator.pushNamed(context, AppRoutes.phase2Unit);
  }
}
```

### Unit Card Widget

Reusable widget for displaying units in Phase2UnitScreen:


```dart
class UnitCard extends StatelessWidget {
  final Phase2Unit unit;
  final VoidCallback onTap;
  
  const UnitCard({
    super.key,
    required this.unit,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Unit icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Unit ${unit.order}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Unit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${unit.masteredCount} / ${unit.lessonCount} lessons mastered',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Reused Components

The following components are reused without modification:
- `LessonCard`: Displays individual lessons with status
- `LessonScreen`: Main lesson interface with 6 tabs
- All tab widgets: `ExplainTab`, `ExamplesTab`, `ListenTab`, `SpeakTab`, `PracticeTab`, `MasteryTab`
- `LessonBottomNav`: Previous/Next navigation
- `CustomButton`, `ProgressIndicator`, `StatusBadge`

## Error Handling

### Phase 2 Specific Error Scenarios

1. **Phase 2 Locked Access**
   - User taps Phase 2 tile while locked
   - Show dialog: "Please complete Phase 1 Final Test before starting Phase 2"
   - No error logged, expected behavior

2. **Missing JSON Asset**
   - Phase 2 lesson file not found
   - Show error: "Unable to load lesson content"
   - Log error with lesson ID for debugging

3. **Invalid JSON Format**
   - Phase 2 JSON parsing fails
   - Show error: "Lesson content is corrupted"
   - Log error with details

4. **Progress Save Failure**
   - Same handling as Phase 1
   - Retry once, then show error message

### Error Handling Strategy

Reuse existing error handling infrastructure:
- `LessonLoadException` for asset loading errors
- `StorageException` for persistence errors
- User-friendly error messages via SnackBar or Dialog
- Detailed logging for debugging

## Testing Strategy

### Unit Tests

#### New Components
- Phase2UnitProvider: unit loading, progress calculation
- LessonRepository extensions: Phase 2 asset path mapping
- ProgressProvider extensions: Phase 2 unlock logic, unit filtering

#### Unlock Logic
- Phase 2 locked when Phase 1 Final Test not passed
- Lesson 7.1 unlocked when Phase 2 unlocked
- Sequential unlocking within units
- Cross-unit unlocking (Unit 7 → Unit 8, etc.)

### Widget Tests

#### New Screens
- Phase2UnitScreen: unit list rendering, tap handling
- Phase2LessonListScreen: lesson list rendering, lock status display
- HomeScreen: Phase 2 tile display, lock dialog

### Integration Tests

#### Phase 2 User Flows
1. **Locked Phase 2 flow**:
   - Launch app → Home → Tap Phase 2 (locked) → See lock dialog

2. **Unlock Phase 2 flow**:
   - Pass Phase 1 Final Test → Home → Phase 2 unlocked → Access Phase2UnitScreen

3. **Lesson progression flow**:
   - Open Lesson 7.1 → Complete → Master → Lesson 7.2 unlocks

4. **Cross-unit progression**:
   - Master Lesson 7.3 → Lesson 8.1 unlocks

5. **Progress persistence**:
   - Complete Phase 2 lessons → Close app → Reopen → Progress restored

### Test Data

Create test fixtures for:
- All 25 Phase 2 lesson JSON files (at least minimal versions)
- Various Phase 2 progress states
- Phase 2 locked/unlocked scenarios

## Performance Considerations

### Asset Loading
- Lazy load Phase 2 lessons (only when accessed)
- Cache parsed JSON in LessonRepository
- Preload next lesson in background (optional optimization)

### Memory Management
- Dispose Phase2UnitProvider when screen closed
- Clear lesson cache if memory pressure detected
- Limit cached lessons to 5 most recent (Phase 1 + Phase 2)

### Storage
- Batch progress updates (same as Phase 1)
- Use same debouncing strategy
- Phase 2 progress stored in same structure as Phase 1

## Content Guidelines

### Units 7 & 8 (Comprehensive Content)

Each lesson must include:
- 1-2 explanation paragraphs (Tamil + English)
- 3-5 example sentences with translations
- 2-3 listening questions
- 3 speak sentences
- 3-5 practice questions
- 3-5 mastery questions

### Units 9, 10 & 11 (Lighter Content)

Each lesson must include:
- 1 explanation paragraph (Tamil + English)
- 2-3 example sentences with translations
- 2 practice questions
- 2 mastery questions

### Content Quality Standards

- All Tamil translations must be accurate and natural
- Examples should be practical and relevant to daily life
- Questions should test understanding, not memorization
- Difficulty should progress gradually within each unit

## Future Extensibility

### Phase 3+ Preparation

The design supports additional phases:

1. **Scalable Structure**
   - Add `Phase3UnitScreen`, `Phase3LessonListScreen`
   - Extend LessonRepository with Phase 3 asset paths
   - Add Phase 3 unlock condition (e.g., Phase 2 Final Test)

2. **Consistent Patterns**
   - Same JSON schema for all phases
   - Same unlock logic pattern
   - Same UI components reused

3. **Minimal Code Changes**
   - New screens follow existing patterns
   - Repository extensions follow same pattern
   - No changes to core models or services

### Backend Integration (Future)

When backend is added:
- Repository pattern allows easy swap to network data source
- Progress sync to cloud storage
- Content updates without app release
- User authentication and multi-device sync

### Advanced Features (Future)

- Phase-specific final tests
- Cross-phase review lessons
- Adaptive difficulty based on performance
- Personalized lesson recommendations

## Summary

Phase 2 implementation leverages the existing Phase 1 architecture with minimal new code:

**New Components**: 3 (Phase2UnitScreen, Phase2LessonListScreen, Phase2UnitProvider)

**Extended Components**: 2 (LessonRepository, ProgressProvider)

**Reused Components**: All models, services, tab widgets, and LessonScreen

**New Assets**: 25 JSON files following existing schema

**Total Effort**: Primarily content creation (JSON files) with minimal code changes

This design ensures consistency, maintainability, and scalability for future phases.
