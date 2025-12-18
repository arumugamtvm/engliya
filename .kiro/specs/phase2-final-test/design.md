# Design Document

## Overview

The Phase 2 Final Mastery Test is a comprehensive assessment feature that validates students' understanding of all five Phase 2 units (Units 7-11). The feature consists of four main components: a test generation service that creates randomized 25-question tests from existing Phase 2 lesson content with proper unit distribution, a test screen for answering questions, a result screen with unit-level performance breakdown for displaying performance, and a review screen for examining incorrect answers. The system integrates with the existing Flutter app architecture using Provider for state management, follows the repository pattern for data access, and uses SharedPreferences for local persistence. Upon passing with 80% or higher (20/25 questions), the test unlocks Phase 3 content.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Phase2 Final │  │   Result     │  │   Review     │      │
│  │ Test Screen  │  │   Screen     │  │   Screen     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                        │
│                   │ Phase2 Final    │                        │
│                   │ Test Provider   │                        │
│                   └────────┬────────┘                        │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                     Service Layer                             │
│                   ┌────────▼────────┐                         │
│                   │ Phase2 Final    │                         │
│                   │  Test Service   │                         │
│                   └────────┬────────┘                         │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                      Data Layer                               │
│         ┌──────────────────┼──────────────────┐               │
│         │                  │                  │               │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐       │
│  │   Lesson     │  │   Storage    │  │ Phase2 Final │       │
│  │  Repository  │  │   Service    │  │ Test Question│       │
│  │  (existing)  │  │  (existing)  │  │    Model     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

**Presentation Layer:**
- **Phase2FinalTestScreen**: Main test interface displaying questions and handling user input
- **Phase2FinalTestResultScreen**: Displays test score, accuracy, unit-level breakdown, and navigation options
- **Phase2FinalTestReviewScreen**: Shows incorrect answers with correct solutions
- **Phase2FinalTestProvider**: Manages test state, question navigation, and answer tracking

**Service Layer:**
- **Phase2FinalTestService**: Generates randomized tests with unit distribution, validates answers, and calculates scores with unit breakdown

**Data Layer:**
- **Phase2FinalTestQuestion**: Model representing a single test question with unit tracking
- **LessonRepository**: Loads lesson JSON files (existing component)
- **StorageService**: Persists test results (existing component)


## Components and Interfaces

### 1. Data Models

#### Phase2FinalTestQuestion Model

```dart
class Phase2FinalTestQuestion {
  final String id;                 // Unique identifier
  final String unitId;             // e.g., "unit7", "unit8", "unit9", "unit10", "unit11"
  final String lessonId;           // e.g., "lesson7_1_time_prepositions"
  final String lessonTitle;        // e.g., "Time Prepositions"
  final String promptEn;           // English question text
  final String? promptTa;          // Tamil question text (optional)
  final List<String> options;      // Four answer options
  final int correctIndex;          // Index of correct answer (0-3)
  final String questionType;       // "mcq", "fill_blank", "sentence_choice", etc.
  
  Phase2FinalTestQuestion({
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
  
  // Factory constructor from lesson question JSON
  factory Phase2FinalTestQuestion.fromLessonQuestion(
    Map<String, dynamic> json,
    String lessonId,
    String lessonTitle,
    String unitId,
  );
  
  // Serialization methods
  Map<String, dynamic> toJson();
  factory Phase2FinalTestQuestion.fromJson(Map<String, dynamic> json);
}
```

#### Phase2TestResult Model

```dart
class Phase2TestResult {
  final int totalQuestions;        // Always 25
  final int correctAnswers;        // Number of correct answers
  final int incorrectAnswers;      // Number of incorrect answers
  final double accuracy;           // Percentage (0-100)
  final bool passed;               // True if score >= 20
  final DateTime completedAt;      // Timestamp of completion
  final Map<String, UnitPerformance> unitBreakdown;  // Per-unit performance
  final List<IncorrectAnswer> incorrectQuestionDetails;
  
  Phase2TestResult({
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
  factory Phase2TestResult.fromJson(Map<String, dynamic> json);
}
```

#### UnitPerformance Model

