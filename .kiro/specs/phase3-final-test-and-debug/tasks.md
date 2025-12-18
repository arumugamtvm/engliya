# Implementation Plan

## Phase 3 Final Test

- [x] 1. Create data models for Phase 3 final test feature
  - Create `Phase3FinalTestQuestion` model class with JSON serialization and unitId tracking
  - Create `Phase3TestResult` model class with accuracy calculation and unit breakdown
  - Create `UnitPerformance` model class for per-unit performance tracking (if not already existing)
  - Reuse existing `IncorrectAnswer` model for review functionality
  - _Requirements: 2.1, 2.2, 2.3, 2.11, 5.2, 5.3, 5.4, 5.5_

- [x] 2. Implement Phase3FinalTestService for test generation and management
  - [x] 2.1 Create service class with dependency injection
    - Initialize service with LessonRepository and StorageService dependencies
    - Define storage key constants for Phase 3 test data
    - Define unit distribution map (6-7-5-5-4-3 for units 12-17)
    - Define lesson-to-unit mapping for all Phase 3 lessons
    - _Requirements: 2.1, 7.1, 7.2, 7.3, 7.4_

  - [x] 2.2 Implement test generation logic with unit distribution
    - Create `generateTest()` method that loads all Phase 3 lessons from assets/lessons/phase3
    - Implement unit grouping logic using lesson-to-unit mapping
    - Implement question extraction from practiceQuestions and masteryQuestions
    - Implement random selection with correct unit distribution:
      - Unit 12: 6 questions (Story Listening & Retelling)
      - Unit 13: 7 questions (Complex Sentences & Connectors)
      - Unit 14: 5 questions (Passive Voice)
      - Unit 15: 5 questions (Reported Speech)
      - Unit 16: 4 questions (Functional English)
      - Unit 17: 3 questions (Speaking & Writing Projects)
    - Tag each question with unitId for result breakdown
    - Shuffle final question list of 30 questions
    - Handle insufficient questions by reusing available questions
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11_

  - [x] 2.3 Implement question type support
    - Support Type A questions (Story Comprehension) with story fragment and options
    - Support Type B questions (Connector/Sentence Building) with grammar options
    - Support Type C questions (Transformations) for passive voice, reported speech, functional English
    - Ensure all questions are MCQ-based text only (no STT/audio)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [x] 2.4 Implement answer validation and result calculation with unit breakdown
    - Create `validateAnswer()` method to check if selected answer is correct
    - Create `calculateResult()` method to compute score, accuracy, and pass/fail status (24/30 = 80%)
    - Implement `_calculateUnitPerformance()` method for per-unit performance
    - Build unit breakdown map with UnitPerformance objects for all 6 units
    - Build list of incorrect answer details for review
    - _Requirements: 5.2, 5.3, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10, 5.11, 5.12_

  - [x] 2.5 Implement local storage operations with Phase 4 unlock
    - Create `saveTestResult()` method to persist test results
    - Save phase3FinalTestPassed, phase3FinalTestScore, phase3FinalTestTakenAt
    - Save phase4Unlocked flag when test is passed (score >= 24)
    - Create `loadTestResult()` method to retrieve previous results
    - Create `hasPassedTest()` method to check pass status
    - Create `getLastTestScore()` method to retrieve score
    - Create `areAllPhase3LessonsMastered()` method for lock/unlock logic (Units 12-16 required, Unit 17 optional)
    - Create `clearTestData()` method for retry functionality
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9_

- [x] 3. Create Phase3FinalTestProvider for state management
  - Initialize provider with Phase3FinalTestService dependency
  - Implement state properties (questions, answers, current index, loading, error)
  - Create `startTest()` method to generate and initialize test
  - Create `selectAnswer()` method to record user's answer selection
  - Create `skipQuestion()` method to allow skipping questions
  - Create `nextQuestion()` method for navigation
  - Create `submitTest()` method to calculate and save results
  - Create `canTakeTest()` method to check if all required lessons are mastered
  - Implement computed getters (progress, canProceed, isLastQuestion, totalQuestions=30)
  - Add proper error handling and loading states
  - _Requirements: 1.4, 1.5, 4.1, 4.2, 4.3, 4.6, 4.7, 4.8, 4.9, 4.10_

