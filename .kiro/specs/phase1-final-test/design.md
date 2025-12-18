# Design Document

## Overview

The Phase 1 Final Mastery Test is a comprehensive assessment feature that validates students' understanding of all six Phase 1 lessons. The feature consists of four main components: a test generation service that creates randomized 20-question tests from existing lesson content, a test screen for answering questions, a result screen for displaying performance, and a review screen for examining incorrect answers. The system integrates with the existing Flutter app architecture using Provider for state management, follows the repository pattern for data access, and uses SharedPreferences for local persistence.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Final Test   │  │   Result     │  │   Review     │      │
│  │   Screen     │  │   Screen     │  │   Screen     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                        │
│                   │  Final Test     │                        │
│                   │    Provider     │                        │
│                   └────────┬────────┘                        │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                     Service Layer                             │
│                   ┌────────▼────────┐                         │
│                   │ Phase1 Final    │                         │
│                   │  Test Service   │                         │
│                   └────────┬────────┘                         │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                      Data Layer                               │
│         ┌──────────────────┼──────────────────┐               │
│         │                  │                  │               │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐       │
│  │   Lesson     │  │   Storage    │  │  Final Test  │       │
│  │  Repository  │  │   Service    │  │   Question   │       │
│  │  (existing)  │  │  (existing)  │  │    Model     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

**Presentation Layer:**
- **Phase1FinalTestScreen**: Main test interface displaying questions and handling user input
- **Phase1FinalTestResultScreen**: Displays test score, accuracy, and navigation options
- **Phase1FinalTestReviewScreen**: Shows incorrect answers with correct solutions
- **FinalTestProvider**: Manages test state, question navigation, and answer tracking

**Service Layer:**
- **Phase1FinalTestService**: Generates randomized tests, validates answers, and calculates scores

**Data Layer:**
- **FinalTestQuestion**: Model representing a single test question
- **LessonRepository**: Loads lesson JSON files (existing component)
- **StorageService**: Persists test results (existing component)

## Components and Interfaces

### 1. Data Models

#### FinalTestQuestion Model

```dart
class FinalTestQuestion {
  final String lessonId;           // e.g., "phase1_lesson1"
  final String lessonTitle;        // e.g., "Subject Pronouns"
  final String promptEn;           // English question text
  final String promptTa;           // Tamil question text (optional)
  final List<String> options;      // Four answer options
  final int correctIndex;          // Index of correct answer (0-3)
  final String questionType;       // "mcq" or "sentence_identification"
  
  FinalTestQuestion({
    required this.lessonId,
    required this.lessonTitle,
    required this.promptEn,
    this.promptTa = '',
    required this.options,
    required this.correctIndex,
    this.questionType = 'mcq',
  });
  
  // Factory constructor from lesson question JSON
  factory FinalTestQuestion.fromLessonQuestion(
    Map<String, dynamic> json,
    String lessonId,
    String lessonTitle,
  );
  
  // Serialization methods
  Map<String, dynamic> toJson();
  factory FinalTestQuestion.fromJson(Map<String, dynamic> json);
}
```

#### TestResult Model

```dart
class TestResult {
  final int totalQuestions;        // Always 20
  final int correctAnswers;        // Number of correct answers
  final int incorrectAnswers;      // Number of incorrect answers
  final double accuracy;           // Percentage (0-100)
  final bool passed;               // True if score >= 16
  final DateTime completedAt;      // Timestamp of completion
  final List<IncorrectAnswer> incorrectQuestionDetails;
  
  TestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.passed,
    required this.completedAt,
    required this.incorrectQuestionDetails,
  });
  
  Map<String, dynamic> toJson();
  factory TestResult.fromJson(Map<String, dynamic> json);
}
```

#### IncorrectAnswer Model

```dart
class IncorrectAnswer {
  final FinalTestQuestion question;
  final int selectedIndex;         // User's selected answer index
  final String selectedAnswer;     // User's selected answer text
  final String correctAnswer;      // Correct answer text
  
  IncorrectAnswer({
    required this.question,
    required this.selectedIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
  });
  
  Map<String, dynamic> toJson();
  factory IncorrectAnswer.fromJson(Map<String, dynamic> json);
}
```

