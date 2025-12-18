# Design Document

## Overview

This design covers two distinct features: (1) Phase 3 Final Test - a comprehensive 30-question assessment validating students' mastery of all Phase 3 content (Units 12-17: Story Listening & Retelling, Complex Sentences & Connectors, Passive Voice, Reported Speech, Functional English, and Speaking & Writing Projects), and (2) Debug Mode - a developer-only tool for bypassing gating logic and testing all features. The Phase 3 Final Test uses only MCQ-based text questions (no STT/audio), provides unit-level performance breakdown, and unlocks Phase 4 upon passing (24/30 or 80%). Debug Mode allows one-tap unlocking of all phases/lessons and complete progress reset. Both features integrate with the existing Flutter app architecture using Provider for state management and SharedPreferences for persistence.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Phase3 Final │  │   Result     │  │   Review     │      │
│  │ Test Screen  │  │   Screen     │  │   Screen     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│  ┌──────┴──────────────────┼──────────────────┘              │
│  │                         │                                 │
│  │                ┌────────▼────────┐                        │
│  │                │ Phase3 Final    │                        │
│  │                │ Test Provider   │                        │
│  │                └─────────────────┘                        │
│  │                                                            │
│  │      ┌──────────────┐                                     │
│  │      │    Debug     │                                     │
│  │      │    Screen    │                                     │
│  │      └──────┬───────┘                                     │
│  │             │                                              │
│  │    ┌────────▼────────┐                                    │
│  │    │     Debug       │                                    │
│  │    │    Provider     │                                    │
│  │    └─────────────────┘                                    │
└────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                     Service Layer                             │
│         ┌──────────────────┼──────────────────┐               │
│         │                  │                  │               │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐       │
│  │ Phase3 Final │  │    Debug     │  │   Gating     │       │
│  │ Test Service │  │   Service    │  │   Service    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                      Data Layer                               │
│         ┌──────────────────┼──────────────────┐               │
│         │                  │                  │               │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐       │
│  │   Lesson     │  │   Storage    │  │ Phase3 Final │       │
│  │  Repository  │  │   Service    │  │ Test Question│       │
│  │  (existing)  │  │  (existing)  │  │    Model     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```


### Component Responsibilities

**Presentation Layer:**
- **Phase3FinalTestScreen**: Main test interface displaying questions and handling user input
- **Phase3FinalTestResultScreen**: Displays test score, accuracy, unit-level breakdown, and navigation options
- **Phase3FinalTestReviewScreen**: Shows incorrect answers with correct solutions
- **Phase3FinalTestProvider**: Manages test state, question navigation, and answer tracking
- **DebugScreen**: Developer interface for enabling debug mode, unlocking content, and resetting progress
- **DebugProvider**: Manages debug mode state and operations

**Service Layer:**
- **Phase3FinalTestService**: Generates randomized tests with unit distribution, validates answers, and calculates scores with unit breakdown
- **DebugService**: Handles debug mode operations including unlock all and reset all functionality
- **GatingService**: Centralized service for checking access permissions with debug mode bypass

**Data Layer:**
- **Phase3FinalTestQuestion**: Model representing a single test question with unit tracking
- **LessonRepository**: Loads lesson JSON files (existing component)
- **StorageService**: Persists test results and debug mode settings (existing component)

## Components and Interfaces

### 1. Data Models

#### Phase3FinalTestQuestion Model

```dart
class Phase3FinalTestQuestion {
  final String id;                 // Unique identifier
  final String unitId;             // "unit12", "unit13", "unit14", "unit15", "unit16", "unit17"
  final String lessonId;           // e.g., "lesson13_1_connectors_and"
  final String lessonTitle;        // e.g., "Connectors: And"
  final String promptEn;           // English question text
  final String? promptTa;          // Tamil question text (optional)
  final List<String> options;      // Four answer options
  final int correctIndex;          // Index of correct answer (0-3)
  final String questionType;       // "story_comprehension", "connector", "transformation"
  
  Phase3FinalTestQuestion({
    required this.id,
    required this.unitId,
    required this.lessonId,
    required this.lessonTitle,
    required this.promptEn,
    this.promptTa,
    required this.options,
    required this.correctIndex,
    this.questionType = 'mcq',
  });
  