- [x] 4. Build Phase3FinalTestScreen UI
  - [x] 4.1 Create screen scaffold with AppBar
    - Add back button navigation
    - Display title "Phase 3 – Final Test"
    - Display subtitle "Real-Life Communication Check"
    - _Requirements: 1.2, 1.3, 13.1, 13.2_

  - [x] 4.2 Implement progress section
    - Display question counter "Question X / 30"
    - Add LinearProgressIndicator with percentage calculation
    - Style progress bar with visually distinct color
    - _Requirements: 4.2, 4.3, 13.5_

  - [x] 4.3 Build question display section
    - Display question text from promptEn field
    - Create scrollable container for long questions
    - Apply proper typography (minimum 16sp) and spacing
    - _Requirements: 4.4, 13.2, 13.6_

  - [x] 4.4 Implement answer options UI
    - Create four radio button options for each question
    - Implement option selection with visual feedback
    - Apply color coding for selected state
    - Ensure minimum touch target size (48x48 logical pixels)
    - _Requirements: 4.5, 4.6, 4.7, 13.3, 13.4, 13.7_

  - [x] 4.5 Add navigation controls
    - Create Skip button with secondary styling (optional)
    - Create Next button with enabled/disabled states
    - Disable Next button when no answer selected
    - Enable Next button when answer is selected
    - Handle navigation to next question or result screen on last question
    - _Requirements: 4.6, 4.7, 4.8, 4.9, 4.10_

  - [x] 4.6 Integrate with Phase3FinalTestProvider
    - Wrap screen with Consumer widget
    - Handle loading state with progress indicator
    - Handle error state with error message display
    - Implement test initialization on screen load
    - Handle locked state when lessons not mastered
    - _Requirements: 1.1, 1.4, 1.5, 8.5_

- [x] 5. Build Phase3FinalTestResultScreen UI
  - [x] 5.1 Create result screen scaffold
    - Add AppBar with back button
    - Display title "Test Results"
    - _Requirements: 5.1_

  - [x] 5.2 Implement score display section
    - Display completion title "Phase 3 Final Test Completed!"
    - Show score in format "Score: X / 30"
    - Calculate and display accuracy percentage "Accuracy: Y%"
    - Add success/failure icon based on pass status
    - Apply appropriate color coding (green for pass, red for fail)
    - _Requirements: 5.1, 5.2, 5.3, 13.1, 13.2_

  - [x] 5.3 Add status message
    - Display "PASSED ✅" with message "You have mastered Phase 3" for score >= 24
    - Display "NOT PASSED ❌" with message "You are close! Review Phase 3 lessons and try again" for score < 24
    - _Requirements: 5.11, 5.12_

  - [x] 5.4 Implement unit breakdown section
    - Create "Breakdown:" section header
    - Display Unit 12 performance: "Stories & Retelling: X / 6"
    - Display Unit 13 performance: "Connectors & Complex Sent.: X / 7"
    - Display Unit 14 performance: "Passive Voice: X / 5"
    - Display Unit 15 performance: "Reported Speech: X / 5"
    - Display Unit 16 performance: "Functional English: X / 4"
    - Display Unit 17 performance: "Projects & General Use: X / 3"
    - Apply color coding based on unit performance
    - _Requirements: 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10_

  - [x] 5.5 Implement action buttons
    - Add "Review Mistakes" button (visible if mistakes exist)
    - Add "Continue" button (only if passed)
    - Add "Retry Test" button (only if failed)
    - Implement navigation to review screen
    - Implement navigation to home or test retry
    - _Requirements: 5.13, 5.14, 5.15_

