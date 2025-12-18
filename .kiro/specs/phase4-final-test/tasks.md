# Implementation Plan

- [x] 1. Create Phase 4 Final Test question models
  - [x] 1.1 Create phase4_final_test_question.dart with union type
    - Define Phase4QuestionType enum (pronunciation, dialogue, listening, speaking)
    - Create Phase4FinalTestQuestion class with factory constructors for each type
    - Include id, type, unitId, lessonId, prompt, options, correctIndex, audioText fields
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  - [x] 1.2 Write property test for question model validity
    - **Property 10: Question Model Validity**
    - **Validates: Requirements 9.1, 9.2, 9.3, 9.4**

- [x] 2. Create Phase 4 Final Test result models
  - [x] 2.1 Create phase4_test_result.dart
    - Define SpeakingResult class with taskId, prompt, recognizedText, wordCount, score, feedback
    - Define Phase4TestResult class with mcqCorrect, speakingScore, totalScore, percentage, passed
    - Include incorrectMcqAnswers and speakingResults lists
    - Add factory constructor Phase4TestResult.calculate()
    - _Requirements: 6.1, 6.2, 6.3_
  - [x] 2.2 Write property test for pass/fail threshold
    - **Property 6: Pass/Fail Threshold**
    - **Validates: Requirements 6.2, 6.3**
  - [x] 2.3 Write property test for total score calculation
    - **Property 11: Total Score Calculation**
    - **Validates: Requirements 6.1**

- [x] 3. Create Phase4FinalTestService
  - [x] 3.1 Implement service skeleton with storage keys
    - Define storage keys: phase4_final_test_passed, phase4_final_test_score, phase5_unlocked
    - Define question distribution constants (6, 6, 4, 4)
    - Define passing score (18) and max score (24)
    - _Requirements: 8.1, 8.2, 8.3_
  - [x] 3.2 Implement canTakeTest() method
    - Check if all Phase 4 lessons (Units 18-21) are mastered
    - Return true if debug mode is enabled
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 3.3 Write property test for test access gating
    - **Property 1: Test Access Gating**
    - **Validates: Requirements 1.1, 1.2**
  - [x] 3.4 Write property test for debug mode bypass
    - **Property 2: Debug Mode Bypass**
    - **Validates: Requirements 1.3**

- [x] 4. Implement test generation in Phase4FinalTestService
  - [x] 4.1 Implement generateTest() method
    - Load Phase 4 lesson JSON files from assets/lessons/phase4/
    - Extract pronunciation questions from Unit 18 lessons
    - Extract dialogue questions from Unit 20-21 lessons
    - Extract listening questions from Phase 4 lessons
    - Extract speaking prompts from Unit 19 lessons
    - Randomly select 6 pronunciation, 6 dialogue, 4 listening, 4 speaking
    - _Requirements: 2.4, 3.4, 4.4, 10.1, 10.2, 10.4_
  - [x] 4.2 Implement fallback hardcoded questions
    - Create fallback questions for each type when lesson content is insufficient
    - Ensure 20 total questions are always returned
    - _Requirements: 10.3_
  - [x] 4.3 Write property test for question distribution
    - **Property 3: Question Distribution Consistency**
    - **Validates: Requirements 1.4, 2.1, 3.1, 4.1, 5.1, 10.2**
  - [x] 4.4 Write property test for fallback guarantee
    - **Property 12: Fallback Question Guarantee**
    - **Validates: Requirements 10.3**

- [x] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [x] 6. Implement scoring logic in Phase4FinalTestService
  - [x] 6.1 Implement validateMcqAnswer() method
    - Compare selectedIndex with correctIndex
    - Return true if match, false otherwise
    - _Requirements: 2.3, 3.3, 4.3_
  - [x] 6.2 Implement scoreSpeakingTask() method
    - Count words in recognized text
    - Return 3 for 20+ words, 2 for 10-19, 1 for 1-9, 0 for no output
    - Generate appropriate feedback message
    - _Requirements: 5.3, 5.4, 5.5_
  - [x] 6.3 Write property test for MCQ scoring
    - **Property 4: MCQ Scoring Consistency**
    - **Validates: Requirements 2.3, 3.3, 4.3**
  - [x] 6.4 Write property test for speaking score tiers
    - **Property 5: Speaking Score Tiers**
    - **Validates: Requirements 5.5**

