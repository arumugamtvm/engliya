# Implementation Plan

- [x] 1. Set up project structure and dependencies
  - Create folder structure following the design: core/, features/, services/
  - Add required dependencies to pubspec.yaml: provider, shared_preferences, flutter_tts
  - Create app configuration files: app.dart, routes.dart, theme.dart
  - Set up assets folder structure and update pubspec.yaml for asset loading
  - _Requirements: 13.1, 13.2_

- [x] 2. Implement core data models
  - Create Lesson model with fromJson/toJson methods
  - Create LessonExplain and ExplainTableRow models
  - Create ExampleSentence model
  - Create ListeningQuestion model
  - Create SpeakSentence model
  - Create QuizQuestion model
  - Create UserLessonStatus model with computed properties
  - _Requirements: 12.2, 13.3_

- [x] 3. Implement storage service
  - Create StorageService class with SharedPreferences initialization
  - Implement generic storage methods: setString, getString, setBool, etc.
  - Implement JSON storage methods: setJson, getJson
  - Add error handling for storage operations
  - _Requirements: 12.1, 12.3, 12.4, 12.5_

- [x] 4. Implement repositories
  - Create LessonRepository with asset loading logic
  - Implement loadLesson method with JSON parsing
  - Implement loadUnitLessons method for Phase 1
  - Create ProgressRepository with storage integration
  - Implement loadAllProgress, loadLessonProgress, saveLessonProgress methods
  - Add error handling for asset loading and storage operations
  - _Requirements: 13.1, 13.3, 13.4, 12.1_

- [x] 5. Implement audio and mastery services
  - Create AudioService with FlutterTts integration
  - Implement speak, stop, and configuration methods
  - Create MasteryService with mastery calculation logic
  - Implement isLessonMastered, shouldUnlockLesson methods
  - Implement calculateOverallProgress method
  - _Requirements: 7.4, 11.6, 4.2, 4.3_

- [x] 6. Create lesson content JSON files
  - Create lesson1_pronouns.json with complete content (10 examples, 5 listening, 5 speaking, 10 practice, 10 mastery questions)
  - Add Tamil and English explanations for subject pronouns from PDF content
  - Create lesson2_be_verb.json with complete content
  - Add Tamil and English explanations for be verb usage
  - Create placeholder JSON files for lessons 3-6 with basic structure
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6_

- [x] 7. Implement state management providers
  - Create LessonProvider with lesson loading and tab navigation
  - Implement tab completion methods: markExplainDone, markExamplesDone, etc.
  - Implement saveProgress method
  - Create ProgressProvider with progress loading and unlock logic
  - Implement isLessonUnlocked and getLessonStatus methods
  - Create OnboardingProvider for level selection
  - Create HomeProvider for home screen data
  - _Requirements: 4.1, 4.2, 4.4, 12.4_

- [x] 8. Implement onboarding screen
  - Create OnboardingScreen with level selection UI
  - Add level selection cards with tap handling
  - Implement "Continue" button with navigation to home
  - Integrate OnboardingProvider for state management
  - Save selected level to storage
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 9. Implement home screen
  - Create HomeScreen with app title and progress summary
  - Add "Start Learning" button with navigation to Phase1UnitScreen
  - Implement "Continue where you left off" card (conditional rendering)
  - Display mastered lesson count (X / 6 format)
  - Integrate HomeProvider for data loading
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 10. Implement Phase 1 unit screen
  - Create Phase1UnitScreen with lesson list
  - Create LessonCard widget with title, description, status badge
  - Implement status indicators: Locked, In Progress, Mastered icons
  - Add progress indicator for each lesson
  - Implement tap handling: navigate to unlocked lessons, show message for locked
  - Integrate ProgressProvider for unlock logic
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 11. Implement lesson screen structure
  - Create LessonScreen with AppBar showing title and progress
  - Implement TabBar with 6 tabs: Explain, Examples, Listen, Speak, Practice, Mastery
  - Create TabBarView container for tab content
  - Implement bottom navigation bar with Previous/Next buttons
  - Add button enable/disable logic based on tab completion
  - Integrate LessonProvider for state management
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