  factory Phase3FinalTestQuestion.fromLessonQuestion(
    Map<String, dynamic> json,
    String lessonId,
    String lessonTitle,
    String unitId,
  );
  
  Map<String, dynamic> toJson();
  factory Phase3FinalTestQuestion.fromJson(Map<String, dynamic> json);
}
```


#### Phase3TestResult Model

```dart
class Phase3TestResult {
  final int totalQuestions;        // Always 30
  final int correctAnswers;        // Number of correct answers
  final int incorrectAnswers;      // Number of incorrect answers
  final double accuracy;           // Percentage (0-100)
  final bool passed;               // True if score >= 24
  final DateTime completedAt;      // Timestamp of completion
  final Map<String, UnitPerformance> unitBreakdown;  // Per-unit performance
  final List<IncorrectAnswer> incorrectQuestionDetails;
  
  Phase3TestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.passed,
    required this.completedAt,
    required this.unitBreakdown,
    required this.incorrectQuestionDetails,
  });
  
  Map<String, dynamic> toJson();
  factory Phase3TestResult.fromJson(Map<String, dynamic> json);
}
```

### 2. Service Layer

#### Phase3FinalTestService

```dart
class Phase3FinalTestService {
  final LessonRepository _lessonRepository;
  final StorageService _storageService;
  
  static const String _keyTestPassed = 'phase3_final_test_passed';
  static const String _keyTestScore = 'phase3_final_test_score';
  static const String _keyTestDate = 'phase3_final_test_taken_at';
  static const String _keyTestResult = 'phase3_final_test_result';
  static const String _keyPhase4Unlocked = 'phase4_unlocked';
  
  // Question distribution by unit
  static const Map<String, int> _unitDistribution = {
    'unit12': 6,   // Story Listening & Retelling
    'unit13': 7,   // Complex Sentences & Connectors
    'unit14': 5,   // Passive Voice
    'unit15': 5,   // Reported Speech
    'unit16': 4,   // Functional English
    'unit17': 3,   // Speaking & Writing Projects
  };
  
  static const int _passingScore = 24;
  static const int _totalQuestions = 30;
  
  Future<List<Phase3FinalTestQuestion>> generateTest();
  Future<List<Phase3FinalTestQuestion>> _loadUnitQuestions(String unitId, int count);
  bool validateAnswer(Phase3FinalTestQuestion question, int selectedIndex);
  Phase3TestResult calculateResult(List<Phase3FinalTestQuestion> questions, List<int?> selectedAnswers);
  Future<void> saveTestResult(Phase3TestResult result);
  Future<Phase3TestResult?> loadTestResult();
  Future<bool> hasPassedTest();
  Future<int?> getLastTestScore();
  Future<bool> areAllPhase3LessonsMastered();
  Future<void> clearTestData();
}
```


#### DebugService

```dart
class DebugService {
  final StorageService _storageService;
  final ProgressRepository _progressRepository;
  
  static const String _keyDebugMode = 'debug_mode_enabled';
  static const int _activationTapCount = 5;
  
  DebugService({
    required StorageService storageService,
    required ProgressRepository progressRepository,
  }) : _storageService = storageService,
       _progressRepository = progressRepository;
  
  /// Check if debug mode is enabled
  Future<bool> isDebugModeEnabled();
  
  /// Enable or disable debug mode
  Future<void> setDebugMode(bool enabled);
  
  /// Unlock all phases and mark all lessons as mastered
  Future<void> unlockAll();
  
  /// Reset all progress to fresh state
  Future<void> resetAll();
  
  /// Get all lesson IDs across all phases
  List<String> _getAllLessonIds();
}
```

#### GatingService

```dart
class GatingService {
  final StorageService _storageService;
  final ProgressRepository _progressRepository;
  final DebugService _debugService;
  
  GatingService({
    required StorageService storageService,
    required ProgressRepository progressRepository,
    required DebugService debugService,
  }) : _storageService = storageService,
       _progressRepository = progressRepository,
       _debugService = debugService;
  
  /// Check if a phase is unlocked (with debug mode bypass)
  Future<bool> isPhaseUnlocked(int phaseNumber);
  
  /// Check if a lesson is unlocked (with debug mode bypass)
  Future<bool> isLessonUnlocked(String lessonId);
  
