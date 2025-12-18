# Design Document

## Overview

Engliya Phase 1 is a Flutter-based mobile application for Tamil-speaking learners to master basic English through structured, mastery-based learning. The application operates entirely offline using local JSON data and assets, with progress tracked in local storage.

### Key Design Principles

1. **Offline-First**: All content and functionality work without network connectivity
2. **Mastery-Based Progression**: Learners must achieve 80% on mastery tests to unlock next lessons
3. **Bilingual Support**: All content includes Tamil translations for clarity
4. **Modular Architecture**: Clean separation between data, business logic, and presentation
5. **Extensibility**: Design supports future phases and backend integration

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                     │
│  (Screens, Widgets, State Management)           │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│           Business Logic Layer                   │
│  (Providers, Services, Use Cases)               │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Data Layer                          │
│  (Models, Repositories, Local Storage)          │
└──────────────────────────────────────────────────┘
```

### Folder Structure


```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp configuration
│   ├── routes.dart                 # Route definitions
│   └── theme.dart                  # App theme
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # App-wide constants
│   ├── utils/
│   │   └── audio_utils.dart        # TTS utilities
│   └── widgets/
│       ├── custom_button.dart
│       ├── lesson_card.dart
│       └── progress_indicator.dart
├── features/
│   ├── onboarding/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── user_level.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── onboarding_provider.dart
│   │   │   └── screens/
│   │   │       └── onboarding_screen.dart
│   │   └── services/
│   │       └── onboarding_service.dart
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── home_provider.dart
│   │   │   └── screens/
│   │   │       └── home_screen.dart
│   │   └── services/
│   │       └── home_service.dart
│   ├── learn/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── lesson.dart
│   │   │   │   ├── lesson_explain.dart
│   │   │   │   ├── example_sentence.dart
│   │   │   │   ├── listening_question.dart
│   │   │   │   ├── speak_sentence.dart
│   │   │   │   ├── quiz_question.dart
│   │   │   │   └── user_lesson_status.dart
│   │   │   └── repositories/
│   │   │       ├── lesson_repository.dart
│   │   │       └── progress_repository.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   ├── lesson_provider.dart
│   │   │   │   └── progress_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── phase1_unit_screen.dart
│   │   │   │   └── lesson_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tabs/
│   │   │       │   ├── explain_tab.dart
│   │   │       │   ├── examples_tab.dart
│   │   │       │   ├── listen_tab.dart
│   │   │       │   ├── speak_tab.dart
│   │   │       │   ├── practice_tab.dart
│   │   │       │   └── mastery_tab.dart
│   │   │       └── lesson_bottom_nav.dart
│   │   └── services/
│   │       ├── lesson_service.dart
│   │       ├── audio_service.dart
│   │       └── mastery_service.dart
│   └── progress/
│       ├── presentation/
│       │   ├── providers/
│       │   │   └── progress_overview_provider.dart
│       │   └── screens/
│       │       └── progress_screen.dart
│       └── services/
│           └── progress_service.dart
└── services/
    └── local_storage/
        └── storage_service.dart

assets/
├── lessons/
│   └── phase1/
│       ├── lesson1_pronouns.json
│       ├── lesson2_be_verb.json
│       ├── lesson3_nouns_articles.json
│       ├── lesson4_object_pronouns.json
│       ├── lesson5_action_verbs.json
│       └── lesson6_simple_present.json
└── audio/                          # Future: pre-recorded audio files
```

## Components and Interfaces

### 1. Data Models

#### Lesson Model


```dart
class Lesson {
  final String id;
  final int order;
  final String unitId;
  final String title;
  final String description;
  final String level;
  final LessonExplain explain;
  final List<ExampleSentence> examples;
  final List<ListeningQuestion> listeningQuestions;
  final List<SpeakSentence> speakSentences;
  final List<QuizQuestion> practiceQuestions;
  final List<QuizQuestion> masteryQuestions;