```dart
class UnitPerformance {
  final String unitId;             // e.g., "unit7"
  final String unitName;           // e.g., "Time & Place"
  final int totalQuestions;        // Questions from this unit
  final int correctAnswers;        // Correct answers for this unit
  final double accuracy;           // Unit-specific accuracy percentage
  
  UnitPerformance({
    required this.unitId,
    required this.unitName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
  });
  
  Map<String, dynamic> toJson();
  factory UnitPerformance.fromJson(Map<String, dynamic> json);
}
```


### 2. Service Layer

#### Phase2FinalTestService

```dart
class Phase2FinalTestService {
  final LessonRepository _lessonRepository;
  final StorageService _storageService;
  
  // Storage keys
  static const String _keyTestPassed = 'phase2_final_test_passed';
  static const String _keyTestScore = 'phase2_final_test_score';
  static const String _keyTestDate = 'phase2_final_test_taken_at';
  static const String _keyTestResult = 'phase2_final_test_result';
  static const String _keyPhase3Unlocked = 'phase3_unlocked';
  
  // Question distribution by unit
  static const Map<String, int> _unitDistribution = {
    'unit7': 5,   // Time & Place Prepositions
    'unit8': 6,   // Continuous Tenses
    'unit9': 5,   // Perfect Tenses
    'unit10': 5,  // Questions & Negatives
    'unit11': 4,  // Advanced Pronouns, Adjectives & Adverbs
  };
  
  // Lesson mapping to units
  static const Map<String, String> _lessonToUnit = {
    'lesson7_1_time_prepositions': 'unit7',
    'lesson7_2_place_prepositions': 'unit7',
    'lesson7_3_time_expressions': 'unit7',
    'lesson8_1_present_continuous': 'unit8',
    'lesson8_2_past_continuous': 'unit8',
    'lesson8_3_future_continuous': 'unit8',
    'lesson8_4_continuous_conversations': 'unit8',
    'lesson9_1_present_perfect': 'unit9',
    'lesson9_2_past_perfect': 'unit9',
    'lesson9_3_future_perfect': 'unit9',
    'lesson9_4_present_perfect_continuous': 'unit9',
    'lesson9_5_perfect_vs_past': 'unit9',
    'lesson10_1_be_questions': 'unit10',
    'lesson10_2_do_does_did_questions': 'unit10',
    'lesson10_3_wh_questions': 'unit10',
    'lesson10_4_negatives': 'unit10',
    'lesson10_5_real_qa': 'unit10',
    'lesson11_1_possessive_pronouns': 'unit11',
    'lesson11_2_reflexive_pronouns': 'unit11',
    'lesson11_3_demonstrative_pronouns': 'unit11',
    'lesson11_4_adjectives': 'unit11',
    'lesson11_5_adverbs': 'unit11',
  };
  
  static const int _passingScore = 20;
  static const int _totalQuestions = 25;
  
  Phase2FinalTestService({
    required LessonRepository lessonRepository,
    required StorageService storageService,
  }) : _lessonRepository = lessonRepository,
       _storageService = storageService;
  
  /// Generate a randomized test with 25 questions
  /// Distribution: Unit7(5), Unit8(6), Unit9(5), Unit10(5), Unit11(4)
  Future<List<Phase2FinalTestQuestion>> generateTest();
  
  /// Load questions from all lessons in a specific unit
  Future<List<Phase2FinalTestQuestion>> _loadUnitQuestions(
    String unitId,
    int count,
  );
  
  /// Extract questions from lesson JSON
  List<Phase2FinalTestQuestion> _extractQuestionsFromLesson(
    Lesson lesson,
    String unitId,
  );
  
  /// Validate an answer and return if correct
  bool validateAnswer(Phase2FinalTestQuestion question, int selectedIndex);
  
  /// Calculate test result from answers with unit breakdown
  Phase2TestResult calculateResult(
    List<Phase2FinalTestQuestion> questions,
    List<int?> selectedAnswers,
  );
  
  /// Calculate performance for a specific unit
  UnitPerformance _calculateUnitPerformance(
    String unitId,
    List<Phase2FinalTestQuestion> questions,
    List<int?> selectedAnswers,
  );
  
  /// Save test result to local storage
  Future<void> saveTestResult(Phase2TestResult result);
  
  /// Load previous test result from storage
  Future<Phase2TestResult?> loadTestResult();
  
  /// Check if student has passed the test
  Future<bool> hasPassedTest();
  
  /// Get the last test score
  Future<int?> getLastTestScore();
  
  /// Check if all Phase 2 lessons are mastered
  Future<bool> areAllPhase2LessonsMastered();
  
  /// Clear test data (for retesting)
  Future<void> clearTestData();
}
```