### 2. Service Layer

#### Phase1FinalTestService

```dart
class Phase1FinalTestService {
  final LessonRepository _lessonRepository;
  final StorageService _storageService;
  
  // Storage keys
  static const String _keyTestPassed = 'phase1_final_test_passed';
  static const String _keyTestScore = 'phase1_final_test_score';
  static const String _keyTestDate = 'phase1_final_test_date';
  static const String _keyTestResult = 'phase1_final_test_result';
  
  Phase1FinalTestService({
    required LessonRepository lessonRepository,
    required StorageService storageService,
  }) : _lessonRepository = lessonRepository,
       _storageService = storageService;
  
  /// Generate a randomized test with 20 questions
  /// Distribution: L1(4), L2(4), L3(4), L4(3), L5(3), L6(2)
  Future<List<FinalTestQuestion>> generateTest();
  
  /// Load questions from a specific lesson
  Future<List<FinalTestQuestion>> _loadLessonQuestions(
    String lessonId,
    int count,
  );
  
  /// Extract questions from lesson JSON
  List<FinalTestQuestion> _extractQuestionsFromLesson(
    Lesson lesson,
    int count,
  );
  
  /// Validate an answer and return if correct
  bool validateAnswer(FinalTestQuestion question, int selectedIndex);
  
  /// Calculate test result from answers
  TestResult calculateResult(
    List<FinalTestQuestion> questions,
    List<int> selectedAnswers,
  );
  
  /// Save test result to local storage
  Future<void> saveTestResult(TestResult result);
  
  /// Load previous test result from storage
  Future<TestResult?> loadTestResult();
  
  /// Check if student has passed the test
  Future<bool> hasPassedTest();
  
  /// Get the last test score
  Future<int?> getLastTestScore();
  
  /// Clear test data (for retesting)
  Future<void> clearTestData();
}
```

**Key Algorithms:**

1. **Test Generation Algorithm:**
```
1. Load all 6 Phase 1 lessons from LessonRepository
2. For each lesson:
   a. Extract practiceQuestions and masteryQuestions
   b. Combine into single pool
   c. Randomly select required count:
      - Lesson 1: 4 questions
      - Lesson 2: 4 questions
      - Lesson 3: 4 questions
      - Lesson 4: 3 questions
      - Lesson 5: 3 questions
      - Lesson 6: 2 questions
3. Combine all selected questions (total: 20)
4. Shuffle the combined list
5. Return shuffled list
```

2. **Result Calculation Algorithm:**
```
1. Initialize counters: correct = 0, incorrect = 0
2. Create empty list for incorrect answer details
3. For each question (i = 0 to 19):
   a. Compare selectedAnswers[i] with question.correctIndex
   b. If match: increment correct counter
   c. If no match:
      - Increment incorrect counter
      - Create IncorrectAnswer object
      - Add to incorrect answer details list
4. Calculate accuracy = (correct / 20) * 100
5. Determine passed = (correct >= 16)
6. Create TestResult object with all data
7. Return TestResult
```

### 3. State Management

#### FinalTestProvider

```dart
class FinalTestProvider extends ChangeNotifier {
  final Phase1FinalTestService _testService;
  
  // Test state
  List<FinalTestQuestion> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _error;
  TestResult? _testResult;
  
  // Getters
  List<FinalTestQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  FinalTestQuestion? get currentQuestion;
  int? get selectedAnswer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TestResult? get testResult => _testResult;
  int get totalQuestions => _questions.length;
  double get progress => (_currentQuestionIndex + 1) / totalQuestions;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get canProceed => selectedAnswer != null;
  
  FinalTestProvider({required Phase1FinalTestService testService})
      : _testService = testService;
  
  /// Initialize and generate a new test
  Future<void> startTest();
  
  /// Select an answer for current question
  void selectAnswer(int index);
  
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
}
```

### 4. Presentation Layer

#### Phase1FinalTestScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  ├─ Title: "Phase 1 – Final Test"
  └─ Subtitle: "Covering Lessons 1 to 6"