  // Factory constructor for JSON deserialization
  factory Lesson.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### LessonExplain Model

```dart
class LessonExplain {
  final String ta;  // Tamil explanation
  final String en;  // English explanation
  final List<ExplainTableRow>? table;  // Optional table data

  factory LessonExplain.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class ExplainTableRow {
  final String pronoun;
  final String descriptionEn;
  final String descriptionTa;

  factory ExplainTableRow.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### ExampleSentence Model

```dart
class ExampleSentence {
  final String en;
  final String ta;
  final String audioId;

  factory ExampleSentence.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### ListeningQuestion Model

```dart
class ListeningQuestion {
  final String audioText;
  final List<String> options;
  final int correctIndex;

  factory ListeningQuestion.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### SpeakSentence Model

```dart
class SpeakSentence {
  final String en;
  final String? ta;  // Optional Tamil translation

  factory SpeakSentence.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### QuizQuestion Model

```dart
class QuizQuestion {
  final String type;  // "mcq", "fill_blank", etc.
  final String promptEn;
  final String? promptTa;
  final List<String> options;
  final int correctIndex;

  factory QuizQuestion.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### UserLessonStatus Model

```dart
class UserLessonStatus {
  final String lessonId;
  bool explainDone;
  bool examplesDone;
  double listeningScore;
  double speakingScore;
  double quizBestScore;
  double masteryBestScore;
  bool isMastered;
  DateTime? lastAccessed;

  // Computed property
  bool get isUnlocked;