  /// Check if final test is accessible (with debug mode bypass)
  Future<bool> isFinalTestAccessible(int phaseNumber);
}
```

### 3. State Management

#### Phase3FinalTestProvider

```dart
class Phase3FinalTestProvider extends ChangeNotifier {
  final Phase3FinalTestService _testService;
  
  List<Phase3FinalTestQuestion> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  Phase3TestResult? _testResult;
  
  // Getters
  List<Phase3FinalTestQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Phase3FinalTestQuestion? get currentQuestion;
  int? get selectedAnswer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Phase3TestResult? get testResult => _testResult;
  int get totalQuestions => 30;
  double get progress => (_currentQuestionIndex + 1) / totalQuestions;
  bool get isLastQuestion => _currentQuestionIndex == 29;
  bool get canProceed => selectedAnswer != null;
  
  Future<void> startTest();
  void selectAnswer(int index);
  void skipQuestion();
  void nextQuestion();
  Future<void> submitTest();
  void resetTest();
  Future<bool> canTakeTest();
}
```


#### DebugProvider

```dart
class DebugProvider extends ChangeNotifier {
  final DebugService _debugService;
  
  bool _isDebugModeEnabled = false;
  bool _isProcessing = false;
  String? _statusMessage;
  
  bool get isDebugModeEnabled => _isDebugModeEnabled;
  bool get isProcessing => _isProcessing;
  String? get statusMessage => _statusMessage;
  
  DebugProvider({required DebugService debugService})
      : _debugService = debugService;
  
  /// Initialize and load debug mode state
  Future<void> initialize();
  
  /// Toggle debug mode on/off
  Future<void> toggleDebugMode(bool enabled);
  
  /// Unlock all phases and lessons
  Future<void> unlockAll();
  
  /// Reset all progress
  Future<void> resetAll();
  
  /// Clear status message
  void clearStatus();
}
```

### 4. Presentation Layer

#### Phase3FinalTestScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  ├─ Title: "Phase 3 – Final Test"
  └─ Subtitle: "Real-Life Communication Check"

Body
  ├─ Progress Section
  │   ├─ Question Counter: "Question X / 30"
  │   └─ Progress Bar: [█████████---------] Y%
  │
  ├─ Question Section (Scrollable)
  │   ├─ Question Text (promptEn)
  │   └─ Options List
  │       ├─ ○ Option A
  │       ├─ ○ Option B
  │       ├─ ○ Option C
  │       └─ ○ Option D
  │
  └─ Navigation Section
      ├─ [ Skip ] (secondary button)
      └─ [ Next ▶ ] (primary button, enabled when selected)
```

**Key Features:**
- Radio button selection with visual feedback
- Disabled Next button until answer selected
- Optional Skip button for flexibility
- Smooth transitions between questions
- Progress bar with percentage display


#### Phase3FinalTestResultScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  └─ Title: "Test Results"

Body (Scrollable)
  ├─ Status Icon (🎉 or ❌)
  ├─ Title: "Phase 3 Final Test Completed!"
  ├─ Score: "Score: X / 30"
  ├─ Accuracy: "Accuracy: Y%"
  │
  ├─ Breakdown Section
  │   ├─ "Breakdown:"
  │   ├─ "- Stories & Retelling: X / 6"
  │   ├─ "- Connectors & Complex Sent.: X / 7"
  │   ├─ "- Passive Voice: X / 5"
  │   ├─ "- Reported Speech: X / 5"
  │   ├─ "- Functional English: X / 4"
  │   └─ "- Projects & General Use: X / 3"
  │
  ├─ Status Message
  │   └─ PASSED ✅ / NOT PASSED ❌
  │
  └─ Action Buttons
      ├─ [ Review Mistakes ]
      └─ [ Continue ] or [ Retry Test ]
```

**Conditional Rendering:**
- Show "PASSED ✅" if score >= 24
- Show "NOT PASSED ❌" if score < 24
- Show "Continue" button only if passed
- Show "Retry Test" button if failed
- Color-code unit performance

#### Phase3FinalTestReviewScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  └─ Title: "Review Mistakes"

Body (ListView)
  ├─ "Incorrect Answers:"
  │
  ├─ Question 1
  │   ├─ "Q3: [Question Text]"
  │   ├─ "Correct: [Correct Answer]"
  │   └─ "You chose: [Your Answer]"
  │
  ├─ Question 2
  │   └─ ...
  │
  └─ [ Back to Results ]
```