Body
  ├─ Progress Section
  │   ├─ Question Counter: "Question X/20"
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
      └─ Next Button (enabled when answer selected)
```

**Key UI Components:**
- Custom RadioListTile with enhanced styling
- Animated progress bar with color transitions
- Disabled state styling for Next button
- Smooth page transitions between questions

#### Phase1FinalTestResultScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  └─ Title: "Test Results"

Body (Centered Column)
  ├─ Success/Failure Icon
  ├─ Title: "Phase 1 Final Test – Completed!"
  ├─ Score Display: "Score: X / 20"
  ├─ Accuracy Display: "Accuracy: Y%"
  ├─ Status Message
  │   └─ (Success: "You have mastered..." / Failure: "Keep practicing...")
  ├─ Action Buttons
  │   ├─ Review Mistakes Button
  │   └─ Continue to Phase 2 / Retry Test Button
```

**Conditional Rendering:**
- Show "Continue to Phase 2" button only if passed (score >= 16)
- Show "Retry Test" button if failed (score < 16)
- Show "Review Mistakes" button only if there are incorrect answers

#### Phase1FinalTestReviewScreen

**Layout Structure:**
```
AppBar
  ├─ Back Button
  └─ Title: "Review Mistakes"

Body (ListView)
  ├─ Incorrect Question 1
  │   ├─ Question Number & Lesson
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

## Data Models

### Question Distribution Map

```dart
const Map<String, int> questionDistribution = {
  'phase1_lesson1': 4,  // Pronouns
  'phase1_lesson2': 4,  // Be Verb
  'phase1_lesson3': 4,  // Nouns & Articles
  'phase1_lesson4': 3,  // Object Pronouns
  'phase1_lesson5': 3,  // Action Verbs
  'phase1_lesson6': 2,  // Simple Present
};
```

### Storage Schema

**SharedPreferences Keys:**
- `phase1_final_test_passed`: bool - Whether test was passed
- `phase1_final_test_score`: int - Last test score (0-20)
- `phase1_final_test_date`: String - ISO 8601 timestamp
- `phase1_final_test_result`: String - JSON serialized TestResult object

## Error Handling

### Error Scenarios and Handling

1. **Lesson Loading Failure**
   - Scenario: JSON file missing or corrupted
   - Handling: Display error message, log to console, allow retry
   - User Message: "Failed to load test content. Please try again."

2. **Insufficient Questions**
   - Scenario: Lesson has fewer questions than required
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

### Error Recovery Strategies

```dart
// Example error handling in service
Future<List<FinalTestQuestion>> generateTest() async {
  try {
    final questions = <FinalTestQuestion>[];
    
    for (final entry in questionDistribution.entries) {
      try {
        final lessonQuestions = await _loadLessonQuestions(
          entry.key,
          entry.value,
        );
        questions.addAll(lessonQuestions);
      } catch (e) {
        // Log error but continue with other lessons
        print('Warning: Failed to load ${entry.key}: $e');
        // If critical lesson (1 or 2), rethrow
        if (entry.key == 'phase1_lesson1' || entry.key == 'phase1_lesson2') {
          rethrow;
        }
      }
    }
    
    if (questions.length < 15) {
      throw TestGenerationException(
        'Insufficient questions loaded: ${questions.length}/20',
      );
    }
    
    questions.shuffle();
    return questions;
  } catch (e) {
    throw TestGenerationException('Failed to generate test: $e');
  }
}
```

## Testing Strategy

### Unit Tests

1. **FinalTestQuestion Model Tests**
   - Test JSON serialization/deserialization
   - Test factory constructor from lesson question
   - Test validation of required fields

2. **Phase1FinalTestService Tests**
   - Test question generation with mocked lesson data
   - Test question distribution (4-4-4-3-3-2)
   - Test answer validation logic
   - Test result calculation with various scores
   - Test storage operations (save/load)
   - Test error handling for missing lessons

3. **TestResult Model Tests**
   - Test accuracy calculation
   - Test pass/fail determination
   - Test JSON serialization

### Widget Tests

1. **Phase1FinalTestScreen Tests**
   - Test initial render with loading state
   - Test question display
   - Test option selection
   - Test Next button enable/disable
   - Test progress bar updates
   - Test navigation to result screen

2. **Phase1FinalTestResultScreen Tests**
   - Test score display
   - Test conditional button rendering (pass vs fail)
   - Test navigation to review screen
   - Test navigation to Phase 2

3. **Phase1FinalTestReviewScreen Tests**
   - Test incorrect answer display
   - Test color coding
   - Test empty state (perfect score)

### Integration Tests

1. **Complete Test Flow**
   - Start test → Answer all questions → View results → Review mistakes
   - Test retry flow after failure
   - Test Phase 2 unlock after passing

2. **Persistence Tests**
   - Complete test → Close app → Reopen → Verify saved results
   - Test result overwrite on retry

## UI/UX Specifications

### Typography

- **Question Text**: 18sp, FontWeight.w500, Color: #212121
- **Option Text**: 16sp, FontWeight.w400, Color: #424242
- **Progress Text**: 14sp, FontWeight.w500, Color: #757575
- **Score Text**: 32sp, FontWeight.bold, Color: #1976D2 (pass) / #D32F2F (fail)
- **Accuracy Text**: 24sp, FontWeight.w600, Color: #424242

### Spacing

- **Screen Padding**: 16px horizontal, 24px vertical
- **Question Section Padding**: 20px all sides
- **Option Spacing**: 12px between options
- **Button Margin**: 16px top
- **Section Spacing**: 24px between major sections

### Colors

- **Primary**: #1976D2 (Blue)
- **Success**: #2E7D32 (Green)
- **Error**: #C62828 (Red)
- **Background**: #FAFAFA
- **Card Background**: #FFFFFF
- **Selected Option**: #E3F2FD (Light Blue)
- **Disabled Button**: #BDBDBD

### Animations

- **Question Transition**: Fade + Slide (300ms, Curves.easeInOut)
- **Progress Bar**: Linear animation (200ms)
- **Button Press**: Scale animation (100ms)
- **Result Screen Entry**: Fade + Scale (400ms)

## Integration Points

### 1. Routing Integration

Add to `lib/app/routes.dart`:
```dart
static const String phase1FinalTest = '/phase1/finalTest';
static const String phase1FinalTestResult = '/phase1/finalTest/result';
static const String phase1FinalTestReview = '/phase1/finalTest/review';
```

### 2. Phase1UnitScreen Integration

Add final test card after Lesson 6:
```dart
// Show final test card if Lesson 6 is completed
if (lesson6Status.isCompleted) {
  FinalTestCard(
    onTap: () => Navigator.pushNamed(context, AppRoutes.phase1FinalTest),
    isPassed: await _testService.hasPassedTest(),
  );
}
```

### 3. Home Screen Integration

Update Phase 2 lock status based on final test:
```dart
final phase2Unlocked = await _testService.hasPassedTest();
```

### 4. Provider Registration

Add to main.dart:
```dart
MultiProvider(
  providers: [
    // Existing providers...
    ChangeNotifierProvider(
      create: (_) => FinalTestProvider(
        testService: Phase1FinalTestService(
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

## Accessibility

1. **Semantic Labels**: Add semantics to all interactive elements
2. **Screen Reader Support**: Announce question changes and results
3. **Touch Targets**: Minimum 48x48 logical pixels for all buttons
4. **Color Contrast**: Maintain 4.5:1 ratio for all text
5. **Focus Management**: Proper focus order for keyboard navigation

## Security Considerations

1. **Data Validation**: Validate all user inputs and stored data
2. **Storage Encryption**: Consider encrypting sensitive test results (future enhancement)
3. **Tampering Prevention**: Validate test integrity (future enhancement)

## Future Enhancements

1. **Analytics**: Track test performance metrics
2. **Adaptive Testing**: Adjust difficulty based on performance
3. **Timed Mode**: Add optional time limits
4. **Detailed Analytics**: Show performance by lesson/topic
5. **Certificate Generation**: Generate completion certificates
6. **Social Sharing**: Share achievements on social media