  factory UserLessonStatus.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### 2. Repositories

#### LessonRepository

```dart
class LessonRepository {
  // Load lesson from JSON asset
  Future<Lesson> loadLesson(String lessonId);
  
  // Load all lessons for a unit
  Future<List<Lesson>> loadUnitLessons(String unitId);
  
  // Cache management
  void clearCache();
}
```

#### ProgressRepository

```dart
class ProgressRepository {
  final StorageService _storage;

  // Load all progress
  Future<Map<String, UserLessonStatus>> loadAllProgress();
  
  // Load progress for specific lesson
  Future<UserLessonStatus?> loadLessonProgress(String lessonId);
  
  // Save progress for specific lesson
  Future<void> saveLessonProgress(UserLessonStatus status);
  
  // Save all progress
  Future<void> saveAllProgress(Map<String, UserLessonStatus> progress);
  
  // Initialize default progress for new lessons
  UserLessonStatus initializeProgress(String lessonId);
}
```

### 3. Services

#### StorageService

```dart
class StorageService {
  late SharedPreferences _prefs;

  Future<void> init();
  
  // Generic storage methods
  Future<void> setString(String key, String value);
  String? getString(String key);
  Future<void> setBool(String key, bool value);
  bool? getBool(String key);
  Future<void> setDouble(String key, double value);
  double? getDouble(String key);
  
  // JSON storage
  Future<void> setJson(String key, Map<String, dynamic> json);
  Map<String, dynamic>? getJson(String key);
}
```

#### AudioService

```dart
class AudioService {
  final FlutterTts _tts;

  Future<void> init();
  
  // Play text using TTS
  Future<void> speak(String text, {String language = 'en-US'});
  
  // Stop current playback
  Future<void> stop();
  
  // Configure TTS settings
  Future<void> setRate(double rate);
  Future<void> setPitch(double pitch);
  Future<void> setVolume(double volume);
}
```

#### MasteryService

```dart
class MasteryService {
  // Calculate if lesson is mastered
  bool isLessonMastered(UserLessonStatus status);
  
  // Calculate overall progress
  double calculateOverallProgress(List<UserLessonStatus> statuses);
  
  // Determine if lesson should be unlocked
  bool shouldUnlockLesson(int lessonOrder, List<UserLessonStatus> allStatuses);
  
  // Generate mastery test questions
  List<QuizQuestion> generateMasteryTest(Lesson lesson);
}
```

### 4. Providers (State Management)

#### LessonProvider

```dart
class LessonProvider extends ChangeNotifier {
  final LessonRepository _lessonRepo;
  final ProgressRepository _progressRepo;
  
  Lesson? _currentLesson;
  UserLessonStatus? _currentStatus;
  int _currentTabIndex = 0;
  
  // Getters
  Lesson? get currentLesson;
  UserLessonStatus? get currentStatus;
  int get currentTabIndex;
  bool get canGoNext;
  bool get canGoPrevious;
  
  // Load lesson
  Future<void> loadLesson(String lessonId);
  
  // Tab navigation
  void goToNextTab();
  void goToPreviousTab();
  void goToTab(int index);
  
  // Tab completion
  void markExplainDone();
  void markExamplesDone();
  void updateListeningScore(double score);
  void updateSpeakingScore(double score);
  void updateQuizScore(double score);
  void updateMasteryScore(double score);
  
  // Save progress
  Future<void> saveProgress();
}
```

#### ProgressProvider

```dart
class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepo;
  final LessonRepository _lessonRepo;
  
  Map<String, UserLessonStatus> _allProgress = {};
  List<Lesson> _allLessons = [];
  
  // Getters
  Map<String, UserLessonStatus> get allProgress;
  List<Lesson> get allLessons;
  int get masteredCount;
  int get totalLessons;
  String? get lastAccessedLessonId;
  
  // Load data
  Future<void> loadAllData();
  
  // Check unlock status
  bool isLessonUnlocked(String lessonId);
  
  // Get lesson status
  UserLessonStatus? getLessonStatus(String lessonId);
}
```

## Data Models

### JSON Structure for Lesson

Example: `assets/lessons/phase1/lesson1_pronouns.json`



```json
{
  "id": "phase1_lesson1",
  "order": 1,
  "unitId": "phase1",
  "title": "Subject Pronouns",
  "description": "I, You, He, She, It, We, They",
  "level": "A1",
  "explain": {
    "ta": "பெயர்ச்சொற்களுக்கு பதிலாக பயன்படுத்தப்படும் சொற்கள் பிரதிபெயர்கள் எனப்படும்...",
    "en": "Pronouns are words that replace nouns like names of people, places, or things...",
    "table": [
      {
        "pronoun": "I",
        "descriptionEn": "First person singular",
        "descriptionTa": "நான்"
      },
      {
        "pronoun": "You",
        "descriptionEn": "Second person (singular/plural)",
        "descriptionTa": "நீ / நீங்கள்"
      }
    ]
  },
  "examples": [
    {
      "en": "I am a student.",
      "ta": "நான் ஒரு மாணவன்.",
      "audioId": "phase1_l1_ex1"
    }
  ],
  "listeningQuestions": [
    {
      "audioText": "I am a student.",
      "options": [
        "I am a student.",
        "You are a student.",
        "They are students."
      ],
      "correctIndex": 0
    }
  ],
  "speakSentences": [
    {
      "en": "I am a student.",
      "ta": "நான் ஒரு மாணவன்."
    }
  ],
  "practiceQuestions": [
    {
      "type": "mcq",
      "promptEn": "___ am a boy.",
      "promptTa": "___ நான் ஒரு சிறுவன்.",
      "options": ["He", "I", "She", "They"],
      "correctIndex": 1
    }
  ],
  "masteryQuestions": [
    {
      "type": "mcq",
      "promptEn": "Choose the correct pronoun: ___ is my sister.",
      "promptTa": "சரியான pronoun-ஐ தேர்வு செய்: ___ என் சகோதரி.",
      "options": ["He", "She", "It", "They"],
      "correctIndex": 1
    }
  ]
}
```

### Local Storage Structure

Progress data stored in SharedPreferences with key `user_progress`:

```json
{
  "phase1_lesson1": {
    "lessonId": "phase1_lesson1",
    "explainDone": true,
    "examplesDone": true,
    "listeningScore": 0.8,
    "speakingScore": 0.85,
    "quizBestScore": 0.9,
    "masteryBestScore": 0.9,
    "isMastered": true,
    "lastAccessed": "2025-11-24T10:30:00.000Z"
  },
  "phase1_lesson2": {
    "lessonId": "phase1_lesson2",
    "explainDone": false,
    "examplesDone": false,
    "listeningScore": 0.0,
    "speakingScore": 0.0,
    "quizBestScore": 0.0,
    "masteryBestScore": 0.0,
    "isMastered": false,
    "lastAccessed": null
  }
}
```

User settings stored with key `user_settings`:

```json
{
  "selectedLevel": "beginner",
  "hasCompletedOnboarding": true,
  "lastAccessedLessonId": "phase1_lesson1"
}
```

## Error Handling

### Error Types

1. **Asset Loading Errors**: JSON file not found or malformed
2. **Storage Errors**: SharedPreferences read/write failures
3. **TTS Errors**: Text-to-speech initialization or playback failures
4. **State Errors**: Invalid state transitions

### Error Handling Strategy

#### Asset Loading

```dart
try {
  final lesson = await lessonRepository.loadLesson(lessonId);
  return lesson;
} on AssetNotFoundException catch (e) {
  // Log error and show user-friendly message
  logger.error('Lesson asset not found: $lessonId');
  throw LessonLoadException('Unable to load lesson content');
} on JsonParseException catch (e) {
  // Log error and show user-friendly message
  logger.error('Invalid lesson JSON: $lessonId');
  throw LessonLoadException('Lesson content is corrupted');
}
```

#### Storage Errors

```dart
try {
  await progressRepository.saveLessonProgress(status);
} on StorageException catch (e) {
  // Log error, retry once, then show error to user
  logger.error('Failed to save progress: ${e.message}');
  // Retry logic
  try {
    await progressRepository.saveLessonProgress(status);
  } catch (retryError) {
    // Show user error message
    showErrorSnackbar('Unable to save progress. Please try again.');
  }
}
```

#### TTS Errors

```dart
try {
  await audioService.speak(text);
} on TtsException catch (e) {
  // Log error and show message
  logger.error('TTS failed: ${e.message}');
  showErrorSnackbar('Audio playback unavailable');
  // Continue without audio
}
```

### User-Facing Error Messages

- **Lesson Load Failure**: "Unable to load lesson. Please restart the app."
- **Progress Save Failure**: "Progress not saved. Please try again."
- **Audio Unavailable**: "Audio playback is currently unavailable."
- **Locked Lesson**: "Please master the previous lesson first."

## Testing Strategy

### Unit Tests

#### Model Tests
- JSON serialization/deserialization for all models
- Validation logic in models
- Computed properties (e.g., `isUnlocked`)

#### Repository Tests
- Lesson loading from assets
- Progress loading/saving to storage
- Cache management
- Error handling for missing/malformed data

#### Service Tests
- Storage service CRUD operations
- Mastery calculation logic
- Unlock logic based on progress
- Audio service initialization and playback

### Widget Tests

#### Screen Tests
- OnboardingScreen: level selection and navigation
- HomeScreen: display of progress and navigation
- Phase1UnitScreen: lesson list rendering and status display
- LessonScreen: tab navigation and bottom bar behavior

#### Tab Widget Tests
- ExplainTab: content display and completion tracking
- ExamplesTab: audio playback and completion tracking
- ListenTab: question display, answer selection, scoring
- SpeakTab: mock score generation and display
- PracticeTab: quiz flow and scoring
- MasteryTab: test flow and mastery marking

### Integration Tests

#### User Flows
1. **First-time user flow**:
   - Launch app → Onboarding → Select level → Home → Start Learning → Lesson 1
   
2. **Lesson completion flow**:
   - Open Lesson 1 → Complete all tabs → Pass mastery test → Unlock Lesson 2
   
3. **Progress persistence flow**:
   - Complete partial lesson → Close app → Reopen → Verify progress restored

4. **Locked lesson flow**:
   - Attempt to open Lesson 2 without mastering Lesson 1 → See locked message

### Test Data

Create test fixtures for:
- Sample lessons with all tab content
- Various progress states (new, in-progress, mastered)
- Edge cases (empty lessons, missing fields)

## UI/UX Design Specifications

### Theme

```dart
ThemeData(
  primaryColor: Color(0xFF4CAF50),  // Green for success/mastery
  accentColor: Color(0xFF2196F3),   // Blue for interactive elements
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  fontFamily: 'Roboto',
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headline2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyText1: TextStyle(fontSize: 18),
    bodyText2: TextStyle(fontSize: 16),
  ),
)
```

### Screen Layouts

#### OnboardingScreen
- Centered content with app logo at top
- Level selection cards in vertical list
- Large "Continue" button at bottom
- Minimum touch target: 48x48 dp

#### HomeScreen
- App title/logo at top
- Progress summary card showing "X / 6 lessons mastered"
- "Continue" card (if applicable) with lesson title and thumbnail
- Large "Start Learning" button
- Bottom navigation (optional for Phase 1)

#### Phase1UnitScreen
- AppBar with "Phase 1" title
- ScrollView with lesson cards
- Each card shows:
  - Lesson number and title
  - Short description
  - Status badge (Locked/In Progress/Mastered)
  - Progress indicator
- Cards use elevation for depth

#### LessonScreen
- AppBar with lesson title and progress (e.g., "2/6")
- TabBar with 6 tabs (icons + labels)
- TabBarView with tab content
- Bottom navigation bar with Previous/Next buttons
- Buttons disabled state clearly visible

### Icons

- Audio: `Icons.volume_up`
- Microphone: `Icons.mic`
- Correct answer: `Icons.check_circle` (green)
- Incorrect answer: `Icons.cancel` (red)
- Locked: `Icons.lock`
- In Progress: `Icons.play_circle_outline`
- Mastered: `Icons.check_circle` (gold/green)

### Animations

- Tab transitions: Slide animation (300ms)
- Button press: Scale animation (100ms)
- Correct/incorrect feedback: Fade + scale (200ms)
- Progress updates: Linear progress animation (500ms)

## Performance Considerations

### Asset Loading
- Lazy load lessons (only load when needed)
- Cache parsed JSON in memory during session
- Preload next lesson in background

### Storage
- Batch progress updates (save on tab completion, not every action)
- Use debouncing for frequent updates
- Implement retry logic with exponential backoff

### TTS
- Initialize TTS engine once at app startup
- Reuse TTS instance across screens
- Queue audio requests to prevent overlapping

### Memory Management
- Dispose providers when screens are popped
- Clear lesson cache when memory pressure detected
- Limit cached lessons to 3 most recent

## Future Extensibility

### Phase 2 Preparation

The design supports future enhancements:

1. **Backend Integration**
   - Repository pattern allows easy swap to network data source
   - Progress sync to cloud storage
   - User authentication

2. **Real STT Integration**
   - SpeakTab already structured for score replacement
   - Audio recording infrastructure can be added to AudioService

3. **Additional Content**
   - JSON structure supports new lesson types
   - New tabs can be added to TabBar
   - New question types supported by QuizQuestion model

4. **Analytics**
   - Event tracking can be added to services
   - Progress data structure supports detailed analytics

5. **Gamification**
   - Points/badges can be added to UserLessonStatus
   - Leaderboards can use existing progress data

### Scalability Considerations

- Lesson content can grow to hundreds of lessons
- Progress data structure scales linearly with lesson count
- Asset loading strategy supports lazy loading for large content libraries
- Storage service can be swapped for Hive or SQLite for better performance with large datasets
