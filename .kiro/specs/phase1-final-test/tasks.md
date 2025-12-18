# Implementation Plan

- [x] 1. Create data models for final test feature
  - Create `FinalTestQuestion` model class with JSON serialization
  - Create `TestResult` model class with accuracy calculation
  - Create `IncorrectAnswer` model class for review functionality
  - _Requirements: 2.2, 2.9, 5.2, 5.3, 5.4_

- [x] 2. Implement Phase1FinalTestService for test generation and management
  - [x] 2.1 Create service class with dependency injection for LessonRepository and StorageService
    - Initialize service with required dependencies
    - Define storage key constants
    - _Requirements: 2.1, 6.1, 6.2, 6.3_
  
  - [x] 2.2 Implement test generation logic
    - Create `generateTest()` method that loads all 6 Phase 1 lessons
    - Implement question extraction from practiceQuestions and masteryQuestions
    - Implement random selection with correct distribution (4-4-4-3-3-2)
    - Shuffle final question list
    - Add error handling for missing or insufficient questions
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10_
  
  - [x] 2.3 Implement answer validation and result calculation
    - Create `validateAnswer()` method to check if selected answer is correct
    - Create `calculateResult()` method to compute score, accuracy, and pass/fail status
    - Build list of incorrect answer details for review
    - _Requirements: 4.2, 4.3, 4.4, 4.5_
  
  - [x] 2.4 Implement local storage operations
    - Create `saveTestResult()` method to persist test results
    - Create `loadTestResult()` method to retrieve previous results
    - Create `hasPassedTest()` method to check pass status
    - Create `getLastTestScore()` method to retrieve score
    - Create `clearTestData()` method for retry functionality
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8_

- [x] 3. Create FinalTestProvider for state management
  - Initialize provider with Phase1FinalTestService dependency
  - Implement state properties (questions, answers, current index, loading, error)
  - Create `startTest()` method to generate and initialize test
  - Create `selectAnswer()` method to record user's answer selection
  - Create `nextQuestion()` and `previousQuestion()` methods for navigation
  - Create `submitTest()` method to calculate and save results
  - Implement computed getters (progress, canProceed, isLastQuestion)
  - Add proper error handling and loading states
  - _Requirements: 3.1, 3.2, 3.3, 3.6, 3.7, 3.8, 3.9_

- [x] 4. Build Phase1FinalTestScreen UI
  - [x] 4.1 Create screen scaffold with AppBar
    - Add back button navigation
    - Display title "Phase 1 – Final Test"
    - Display subtitle "Covering Lessons 1 to 6"
    - _Requirements: 1.2, 1.3, 8.1, 8.2_
  
  - [x] 4.2 Implement progress section
    - Display question counter "Question X/20"
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
    - Create Next button with enabled/disabled states
    - Disable button when no answer selected
    - Enable button when answer is selected
    - Handle navigation to next question or result screen
    - _Requirements: 3.6, 3.7, 3.8, 3.9_
  
  - [x] 4.6 Integrate with FinalTestProvider
    - Wrap screen with Consumer widget
    - Handle loading state with progress indicator
    - Handle error state with error message display
    - Implement test initialization on screen load
    - _Requirements: 1.1, 1.4, 7.4_

- [x] 5. Build Phase1FinalTestResultScreen UI
  - [x] 5.1 Create result screen scaffold
    - Add AppBar with back button
    - Display title "Test Results"
    - _Requirements: 4.1_
  
  - [x] 5.2 Implement score display section
    - Display completion title "Phase 1 Final Test – Completed!"
    - Show score in format "Score: X / 20"
    - Calculate and display accuracy percentage
    - Add success/failure icon based on pass status
    - Apply appropriate color coding (green for pass, red for fail)
    - _Requirements: 4.1, 4.2, 4.3, 8.1, 8.2_
  
  - [x] 5.3 Add status message
    - Display success message for passing score (>= 16)
    - Display encouragement message for failing score (< 16)
    - _Requirements: 4.4, 4.5_
  
  - [x] 5.4 Implement action buttons
    - Add "Review Mistakes" button (always visible if mistakes exist)
    - Add "Continue to Phase 2" button (only if passed)
    - Add "Retry Test" button (only if failed)
    - Implement navigation to review screen
    - Implement navigation to Phase 2 or test retry
    - _Requirements: 4.6, 4.7, 4.8_

- [x] 6. Build Phase1FinalTestReviewScreen UI
  - Create review screen scaffold with AppBar
  - Display "Review Mistakes" title
  - Implement ListView for incorrect answers
  - Display each incorrect question with question text
  - Show user's selected answer with red highlighting
  - Show correct answer with green highlighting
  - Display question number and lesson information
  - Handle empty state (perfect score scenario)
  - Add "Back to Results" button
  - Apply proper color coding and spacing
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 8.1, 8.2, 8.6_

- [x] 7. Integrate routing and navigation
  - [x] 7.1 Add route definitions to AppRoutes
    - Define `/phase1/finalTest` route constant
    - Define `/phase1/finalTest/result` route constant
    - Define `/phase1/finalTest/review` route constant
    - _Requirements: 7.1, 7.2_
  
  - [x] 7.2 Implement route handlers
    - Add case for phase1FinalTest route in onGenerateRoute
    - Add case for result screen route with TestResult argument
    - Add case for review screen route with incorrect answers argument
    - Handle missing arguments gracefully
    - _Requirements: 7.2, 7.3_
  
  - [x] 7.3 Add navigation from Phase1UnitScreen
    - Check if Lesson 6 is completed
    - Display final test card/button after Lesson 6
    - Show pass status if test was previously completed
    - Implement navigation to final test screen on tap
    - _Requirements: 1.1, 7.5_

- [x] 8. Register provider in main.dart
  - Import FinalTestProvider and Phase1FinalTestService
  - Create Phase1FinalTestService instance with dependencies
  - Add ChangeNotifierProvider for FinalTestProvider
  - Ensure proper initialization order with existing providers
  - _Requirements: 1.1, 2.1_

- [x] 9. Implement Phase 2 unlock mechanism
  - Update home screen to check phase1FinalTestPassed status
  - Conditionally enable/disable Phase 2 navigation based on test pass
  - Display lock icon or message if test not passed
  - Update UI to show Phase 2 as unlocked after passing test
  - _Requirements: 6.1, 6.8_

- [x] 10. Add error handling and edge cases
  - Handle lesson loading failures with user-friendly messages
  - Handle insufficient questions scenario gracefully
  - Handle storage failures with appropriate fallbacks
  - Add retry mechanism for failed operations
  - Implement proper error logging
  - _Requirements: 2.10_

- [x] 11. Implement accessibility features
  - Add semantic labels to all interactive elements
  - Implement screen reader announcements for question changes
  - Ensure proper focus management for keyboard navigation
  - Verify color contrast ratios meet WCAG standards
  - Test with screen reader (TalkBack/VoiceOver)
  - _Requirements: 8.8_

- [x] 12. Add animations and transitions
  - Implement fade transition between questions
  - Add progress bar animation
  - Add button press feedback animations
  - Implement result screen entry animation
  - Ensure smooth navigation transitions
  - _Requirements: 8.1_