**Key Algorithms:**

1. **Test Generation Algorithm:**
```
1. Load all Phase 2 lessons from LessonRepository
2. Group lessons by unit using _lessonToUnit mapping
3. For each unit:
   a. Collect all questions from unit's lessons
   b. Combine practiceQuestions and masteryQuestions
   c. Randomly select required count:
      - Unit 7: 5 questions
      - Unit 8: 6 questions
      - Unit 9: 5 questions
      - Unit 10: 5 questions
      - Unit 11: 4 questions
   d. Tag each question with unitId
4. Combine all selected questions (total: 25)
5. Shuffle the combined list
6. Return shuffled list
```

2. **Result Calculation Algorithm:**
```
1. Initialize counters: correct = 0, incorrect = 0
2. Create empty map for unit performance tracking
3. Create empty list for incorrect answer details
4. For each question (i = 0 to 24):
   a. Compare selectedAnswers[i] with question.correctIndex
   b. Track result in unit-specific counter
   c. If match: increment correct counter
   d. If no match:
      - Increment incorrect counter
      - Create IncorrectAnswer object
      - Add to incorrect answer details list
5. For each unit:
   a. Calculate unit accuracy
   b. Create UnitPerformance object
6. Calculate overall accuracy = (correct / 25) * 100
7. Determine passed = (correct >= 20)
8. Create Phase2TestResult object with all data
9. Return Phase2TestResult
```

3. **Unit Performance Calculation:**
```
1. Filter questions by unitId
2. Count total questions for unit
3. Count correct answers for unit
4. Calculate unit accuracy = (correct / total) * 100
5. Return UnitPerformance object
```


### 3. State Management

#### Phase2FinalTestProvider

```dart
class Phase2FinalTestProvider extends ChangeNotifier {
  final Phase2FinalTestService _testService;
  
  // Test state
  List<Phase2FinalTestQuestion> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  Phase2TestResult? _testResult;
  
  // Getters
  List<Phase2FinalTestQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Phase2FinalTestQuestion? get currentQuestion;
  int? get selectedAnswer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Phase2TestResult? get testResult => _testResult;
  int get totalQuestions => _questions.length;
  double get progress => (_currentQuestionIndex + 1) / totalQuestions;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get canProceed => selectedAnswer != null;
  
  Phase2FinalTestProvider({required Phase2FinalTestService testService})
      : _testService = testService;
  
  /// Initialize and generate a new test
  Future<void> startTest();
  
  /// Select an answer for current question
  void selectAnswer(int index);
  
  /// Skip current question (leave as null)
  void skipQuestion();
  
  /// Move to next question
  void nextQuestion();
  
  /// Move to previous question
  void previousQuestion();
  
  /// Submit test and calculate results
  Future<void> submitTest();
  
  /// Load previous test result
  Future<void> loadPreviousResult();
  
  /// Reset test state for retry
  void resetTest();
  
  /// Check if test has been passed before
  Future<bool> hasPassedBefore();
  
  /// Check if all Phase 2 lessons are mastered (for lock/unlock)
  Future<bool> canTakeTest();
}
```


### 4. Presentation Layer

#### Phase2FinalTestScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  ├─ Title: "Phase 2 – Final Test"
  └─ Subtitle: "Units 7–11 • 25 Questions"

Body
  ├─ Progress Section
  │   ├─ Question Counter: "Question X / 25"
  │   └─ Progress Bar (LinearProgressIndicator)
  │
  ├─ Question Section (Scrollable)
  │   ├─ Question Text (promptEn)
  │   └─ Options List
  │       ├─ Radio Option 1
  │       ├─ Radio Option 2
  │       ├─ Radio Option 3
  │       └─ Radio Option 4
  │
  └─ Navigation Section
      ├─ Skip Button (optional, secondary style)
      └─ Next Button (enabled when answer selected)