- [x] 6. Build Phase3FinalTestReviewScreen UI
  - Create review screen scaffold with AppBar
  - Display "Review Mistakes" title
  - Implement ListView for incorrect answers
  - Display each incorrect question with question text
  - Show unit and lesson badge for each question
  - Show user's selected answer with red highlighting (#FFEBEE background, #C62828 text)
  - Show correct answer with green highlighting (#E8F5E9 background, #2E7D32 text)
  - Display questions in the order they appeared in the test
  - Handle empty state with "Perfect score! No mistakes to review" message
  - Add "Back to Results" button
  - Apply proper color coding and spacing
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 13.1, 13.2, 13.6_

- [x] 7. Integrate routing and navigation for Phase 3 Final Test
  - [x] 7.1 Add route definitions to AppRoutes
    - Define `/phase3/finalTest` route constant
    - Define `/phase3/finalTest/result` route constant
    - Define `/phase3/finalTest/review` route constant
    - _Requirements: 8.1, 8.2_

  - [x] 7.2 Implement route handlers
    - Add case for phase3FinalTest route in onGenerateRoute
    - Add case for result screen route with Phase3TestResult argument
    - Add case for review screen route with incorrect answers argument
    - Support deep linking to the final test route
    - Handle missing arguments gracefully
    - _Requirements: 8.2, 8.3_

  - [x] 7.3 Add navigation from Phase3LessonListScreen
    - Check if all Phase 3 lessons (Units 12-16) are mastered
    - Display final test card at bottom of lesson list
    - Show lock status if lessons not mastered
    - Show pass status if test was previously completed
    - Implement navigation to final test screen on tap
    - _Requirements: 1.1, 8.4, 8.5_

## Debug Mode Feature

- [x] 8. Implement DebugService for debug mode operations
  - [x] 8.1 Create service class with dependency injection
    - Initialize service with StorageService and ProgressRepository dependencies
    - Define storage key constant for debugModeEnabled
    - Define activation tap count constant (5 taps)
    - _Requirements: 9.1, 9.5, 9.6, 9.7_

  - [x] 8.2 Implement debug mode toggle
    - Create `isDebugModeEnabled()` method to check current state
    - Create `setDebugMode(bool enabled)` method to enable/disable
    - Persist debugModeEnabled value across app sessions
    - _Requirements: 9.4, 9.5, 9.6, 9.7_

  - [x] 8.3 Implement unlock all functionality
    - Create `unlockAll()` method
    - Set phase1FinalTestPassed, phase2FinalTestPassed, phase3FinalTestPassed to true
    - Set phase2Unlocked, phase3Unlocked, phase4Unlocked to true
    - Create/update UserLessonStatus for every lesson across all phases:
      - isMastered = true
      - masteryBestScore = 1.0
      - quizBestScore = 1.0
      - timesAttempted = 1
      - completedAt = current timestamp
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 10.10, 10.11, 10.12, 10.13_

  - [x] 8.4 Implement reset all functionality
    - Create `resetAll()` method
    - Clear all UserLessonStatus data for all lessons
    - Set phase1FinalTestPassed, phase2FinalTestPassed, phase3FinalTestPassed to false
    - Clear all phaseXFinalTestScore values
    - Set phase2Unlocked, phase3Unlocked, phase4Unlocked to false
    - Set debugModeEnabled to false
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 11.10, 11.11_

  - [x] 8.5 Implement helper method to get all lesson IDs
    - Create `_getAllLessonIds()` method
    - Return lesson IDs for Phase 1 (lesson1 to lesson6)
    - Return lesson IDs for Phase 2 (lesson7_1 to lesson11_5)
    - Return lesson IDs for Phase 3 (lesson13_1 to lesson17_5)
    - _Requirements: 10.8, 11.2_

- [x] 9. Implement GatingService for centralized access control
  - Create GatingService class with StorageService, ProgressRepository, and DebugService dependencies
  - Create `isPhaseUnlocked(int phaseNumber)` method with debug mode bypass
  - Create `isLessonUnlocked(String lessonId)` method with debug mode bypass
  - Create `isFinalTestAccessible(int phaseNumber)` method with debug mode bypass
  - When debugModeEnabled is true, return true for all access checks
  - When debugModeEnabled is false, enforce normal gating logic
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7_

- [x] 10. Create DebugProvider for state management
  - Initialize provider with DebugService dependency
  - Implement state properties (isDebugModeEnabled, isProcessing, statusMessage)
  - Create `initialize()` method to load debug mode state
  - Create `toggleDebugMode(bool enabled)` method
  - Create `unlockAll()` method with processing state and status message
  - Create `resetAll()` method with processing state and status message
  - Create `clearStatus()` method to clear status message
  - Add proper error handling
  - _Requirements: 9.4, 9.5, 9.6, 10.13, 11.11_

- [x] 11. Build DebugScreen UI
  - [x] 11.1 Create screen scaffold
    - Add AppBar with back button
    - Display title "Debug Mode"
    - _Requirements: 9.3_

  - [x] 11.2 Implement debug mode toggle section
    - Display "Debug Mode" label
    - Add Switch widget labeled "Enable Debug Mode"
    - Connect to DebugProvider for state management
    - _Requirements: 9.4_

  - [x] 11.3 Implement action buttons
    - Add "Unlock All Phases & Lessons" button
    - Add "Reset All Progress" button
    - Show loading indicator when processing
    - _Requirements: 10.1, 11.1_

  - [x] 11.4 Implement status message display
    - Show success/error messages after operations
    - Display "✓ All content unlocked successfully" after unlock
    - Display appropriate message after reset
    - _Requirements: 10.13, 11.11_

  - [x] 11.5 Add close button
    - Add "Close" button to exit Debug Screen
    - Navigate back to previous screen
    - _Requirements: 11.12_

- [x] 12. Implement debug mode activation on Home Screen
  - [x] 12.1 Add tap counter logic
    - Track consecutive long-presses on app title
    - Reset counter if more than 2 seconds between taps
    - Navigate to Debug Screen after 5 consecutive long-presses
    - _Requirements: 9.1, 9.2_

  - [x] 12.2 Add debug mode indicator
    - Display "Debug Mode ON" or "DEV" label in app bar when enabled
    - Use small, unobtrusive indicator (12sp, Deep Orange color)
    - _Requirements: 9.8_

- [x] 13. Integrate routing for Debug Screen
  - Add `/debug` route constant to AppRoutes
  - Add case for debug route in onGenerateRoute
  - _Requirements: 9.2_

- [x] 14. Update existing gating logic to use GatingService
  - Update home screen phase unlock checks to use GatingService
  - Update lesson list screens to use GatingService for lesson access
  - Update final test screens to use GatingService for test access
  - Ensure debug mode bypass works across all screens
  - _Requirements: 12.1, 12.2, 12.3, 12.6, 12.7_

## Provider Registration and Integration

- [x] 15. Register providers in main.dart
  - Import Phase3FinalTestProvider, Phase3FinalTestService
  - Import DebugProvider, DebugService, GatingService
  - Create service instances with dependencies
  - Add ChangeNotifierProvider for Phase3FinalTestProvider
  - Add ChangeNotifierProvider for DebugProvider
  - Ensure proper initialization order with existing providers
  - _Requirements: 1.1, 2.1, 9.1_

- [x] 16. Implement Phase 4 unlock mechanism
  - Update home screen to check phase3FinalTestPassed status
  - Set phase4Unlocked flag when test is passed
  - Conditionally enable/disable Phase 4 navigation based on unlock status
  - Display lock icon or message if test not passed
  - Update UI to show Phase 4 as unlocked after passing test
  - _Requirements: 7.4, 7.9_

## Error Handling and Polish

- [x] 17. Add error handling and edge cases
  - Handle lesson loading failures with user-friendly messages
  - Handle insufficient questions scenario gracefully (reuse questions)
  - Handle storage failures with appropriate fallbacks
  - Add retry mechanism for failed operations
  - Implement proper error logging
  - Handle navigation errors gracefully
  - Handle debug mode activation/unlock/reset failures
  - _Requirements: 2.10_

- [x] 18. Implement accessibility features
  - Add semantic labels to all interactive elements
  - Implement screen reader announcements for question changes
  - Ensure proper focus management for keyboard navigation
  - Verify color contrast ratios meet WCAG standards (minimum 4.5:1)
  - Don't rely solely on color for unit performance indicators
  - Clearly announce when debug mode is enabled
  - Test with screen reader (TalkBack/VoiceOver)
  - _Requirements: 13.8_

- [x] 19. Add animations and transitions
  - Implement fade + slide transition between questions (300ms)
  - Add progress bar animation (200ms)
  - Add button press feedback animations (100ms)
  - Implement result screen entry animation (fade + scale, 400ms)
  - Add staggered fade-in for unit summary items
  - Ensure smooth navigation transitions
  - _Requirements: 13.1_
