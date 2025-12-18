# Implementation Plan

- [x] 1. Create data models for Phase 2 final test feature
  - Create `Phase2FinalTestQuestion` model class with JSON serialization and unitId tracking
  - Create `Phase2TestResult` model class with accuracy calculation and unit breakdown
  - Create `UnitPerformance` model class for per-unit performance tracking
  - Reuse existing `IncorrectAnswer` model for review functionality
  - _Requirements: 2.2, 2.10, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5.3, 5.4, 5.5, 5.7_

- [x] 2. Implement Phase2FinalTestService for test generation and management
- [x] 2.1 Create service class with dependency injection
  - Initialize service with LessonRepository and StorageService dependencies
  - Define storage key constants for Phase 2 test data
  - Define unit distribution map (5-6-5-5-4)
  - Define lesson-to-unit mapping for all Phase 2 lessons
  - _Requirements: 2.1, 6.1, 6.2, 6.3, 6.4_

- [x] 2.2 Implement test generation logic with unit distribution
  - Create `generateTest()` method that loads all Phase 2 lessons
  - Implement unit grouping logic using lesson-to-unit mapping
  - Implement question extraction from practiceQuestions and masteryQuestions
  - Implement random selection with correct unit distribution (5-6-5-5-4)
  - Tag each question with unitId for result breakdown
  - Shuffle final question list
  - Add error handling for missing or insufficient questions
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10_

- [x] 2.3 Implement answer validation and result calculation with unit breakdown
  - Create `validateAnswer()` method to check if selected answer is correct
  - Create `calculateResult()` method to compute score, accuracy, and pass/fail status
  - Implement `_calculateUnitPerformance()` method for per-unit performance
  - Build unit breakdown map with UnitPerformance objects
  - Build list of incorrect answer details for review
  - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10, 4.11_

- [x] 2.4 Implement local storage operations with Phase 3 unlock
  - Create `saveTestResult()` method to persist test results
  - Save phase3Unlocked flag when test is passed
  - Create `loadTestResult()` method to retrieve previous results
  - Create `hasPassedTest()` method to check pass status
  - Create `getLastTestScore()` method to retrieve score
  - Create `areAllPhase2LessonsMastered()` method for lock/unlock logic
  - Create `clearTestData()` method for retry functionality
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9_

- [x] 3. Create Phase2FinalTestProvider for state management
  - Initialize provider with Phase2FinalTestService dependency
  - Implement state properties (questions, answers, current index, loading, error)
  - Create `startTest()` method to generate and initialize test
  - Create `selectAnswer()` method to record user's answer selection
  - Create `skipQuestion()` method to allow skipping questions
  - Create `nextQuestion()` and `previousQuestion()` methods for navigation
  - Create `submitTest()` method to calculate and save results
  - Create `canTakeTest()` method to check if all lessons are mastered
  - Implement computed getters (progress, canProceed, isLastQuestion)
  - Add proper error handling and loading states
  - _Requirements: 1.4, 3.1, 3.2, 3.3, 3.6, 3.7, 3.8, 3.9, 3.10, 7.5_


- [x] 4. Build Phase2FinalTestScreen UI
- [x] 4.1 Create screen scaffold with AppBar
  - Add back button navigation
  - Display title "Phase 2 – Final Test"
  - Display subtitle "Units 7–11 • 25 Questions"
  - _Requirements: 1.2, 1.3, 8.1, 8.2_

- [x] 4.2 Implement progress section
  - Display question counter "Question X / 25"
  - Add LinearProgressIndicator with percentage calculation
  - Style progress bar with primary color
  - _Requirements: 3.2, 3.3, 8.5_

- [x] 4.3 Build question display section
  - Display question text from promptEn field
  - Create scrollable container for long questions
  - Apply proper typography and spacing
  - _Requirements: 3.4, 8.1, 8.2, 8.6_

- [x] 4.4 Implement answer options UI
  - Create four RadioListTile widgets for options
  - Implement option selection with visual feedback
  - Apply color coding for selected state
  - Ensure minimum touch target size (48x48)
  - _Requirements: 3.5, 3.6, 3.7, 8.3, 8.4, 8.7_

- [x] 4.5 Add navigation controls
  - Create Skip button with secondary styling (optional)
  - Create Next button with enabled/disabled states
  - Disable Next button when no answer selected (unless skipped)
  - Enable Next button when answer is selected
  - Handle navigation to next question or result screen
  - _Requirements: 3.6, 3.7, 3.8, 3.9, 3.10_

- [x] 4.6 Integrate with Phase2FinalTestProvider
  - Wrap screen with Consumer widget
  - Handle loading state with progress indicator
  - Handle error state with error message display
  - Implement test initialization on screen load
  - Handle locked state when lessons not mastered
  - _Requirements: 1.1, 1.4, 1.5, 7.5_

- [x] 5. Build Phase2FinalTestResultScreen UI
- [x] 5.1 Create result screen scaffold
  - Add AppBar with back button
  - Display title "Test Results"
  - _Requirements: 4.1_