```

**Key UI Components:**
- Custom RadioListTile with enhanced styling
- Animated progress bar with color transitions
- Disabled state styling for Next button
- Optional Skip button with secondary styling
- Smooth page transitions between questions

#### Phase2FinalTestResultScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  └─ Title: "Test Results"

Body (Centered Column, Scrollable)
  ├─ Success/Failure Icon
  ├─ Title: "Phase 2 Final Test Completed!"
  ├─ Score Display: "Score: X / 25"
  ├─ Accuracy Display: "Accuracy: Y%"
  ├─ Status Message
  │   └─ (Success: "You have mastered Phase 2" / Failure: "You scored X%. Try again...")
  │
  ├─ Unit Summary Section
  │   ├─ Section Title: "Summary"
  │   ├─ Unit 7: "Time & Place: X / 5"
  │   ├─ Unit 8: "Continuous Tenses: X / 6"
  │   ├─ Unit 9: "Perfect Tenses: X / 5"
  │   ├─ Unit 10: "Questions/Neg: X / 5"
  │   └─ Unit 11: "Adj/Adv/Pronouns: X / 4"
  │
  └─ Action Buttons
      ├─ Review Mistakes Button
      └─ Continue / Retry Test Button
```

**Conditional Rendering:**
- Show "Continue" button only if passed (score >= 20)
- Show "Retry Test" button if failed (score < 20)
- Show "Review Mistakes" button only if there are incorrect answers
- Color-code unit performance (green for 80%+, yellow for 60-79%, red for <60%)

#### Phase2FinalTestReviewScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  └─ Title: "Review Mistakes"

Body (ListView)
  ├─ Incorrect Question 1
  │   ├─ Question Number & Unit/Lesson
  │   ├─ Question Text
  │   ├─ Your Answer (Red highlight)
  │   └─ Correct Answer (Green highlight)
  │
  ├─ Incorrect Question 2
  │   └─ ...
  │
  └─ Back to Results Button
```

**Color Coding:**
- Incorrect answer: Red background (#FFEBEE) with red text (#C62828)
- Correct answer: Green background (#E8F5E9) with green text (#2E7D32)
- Unit badge: Color-coded by unit (Unit 7: Blue, Unit 8: Purple, Unit 9: Orange, Unit 10: Teal, Unit 11: Pink)


## Data Models

### Unit Distribution Map

```dart
const Map<String, int> unitDistribution = {
  'unit7': 5,   // Time & Place Prepositions
  'unit8': 6,   // Continuous Tenses
  'unit9': 5,   // Perfect Tenses
  'unit10': 5,  // Questions & Negatives
  'unit11': 4,  // Advanced Pronouns, Adjectives & Adverbs
};