- [x] 12. Implement Explain tab
  - Create ExplainTab widget with scrollable content
  - Display Tamil explanation text
  - Display English explanation text
  - Render table data if present (pronoun table)
  - Implement scroll-to-bottom detection for completion
  - Call markExplainDone when completed
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 13. Implement Examples tab
  - Create ExamplesTab widget with example list
  - Display each example with English and Tamil text
  - Add audio play icon button for each example
  - Integrate AudioService for TTS playback
  - Track played examples count
  - Call markExamplesDone when 3+ examples played
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 14. Implement Listen tab
  - Create ListenTab widget with question list
  - Display audio play button for each question
  - Integrate AudioService for question audio playback
  - Display 3 answer options as selectable buttons
  - Implement answer selection with correct/incorrect feedback
  - Calculate accuracy score after 3+ questions
  - Call updateListeningScore when 70%+ accuracy achieved
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

- [x] 15. Implement Speak tab
  - Create SpeakTab widget with sentence list
  - Display target sentence for each exercise
  - Add microphone button for each sentence
  - Implement mock score generation (70-100 range)
  - Display "You said: ..." placeholder text
  - Display score percentage after each attempt
  - Calculate average score after 3+ attempts
  - Call updateSpeakingScore when 70%+ average achieved
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

- [x] 16. Implement Practice tab
  - Create PracticeTab widget with quiz interface
  - Display questions with English and Tamil prompts
  - Render answer options as selectable buttons
  - Implement answer selection with immediate feedback
  - Calculate total score after all questions answered
  - Display final score as percentage
  - Call updateQuizScore with result
  - Mark tab complete if score >= 60%
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_

- [x] 17. Implement Mastery tab
  - Create MasteryTab widget with summary view
  - Display previous quiz scores and listening results
  - Add "Start Mastery Test" button
  - Implement mastery test with 8-10 mixed questions
  - Use questions from practice and listening pools
  - Calculate and display final score
  - Call updateMasteryScore with result
  - Mark lesson as mastered if score >= 80%
  - Trigger next lesson unlock on mastery
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8_

- [x] 18. Implement UI theme and common widgets
  - Create app theme with colors, fonts, and text styles
  - Create CustomButton widget with consistent styling
  - Create ProgressIndicator widget for lesson progress
  - Create StatusBadge widget for lesson status
  - Implement icons: volume, mic, check, cancel, lock
  - Add animations: tab transitions, button press, feedback
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7_

- [x] 19. Implement routing and navigation
  - Set up named routes in routes.dart
  - Configure initial route based on onboarding status
  - Implement navigation between screens
  - Add back button handling for lesson screen
  - Test navigation flow: onboarding → home → unit → lesson
  - _Requirements: 1.4, 1.5, 2.4, 2.5, 3.5_

- [x] 20. Implement progress persistence and restoration
  - Ensure progress saves after each tab completion
  - Implement progress loading on app startup
  - Test progress restoration after app restart
  - Verify unlock status persists correctly
  - Test last accessed lesson tracking
  - _Requirements: 12.3, 12.4, 12.5, 4.4, 2.2_

- [x] 21. Add error handling and user feedback
  - Implement error handling for asset loading failures
  - Add error handling for storage failures with retry logic
  - Implement error handling for TTS failures
  - Create user-friendly error messages and snackbars
  - Test error scenarios: missing JSON, storage failure, TTS unavailable
  - _Requirements: 13.4, 12.1_

- [x] 22. Create progress overview screen
  - Create ProgressScreen with lesson list
  - Display mastery status for each lesson
  - Show detailed scores for completed lessons
  - Add navigation from home screen
  - _Requirements: 2.3_