- [x] 5.2 Implement score display section
  - Display completion title "Phase 2 Final Test Completed!"
  - Show score in format "Score: X / 25"
  - Calculate and display accuracy percentage
  - Add success/failure icon based on pass status
  - Apply appropriate color coding (green for pass, red for fail)
  - _Requirements: 4.1, 4.2, 4.3, 8.1, 8.2_

- [x] 5.3 Add status message
  - Display success message for passing score (>= 20)
  - Display encouragement message for failing score (< 20)
  - _Requirements: 4.10, 4.11_

- [x] 5.4 Implement unit breakdown section
  - Create "Summary" section header
  - Display Unit 7 performance: "Time & Place: X / 5"
  - Display Unit 8 performance: "Continuous Tenses: X / 6"
  - Display Unit 9 performance: "Perfect Tenses: X / 5"
  - Display Unit 10 performance: "Questions/Neg: X / 5"
  - Display Unit 11 performance: "Adj/Adv/Pronouns: X / 4"
  - Apply color coding based on unit performance (green/yellow/red)
  - _Requirements: 4.4, 4.5, 4.6, 4.7, 4.8, 4.9_

- [x] 5.5 Implement action buttons
  - Add "Review Mistakes" button (visible if mistakes exist)
  - Add "Continue" button (only if passed)
  - Add "Retry Test" button (only if failed)
  - Implement navigation to review screen
  - Implement navigation to home or test retry
  - _Requirements: 4.12, 4.13, 4.14_

- [x] 6. Build Phase2FinalTestReviewScreen UI
  - Create review screen scaffold with AppBar
  - Display "Review Mistakes" title
  - Implement ListView for incorrect answers
  - Display each incorrect question with question text
  - Show unit and lesson badge for each question
  - Show user's selected answer with red highlighting
  - Show correct answer with green highlighting
  - Display question number and source information
  - Handle empty state (perfect score scenario)
  - Add "Back to Results" button
  - Apply proper color coding and spacing
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 8.1, 8.2, 8.6_

- [x] 7. Integrate routing and navigation
- [x] 7.1 Add route definitions to AppRoutes
  - Define `/phase2/finalTest` route constant
  - Define `/phase2/finalTest/result` route constant
  - Define `/phase2/finalTest/review` route constant
  - _Requirements: 7.1, 7.2_

- [x] 7.2 Implement route handlers
  - Add case for phase2FinalTest route in onGenerateRoute
  - Add case for result screen route with Phase2TestResult argument
  - Add case for review screen route with incorrect answers argument
  - Handle missing arguments gracefully
  - _Requirements: 7.2, 7.3_

- [x] 7.3 Add navigation from Phase2LessonListScreen
  - Check if all Phase 2 lessons are mastered
  - Display final test card at bottom of lesson list
  - Show lock status if lessons not mastered
  - Show pass status if test was previously completed
  - Implement navigation to final test screen on tap
  - _Requirements: 1.1, 7.4_

- [x] 8. Register provider in main.dart
  - Import Phase2FinalTestProvider and Phase2FinalTestService
  - Create Phase2FinalTestService instance with dependencies
  - Add ChangeNotifierProvider for Phase2FinalTestProvider
  - Ensure proper initialization order with existing providers
  - _Requirements: 1.1, 2.1_

- [x] 9. Implement Phase 3 unlock mechanism
  - Update home screen to check phase2FinalTestPassed status
  - Set phase3Unlocked flag when test is passed
  - Conditionally enable/disable Phase 3 navigation based on unlock status
  - Display lock icon or message if test not passed
  - Update UI to show Phase 3 as unlocked after passing test
  - _Requirements: 6.1, 6.4, 6.9_

- [x] 10. Implement lock/unlock logic for test access
  - Create method to check if all Phase 2 lessons are mastered
  - Display locked state on test screen if lessons not mastered
  - Show clear message: "Please master all Phase 2 lessons before taking the final test"
  - Prevent test generation when locked
  - Update home screen to show test status (Locked/Ready/Completed)
  - _Requirements: 1.4, 7.5, 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 11. Add error handling and edge cases
  - Handle lesson loading failures with user-friendly messages
  - Handle insufficient questions scenario gracefully
  - Handle storage failures with appropriate fallbacks
  - Add retry mechanism for failed operations
  - Implement proper error logging
  - Handle navigation errors gracefully
  - _Requirements: 2.9_

- [x] 12. Implement accessibility features
  - Add semantic labels to all interactive elements
  - Implement screen reader announcements for question changes
  - Ensure proper focus management for keyboard navigation
  - Verify color contrast ratios meet WCAG standards
  - Don't rely solely on color for unit performance indicators
  - Test with screen reader (TalkBack/VoiceOver)
  - _Requirements: 8.8_

- [x] 13. Add animations and transitions
  - Implement fade transition between questions
  - Add progress bar animation
  - Add button press feedback animations
  - Implement result screen entry animation
  - Add staggered fade-in for unit summary items
  - Ensure smooth navigation transitions
  - _Requirements: 8.1_