const Map<String, String> unitNames = {
  'unit7': 'Time & Place',
  'unit8': 'Continuous Tenses',
  'unit9': 'Perfect Tenses',
  'unit10': 'Questions/Neg',
  'unit11': 'Adj/Adv/Pronouns',
};
```

### Storage Schema

**SharedPreferences Keys:**
- `phase2_final_test_passed`: bool - Whether test was passed
- `phase2_final_test_score`: int - Last test score (0-25)
- `phase2_final_test_taken_at`: String - ISO 8601 timestamp
- `phase2_final_test_result`: String - JSON serialized Phase2TestResult object
- `phase3_unlocked`: bool - Whether Phase 3 is unlocked

## Error Handling

### Error Scenarios and Handling

1. **Lesson Loading Failure**
   - Scenario: JSON file missing or corrupted
   - Handling: Display error message, log to console, allow retry
   - User Message: "Failed to load test content. Please try again."

2. **Insufficient Questions**
   - Scenario: Unit has fewer questions than required
   - Handling: Use all available questions, log warning, continue with reduced count
   - User Message: None (graceful degradation)

3. **Storage Failure**
   - Scenario: SharedPreferences write fails
   - Handling: Log error, continue without saving, notify user
   - User Message: "Unable to save test results. Your progress may not be saved."

4. **Navigation Error**
   - Scenario: Invalid route or missing arguments
   - Handling: Redirect to home screen, log error
   - User Message: "Navigation error occurred. Returning to home."

5. **Lessons Not Mastered**
   - Scenario: User tries to access test without mastering all Phase 2 lessons
   - Handling: Show locked state with clear message
   - User Message: "Please master all Phase 2 lessons before taking the final test."

### Error Recovery Strategies

```dart
// Example error handling in service
Future<List<Phase2FinalTestQuestion>> generateTest() async {
  try {
    final questionsByUnit = <String, List<Phase2FinalTestQuestion>>{};
    
    for (final entry in _unitDistribution.entries) {
      try {
        final unitQuestions = await _loadUnitQuestions(
          entry.key,
          entry.value,
        );
        questionsByUnit[entry.key] = unitQuestions;
      } catch (e) {
        print('Warning: Failed to load ${entry.key}: $e');
        // Continue with other units
      }
    }
    
    final allQuestions = questionsByUnit.values
        .expand((list) => list)
        .toList();
    
    if (allQuestions.length < 20) {
      throw TestGenerationException(
        'Insufficient questions loaded: ${allQuestions.length}/25',
      );
    }
    
    allQuestions.shuffle();
    return allQuestions;
  } catch (e) {
    throw TestGenerationException('Failed to generate test: $e');
  }
}
```


## Testing Strategy

### Unit Tests

1. **Phase2FinalTestQuestion Model Tests**
   - Test JSON serialization/deserialization
   - Test factory constructor from lesson question
   - Test validation of required fields including unitId

2. **Phase2FinalTestService Tests**
   - Test question generation with mocked lesson data
   - Test unit distribution (5-6-5-5-4)
   - Test answer validation logic
   - Test result calculation with unit breakdown
   - Test unit performance calculation
   - Test storage operations (save/load)
   - Test error handling for missing lessons
   - Test Phase 3 unlock logic

3. **Phase2TestResult Model Tests**
   - Test accuracy calculation
   - Test pass/fail determination
   - Test unit breakdown calculation
   - Test JSON serialization

4. **UnitPerformance Model Tests**
   - Test accuracy calculation per unit
   - Test JSON serialization

### Widget Tests

1. **Phase2FinalTestScreen Tests**
   - Test initial render with loading state
   - Test question display
   - Test option selection
   - Test Next button enable/disable
   - Test Skip button functionality
   - Test progress bar updates
   - Test navigation to result screen

2. **Phase2FinalTestResultScreen Tests**
   - Test score display
   - Test unit breakdown display
   - Test conditional button rendering (pass vs fail)
   - Test navigation to review screen
   - Test Phase 3 unlock indication

3. **Phase2FinalTestReviewScreen Tests**
   - Test incorrect answer display
   - Test color coding
   - Test unit badge display
   - Test empty state (perfect score)

### Integration Tests

1. **Complete Test Flow**
   - Start test → Answer all questions → View results → Review mistakes
   - Test retry flow after failure
   - Test Phase 3 unlock after passing

2. **Persistence Tests**
   - Complete test → Close app → Reopen → Verify saved results
   - Test result overwrite on retry

3. **Lock/Unlock Tests**
   - Verify test is locked when lessons not mastered
   - Verify test unlocks when all lessons mastered
   - Verify Phase 3 unlocks after passing test


## UI/UX Specifications

### Typography

- **Question Text**: 18sp, FontWeight.w500, Color: #212121
- **Option Text**: 16sp, FontWeight.w400, Color: #424242
- **Progress Text**: 14sp, FontWeight.w500, Color: #757575
- **Score Text**: 32sp, FontWeight.bold, Color: #1976D2 (pass) / #D32F2F (fail)
- **Accuracy Text**: 24sp, FontWeight.w600, Color: #424242
- **Unit Summary Text**: 16sp, FontWeight.w500, Color: #424242

### Spacing

- **Screen Padding**: 16px horizontal, 24px vertical
- **Question Section Padding**: 20px all sides
- **Option Spacing**: 12px between options
- **Button Margin**: 16px top
- **Section Spacing**: 24px between major sections
- **Unit Summary Item Spacing**: 8px between items

### Colors

- **Primary**: #1976D2 (Blue)
- **Success**: #2E7D32 (Green)
- **Error**: #C62828 (Red)
- **Warning**: #F57C00 (Orange)
- **Background**: #FAFAFA
- **Card Background**: #FFFFFF
- **Selected Option**: #E3F2FD (Light Blue)
- **Disabled Button**: #BDBDBD
- **Unit 7 Badge**: #2196F3 (Blue)
- **Unit 8 Badge**: #9C27B0 (Purple)
- **Unit 9 Badge**: #FF9800 (Orange)
- **Unit 10 Badge**: #009688 (Teal)
- **Unit 11 Badge**: #E91E63 (Pink)

### Animations

- **Question Transition**: Fade + Slide (300ms, Curves.easeInOut)
- **Progress Bar**: Linear animation (200ms)
- **Button Press**: Scale animation (100ms)
- **Result Screen Entry**: Fade + Scale (400ms)
- **Unit Summary Reveal**: Staggered fade-in (100ms delay per item)

## Integration Points

### 1. Routing Integration

Add to `lib/app/routes.dart`:
```dart
static const String phase2FinalTest = '/phase2/finalTest';
static const String phase2FinalTestResult = '/phase2/finalTest/result';
static const String phase2FinalTestReview = '/phase2/finalTest/review';
```

### 2. Phase2LessonListScreen Integration

Add final test card at bottom of lesson list:
```dart
// Show final test card if all Phase 2 lessons are mastered
if (await _testService.areAllPhase2LessonsMastered()) {
  Phase2FinalTestCard(
    onTap: () => Navigator.pushNamed(context, AppRoutes.phase2FinalTest),
    isPassed: await _testService.hasPassedTest(),
    lastScore: await _testService.getLastTestScore(),
  );
}
```

### 3. Home Screen Integration

Update Phase 2 and Phase 3 status based on final test:
```dart
final phase2Passed = await _phase2TestService.hasPassedTest();
final phase3Unlocked = await _storageService.getBool('phase3_unlocked') ?? false;
```

### 4. Provider Registration

Add to main.dart:
```dart
MultiProvider(
  providers: [
    // Existing providers...
    ChangeNotifierProvider(
      create: (_) => Phase2FinalTestProvider(
        testService: Phase2FinalTestService(
          lessonRepository: LessonRepository(),
          storageService: storageService,
        ),
      ),
    ),
  ],
  child: MyApp(),
)
```

## Performance Considerations

1. **Lazy Loading**: Load lesson JSON only when generating test
2. **Caching**: Use LessonRepository's built-in caching
3. **Memory Management**: Clear question list after test completion
4. **Async Operations**: Use FutureBuilder for async data loading
5. **State Optimization**: Use `notifyListeners()` selectively in provider
6. **Unit Calculation**: Calculate unit performance once during result calculation

## Accessibility

1. **Semantic Labels**: Add semantics to all interactive elements
2. **Screen Reader Support**: Announce question changes and results
3. **Touch Targets**: Minimum 48x48 logical pixels for all buttons
4. **Color Contrast**: Maintain 4.5:1 ratio for all text
5. **Focus Management**: Proper focus order for keyboard navigation
6. **Unit Color Coding**: Don't rely solely on color; include text labels

## Security Considerations

1. **Data Validation**: Validate all user inputs and stored data
2. **Storage Encryption**: Consider encrypting sensitive test results (future enhancement)
3. **Tampering Prevention**: Validate test integrity (future enhancement)

## Future Enhancements

1. **Analytics**: Track test performance metrics by unit
2. **Adaptive Testing**: Adjust difficulty based on performance
3. **Timed Mode**: Add optional time limits
4. **Detailed Analytics**: Show performance by specific lesson/topic
5. **Certificate Generation**: Generate Phase 2 completion certificates
6. **Social Sharing**: Share achievements on social media
7. **Retry Specific Units**: Allow retaking test for specific weak units
8. **Progress Tracking**: Show improvement over multiple attempts