**Color Coding:**
- Incorrect answer: Red (#FFEBEE background, #C62828 text)
- Correct answer: Green (#E8F5E9 background, #2E7D32 text)


#### DebugScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  └─ Title: "Debug Mode"

Body (Centered Column)
  ├─ Debug Mode Section
  │   ├─ "Debug Mode"
  │   └─ [ ] Enable Debug Mode (Switch)
  │
  ├─ Actions Section
  │   ├─ [ Unlock All Phases & Lessons ]
  │   └─ [ Reset All Progress ]
  │
  ├─ Status Message (if any)
  │   └─ "✓ All content unlocked successfully"
  │
  └─ [ Close ]
```

**Activation Method:**
- Long-press app title on Home Screen 5 times consecutively
- Shows hidden "Debug" button or navigation option
- Alternative: Enter code "DEBUG123" in settings (optional)

**Debug Mode Indicator:**
- When enabled, show "Debug Mode ON" or "DEV" label in Home Screen app bar
- Small, unobtrusive indicator

### 5. Key Algorithms

#### Test Generation Algorithm

```
1. Load all Phase 3 lessons from assets/lessons/phase3/
2. Group lessons by unit:
   - unit12: lesson13_1 to lesson13_5 (Story patterns)
   - unit13: lesson13_1 to lesson13_5 (Connectors)
   - unit14: lesson14_1 to lesson14_4 (Passive)
   - unit15: lesson15_1 to lesson15_4 (Reported)
   - unit16: lesson16_1 to lesson16_5 (Functional)
   - unit17: lesson17_1 to lesson17_5 (Projects)
3. For each unit:
   a. Extract practiceQuestions + masteryQuestions
   b. Randomly select required count:
      - Unit 12: 6 questions
      - Unit 13: 7 questions
      - Unit 14: 5 questions
      - Unit 15: 5 questions
      - Unit 16: 4 questions
      - Unit 17: 3 questions
   c. Tag each with unitId
4. Combine all 30 questions
5. Shuffle the list
6. Return shuffled list
```

#### Unlock All Algorithm

```
1. Set phase flags:
   - phase1FinalTestPassed = true
   - phase2FinalTestPassed = true
   - phase3FinalTestPassed = true
   - phase2Unlocked = true
   - phase3Unlocked = true
   - phase4Unlocked = true
2. Get all lesson IDs:
   - Phase 1: lesson1 to lesson6
   - Phase 2: lesson7_1 to lesson11_5
   - Phase 3: lesson13_1 to lesson17_5
3. For each lesson:
   - Create/update UserLessonStatus:
     * isMastered = true
     * masteryBestScore = 1.0
     * quizBestScore = 1.0
     * timesAttempted = 1
     * completedAt = now()
4. Save all changes
5. Notify listeners to refresh UI
```


#### Reset All Algorithm

```
1. Clear all UserLessonStatus data
2. Reset phase flags:
   - phase1FinalTestPassed = false
   - phase2FinalTestPassed = false
   - phase3FinalTestPassed = false
   - phase2Unlocked = false
   - phase3Unlocked = false
   - phase4Unlocked = false
3. Clear all test scores and dates
4. Set debugModeEnabled = false
5. Save all changes
6. Notify listeners to refresh UI
7. Optionally navigate to onboarding
```

#### Gating Logic with Debug Bypass

```
function isPhaseUnlocked(phaseNumber):
  if debugModeEnabled:
    return true
  
  if phaseNumber == 1:
    return true
  if phaseNumber == 2:
    return phase1FinalTestPassed
  if phaseNumber == 3:
    return phase2FinalTestPassed
  if phaseNumber == 4:
    return phase3FinalTestPassed
  
  return false
```

## Data Models

### Unit Distribution Map

```dart
const Map<String, int> unitDistribution = {
  'unit12': 6,   // Story Listening & Retelling
  'unit13': 7,   // Complex Sentences & Connectors
  'unit14': 5,   // Passive Voice
  'unit15': 5,   // Reported Speech
  'unit16': 4,   // Functional English
  'unit17': 3,   // Speaking & Writing Projects
};

const Map<String, String> unitNames = {
  'unit12': 'Stories & Retelling',
  'unit13': 'Connectors & Complex Sent.',
  'unit14': 'Passive Voice',
  'unit15': 'Reported Speech',
  'unit16': 'Functional English',
  'unit17': 'Projects & General Use',
};
```

### Storage Schema

**SharedPreferences Keys:**

Phase 3 Final Test:
- `phase3_final_test_passed`: bool
- `phase3_final_test_score`: int (0-30)
- `phase3_final_test_taken_at`: String (ISO 8601)
- `phase3_final_test_result`: String (JSON)
- `phase4_unlocked`: bool

Debug Mode:
- `debug_mode_enabled`: bool


## Error Handling

### Error Scenarios

1. **Lesson Loading Failure**
   - Scenario: Phase 3 JSON file missing or corrupted
   - Handling: Log error, show user message, allow retry
   - Message: "Failed to load test content. Please try again."

2. **Insufficient Questions**
   - Scenario: Unit has fewer questions than required
   - Handling: Reuse available questions, log warning
   - Message: None (graceful degradation)

3. **Storage Failure**
   - Scenario: SharedPreferences write fails
   - Handling: Log error, notify user
   - Message: "Unable to save results. Progress may not be saved."

4. **Debug Mode Activation Failure**
   - Scenario: Storage error when enabling debug mode
   - Handling: Show error message, keep mode disabled
   - Message: "Failed to enable debug mode."

5. **Unlock All Failure**
   - Scenario: Error during mass unlock operation
   - Handling: Rollback changes, show error
   - Message: "Failed to unlock content. Please try again."

### Error Recovery

```dart
Future<void> unlockAll() async {
  try {
    _isProcessing = true;
    notifyListeners();
    
    // Perform unlock operations
    await _unlockPhases();
    await _unlockLessons();
    
    _statusMessage = 'All content unlocked successfully';
  } catch (e) {
    _statusMessage = 'Failed to unlock: $e';
    // Attempt rollback if possible
  } finally {
    _isProcessing = false;
    notifyListeners();
  }
}
```

## Testing Strategy

### Unit Tests

1. **Phase3FinalTestQuestion Model**
   - JSON serialization/deserialization
   - Factory constructor validation
   - Field validation

2. **Phase3FinalTestService**
   - Test generation with mocked data
   - Unit distribution (6-7-5-5-4-3)
   - Answer validation
   - Result calculation with unit breakdown
   - Storage operations
   - Phase 4 unlock logic

3. **DebugService**
   - Debug mode enable/disable
   - Unlock all functionality
   - Reset all functionality
   - Lesson ID collection

4. **GatingService**
   - Phase unlock checks with debug bypass
   - Lesson unlock checks with debug bypass
   - Final test access checks


### Widget Tests

1. **Phase3FinalTestScreen**
   - Initial render with loading
   - Question display
   - Option selection
   - Next/Skip button behavior
   - Progress bar updates

2. **Phase3FinalTestResultScreen**
   - Score display
   - Unit breakdown display
   - Pass/fail status
   - Button rendering (pass vs fail)

3. **Phase3FinalTestReviewScreen**
   - Incorrect answer display
   - Color coding
   - Empty state (perfect score)

4. **DebugScreen**
   - Debug mode toggle
   - Unlock all button
   - Reset all button
   - Status message display

### Integration Tests

1. **Complete Test Flow**
   - Start test → Answer questions → View results → Review mistakes
   - Retry flow after failure
   - Phase 4 unlock after passing

2. **Debug Mode Flow**
   - Activate debug mode → Unlock all → Verify UI updates
   - Reset all → Verify fresh state

3. **Gating Logic**
   - Verify locks with debug mode off
   - Verify bypass with debug mode on

## UI/UX Specifications

### Typography

- **Question Text**: 18sp, FontWeight.w500, #212121
- **Option Text**: 16sp, FontWeight.w400, #424242
- **Progress Text**: 14sp, FontWeight.w500, #757575
- **Score Text**: 32sp, FontWeight.bold, #1976D2 (pass) / #D32F2F (fail)
- **Unit Breakdown**: 16sp, FontWeight.w500, #424242
- **Debug Label**: 12sp, FontWeight.w600, #FF5722

### Spacing

- **Screen Padding**: 16px horizontal, 24px vertical
- **Question Section**: 20px padding
- **Option Spacing**: 12px between options
- **Button Margin**: 16px top
- **Section Spacing**: 24px between sections

### Colors

- **Primary**: #1976D2 (Blue)
- **Success**: #2E7D32 (Green)
- **Error**: #C62828 (Red)
- **Warning**: #F57C00 (Orange)
- **Debug**: #FF5722 (Deep Orange)
- **Background**: #FAFAFA
- **Card**: #FFFFFF
- **Selected**: #E3F2FD (Light Blue)

### Animations

- **Question Transition**: Fade + Slide (300ms)
- **Progress Bar**: Linear (200ms)
- **Button Press**: Scale (100ms)
- **Result Entry**: Fade + Scale (400ms)


## Integration Points

### 1. Routing Integration

Add to `lib/app/routes.dart`:
```dart
static const String phase3FinalTest = '/phase3/finalTest';
static const String phase3FinalTestResult = '/phase3/finalTest/result';
static const String phase3FinalTestReview = '/phase3/finalTest/review';
static const String debug = '/debug';
```

### 2. Home Screen Integration

**Debug Mode Activation:**
```dart
int _titleTapCount = 0;
DateTime? _lastTapTime;

void _onTitleTap() {
  final now = DateTime.now();
  if (_lastTapTime != null && now.difference(_lastTapTime!) > Duration(seconds: 2)) {
    _titleTapCount = 0;
  }
  
  _titleTapCount++;
  _lastTapTime = now;
  
  if (_titleTapCount >= 5) {
    Navigator.pushNamed(context, AppRoutes.debug);
    _titleTapCount = 0;
  }
}
```

**Debug Mode Indicator:**
```dart
AppBar(
  title: Column(
    children: [
      Text('Engliya'),
      if (debugModeEnabled)
        Text('Debug Mode ON', style: TextStyle(fontSize: 10, color: Colors.deepOrange)),
    ],
  ),
)
```

### 3. Phase3LessonListScreen Integration

Add final test card:
```dart
if (await _testService.areAllPhase3LessonsMastered()) {
  Phase3FinalTestCard(
    onTap: () => Navigator.pushNamed(context, AppRoutes.phase3FinalTest),
    isPassed: await _testService.hasPassedTest(),
  );
}
```

### 4. Provider Registration

Add to `main.dart`:
```dart
MultiProvider(
  providers: [
    // Existing providers...
    ChangeNotifierProvider(
      create: (_) => Phase3FinalTestProvider(
        testService: Phase3FinalTestService(
          lessonRepository: LessonRepository(),
          storageService: storageService,
        ),
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => DebugProvider(
        debugService: DebugService(
          storageService: storageService,
          progressRepository: progressRepository,
        ),
      ),
    ),
  ],
  child: MyApp(),
)
```

### 5. Gating Logic Updates

Update all gating checks to use GatingService:
```dart
// Before
final phase2Unlocked = await _storageService.getBool('phase2_unlocked') ?? false;

// After
final phase2Unlocked = await _gatingService.isPhaseUnlocked(2);
```

## Performance Considerations

1. **Lazy Loading**: Load Phase 3 lessons only when generating test
2. **Caching**: Use LessonRepository's built-in caching
3. **Batch Operations**: Unlock all lessons in batch, not individually
4. **Memory Management**: Clear question list after test completion
5. **Async Operations**: Use FutureBuilder for async loading
6. **State Optimization**: Selective notifyListeners() calls

## Accessibility

1. **Semantic Labels**: All interactive elements
2. **Screen Reader**: Announce question changes and results
3. **Touch Targets**: Minimum 48x48 logical pixels
4. **Color Contrast**: 4.5:1 ratio for all text
5. **Focus Management**: Proper keyboard navigation
6. **Debug Mode**: Clearly announce when enabled

## Security Considerations

1. **Debug Mode Protection**: Hidden activation method
2. **Data Validation**: Validate all inputs and stored data
3. **Tampering Prevention**: Validate test integrity (future)
4. **Storage Encryption**: Consider for sensitive data (future)

## Future Enhancements

1. **Analytics**: Track test performance by unit
2. **Adaptive Testing**: Adjust difficulty based on performance
3. **Timed Mode**: Optional time limits
4. **Detailed Analytics**: Performance by specific topics
5. **Certificate Generation**: Phase 3 completion certificates
6. **Debug Mode Enhancements**: More granular control options
7. **Question Type Indicators**: Show question type in UI
8. **Unit-Specific Retry**: Retry test for weak units only