- [x] 7. Implement result calculation and persistence
  - [x] 7.1 Implement calculateResult() method
    - Sum MCQ correct answers (0 or 1 each)
    - Sum speaking scores (0-3 each)
    - Calculate total score and percentage
    - Determine pass/fail (>= 18 points)
    - Collect incorrect MCQ answers for review
    - _Requirements: 6.1, 6.2, 6.3, 7.1_
  - [x] 7.2 Implement saveTestResult() method
    - Save phase4FinalTestPassed to storage
    - Save phase4FinalTestScore to storage
    - If passed, set phase5Unlocked to true
    - _Requirements: 8.1, 8.2, 8.3_
  - [x] 7.3 Write property test for result persistence
    - **Property 7: Result Persistence Consistency**
    - **Validates: Requirements 8.1, 8.2, 8.3**
  - [x] 7.4 Write property test for Phase 5 unlock
    - **Property 8: Phase 5 Unlock Consistency**
    - **Validates: Requirements 8.4**

- [x] 8. Implement review filtering
  - [x] 8.1 Implement getIncorrectMcqAnswers() method
    - Filter out speaking tasks from incorrect answers
    - Return only MCQ questions with wrong answers
    - _Requirements: 7.1, 7.3_
  - [x] 8.2 Write property test for review filtering
    - **Property 9: Review Filtering**
    - **Validates: Requirements 7.1, 7.3**

- [x] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Create Phase4FinalTestProvider
  - [x] 10.1 Implement provider class
    - Manage questions list and current index
    - Track answers (int? for MCQ, SpeakingResult for speaking)
    - Handle loading, error, and result states
    - _Requirements: 1.4, 12.1_
  - [x] 10.2 Implement test flow methods
    - startTest(): Load questions via service
    - selectMcqAnswer(int index): Record MCQ selection
    - recordSpeakingResult(SpeakingResult): Record speaking result
    - nextQuestion(): Advance to next question
    - skipQuestion(): Skip current question
    - submitTest(): Calculate and save result
    - _Requirements: 12.4_

- [x] 11. Create Phase4FinalTestScreen
  - [x] 11.1 Implement main test screen widget
    - Display progress bar and question counter (X/20)
    - Show locked state if lessons not mastered
    - Handle loading and error states
    - _Requirements: 1.2, 12.1_
  - [x] 11.2 Implement MCQ question display
    - Show prompt text
    - Display selectable options with visual feedback
    - Handle answer selection
    - _Requirements: 2.2, 3.2, 4.2, 12.2_
  - [x] 11.3 Implement speaking task display
    - Show prompt text
    - Display microphone button for recording
    - Show recording status and timer
    - Handle STT or mock scoring
    - _Requirements: 5.2, 12.3_
  - [x] 11.4 Implement navigation controls
    - Next button (enabled when answer selected or speaking recorded)
    - Skip button (always enabled)
    - Submit button on last question
    - _Requirements: 12.4_

- [x] 12. Create Phase4FinalTestResultScreen
  - [x] 12.1 Implement result screen widget
    - Display total score out of 24 and percentage
    - Show pass/fail status with appropriate message
    - Display Phase 5 unlock message if passed
    - _Requirements: 6.1, 6.2, 6.3_
  - [x] 12.2 Implement action buttons
    - "Review Mistakes" button (navigates to review screen)
    - "Continue" button if passed (navigates to home)
    - "Retry" button if failed (restarts test)
    - _Requirements: 6.4_

- [ ] 13. Create Phase4FinalTestReviewScreen
  - [ ] 13.1 Implement review screen widget
    - Display list of incorrect MCQ answers only
    - Show question prompt, correct answer, and user's selection
    - Exclude speaking tasks from review
    - _Requirements: 7.1, 7.2, 7.3_
  - [ ] 13.2 Implement navigation
    - Back button to return to results
    - Done button to return to home
    - _Requirements: 7.4_

- [ ] 14. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Add routes and navigation
  - [ ] 15.1 Add Phase 4 Final Test routes to AppRoutes
    - Add phase4FinalTest route constant ('/phase4/finalTest')
    - Add phase4FinalTestResult route constant ('/phase4/finalTest/result')
    - Add phase4FinalTestReview route constant ('/phase4/finalTest/review')
    - Add route handlers in onGenerateRoute
    - _Requirements: 11.1, 11.2, 11.3, 11.4_
  - [ ] 15.2 Update Phase4UnitScreen to show Final Test button
    - Add Final Test card/button below unit list
    - Show locked/unlocked status based on lesson mastery
    - Navigate to Phase4FinalTestScreen when tapped
    - _Requirements: 1.1, 1.2_

- [ ] 16. Register Phase4FinalTestProvider in main.dart
  - [ ] 16.1 Add provider to MultiProvider
    - Import Phase4FinalTestProvider
    - Add ChangeNotifierProvider for Phase4FinalTestProvider
    - Wire up dependencies (Phase4FinalTestService, StorageService)
    - _Requirements: 10.1_

- [ ] 17. Extend GatingService for Phase 5 unlock
  - [ ] 17.1 Add Phase 5 unlock checking
    - Add isPhase5Unlocked() method
    - Check phase4FinalTestPassed storage key
    - _Requirements: 8.4_

- [ ] 18. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

