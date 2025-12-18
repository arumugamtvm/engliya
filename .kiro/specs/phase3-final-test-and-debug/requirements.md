# Requirements Document

## Introduction

This specification covers two distinct features for the English learning app: (1) Phase 3 Final Test - a comprehensive assessment evaluating students' mastery of all Phase 3 content (Units 12-17: Story Listening & Retelling, Complex Sentences & Connectors, Passive Voice, Reported Speech, Functional English, and Speaking & Writing Projects), and (2) Debug Mode - a developer-only tool that allows bypassing all gating logic and unlocking all content for testing purposes. The Phase 3 Final Test consists of 30 MCQ-based questions with unit-level performance breakdown, while Debug Mode provides one-tap access to unlock all phases, lessons, and test completions.

## Glossary

- **Phase3 Final Test System**: The complete testing feature including question generation, test execution, scoring, result persistence, and Phase 4 unlocking for Phase 3 content
- **Test Generator Service**: The service responsible for loading Phase 3 lesson JSON files and creating randomized test questions with proper unit distribution
- **Test Question**: A single assessment item derived from practiceQuestions or masteryQuestions in Phase 3 lesson JSON files
- **Test Session**: A single attempt at the Phase 3 Final Test consisting of 30 questions
- **Result Screen**: The UI component that displays the test score, accuracy, unit-level breakdown, and completion status
- **Review Screen**: The UI component that shows incorrect answers with correct solutions
- **Unit Distribution**: The allocation of questions across six Phase 3 units (Unit 12: 6 questions, Unit 13: 7 questions, Unit 14: 5 questions, Unit 15: 5 questions, Unit 16: 4 questions, Unit 17: 3 questions)
- **Question Type**: The category of question (Type A: Story Comprehension, Type B: Connector/Sentence Building, Type C: Transformations)
- **Local Storage Service**: The persistence layer that stores test results, completion status, and debug mode settings
- **Phase Unlock**: The mechanism that grants access to Phase 4 content after passing the final test
- **Passing Threshold**: The minimum score (80% or 24/30 questions) required to pass the test
- **Debug Mode**: A developer-only feature that bypasses all gating logic and allows one-tap unlocking of all content
- **Debug Screen**: The UI component that provides controls for enabling debug mode, unlocking all content, and resetting progress
- **Gating Logic**: The system that controls access to phases, lessons, and tests based on completion status

## Requirements

### Requirement 1: Phase 3 Final Test Access

**User Story:** As a student who has mastered all core Phase 3 lessons, I want to access a comprehensive final test, so that I can demonstrate my mastery of all Phase 3 content

#### Acceptance Criteria

1. WHEN THE Student masters all lessons in Units 12-16, THE Phase3 Final Test System SHALL display a navigation option to access the Phase 3 Final Test
2. WHEN THE Student navigates to the final test route, THE Phase3 Final Test System SHALL display a screen with title "Phase 3 – Final Test" and subtitle "Real-Life Communication Check"
3. THE Phase3 Final Test System SHALL provide a back navigation button to return to the previous screen
4. WHEN THE Student has not mastered all required Phase 3 lessons, THE Phase3 Final Test System SHALL display a locked state with message "Please master all Phase 3 lessons before taking the Final Test"
5. WHEN THE Student has not yet started the test, THE Phase3 Final Test System SHALL display a start button to begin the test session
6. THE Phase3 Final Test System SHALL treat Unit 17 project lessons as optional for test access purposes

### Requirement 2: Phase 3 Test Question Generation

**User Story:** As a student taking the final test, I want questions to be randomly selected from all six Phase 3 units with proper distribution, so that each test attempt comprehensively covers all Phase 3 topics

#### Acceptance Criteria

1. WHEN THE Test Generator Service creates a test, THE Test Generator Service SHALL load all Phase 3 lesson JSON files from the assets/lessons/phase3 directory
2. WHEN THE Test Generator Service processes lesson data, THE Test Generator Service SHALL extract questions from both practiceQuestions and masteryQuestions arrays
3. THE Test Generator Service SHALL select exactly 6 questions from Unit 12 lessons (Story Listening & Retelling)
4. THE Test Generator Service SHALL select exactly 7 questions from Unit 13 lessons (Complex Sentences & Connectors)
5. THE Test Generator Service SHALL select exactly 5 questions from Unit 14 lessons (Passive Voice)
6. THE Test Generator Service SHALL select exactly 5 questions from Unit 15 lessons (Reported Speech)
7. THE Test Generator Service SHALL select exactly 4 questions from Unit 16 lessons (Functional English)
8. THE Test Generator Service SHALL select exactly 3 questions from Unit 17 lessons (Speaking & Writing Projects)
9. WHEN THE Test Generator Service completes question selection, THE Test Generator Service SHALL shuffle the final list of 30 questions to randomize order
10. WHEN THE Test Generator Service encounters insufficient questions in a unit, THE Test Generator Service SHALL reuse available questions or select from related lessons in that unit
11. THE Test Generator Service SHALL tag each question with its source unitId for result breakdown purposes

### Requirement 3: Phase 3 Test Question Types

**User Story:** As a student taking the test, I want to encounter diverse question types that assess different aspects of Phase 3 content, so that the test comprehensively evaluates my skills

#### Acceptance Criteria

1. THE Test Generator Service SHALL support Type A questions (Story Comprehension) with a story fragment prompt and four answer options
2. THE Test Generator Service SHALL support Type B questions (Connector/Sentence Building) with sentence options where only one is grammatically correct
3. THE Test Generator Service SHALL support Type C questions (Transformations) including passive voice, reported speech, and functional English transformations
4. THE Test Generator Service SHALL ensure Type A questions include a short story or summary followed by a comprehension question
5. THE Test Generator Service SHALL ensure Type B questions test proper use of connectors and sentence structure
6. THE Test Generator Service SHALL ensure Type C questions test transformations between active/passive voice, direct/reported speech, or formal/informal English
7. THE Test Generator Service SHALL use only MCQ-based text questions without requiring speech-to-text or audio playback

### Requirement 4: Phase 3 Test Execution

**User Story:** As a student taking the test, I want to answer multiple-choice questions one at a time with clear progress tracking, so that I can focus on each question without distraction

#### Acceptance Criteria

1. THE Phase3 Final Test System SHALL display one question at a time with its answer options
2. THE Phase3 Final Test System SHALL display a progress indicator showing "Question X / 30" where X is the current question number
3. THE Phase3 Final Test System SHALL display a visual progress bar showing percentage completion calculated as (current question / 30 * 100)
4. THE Phase3 Final Test System SHALL render the question text in English from the promptEn field
5. THE Phase3 Final Test System SHALL display four radio button options corresponding to the question's options array
6. WHEN THE Student has not selected an option, THE Phase3 Final Test System SHALL disable the Next button
7. WHEN THE Student selects an option, THE Phase3 Final Test System SHALL enable the Next button
8. THE Phase3 Final Test System SHALL provide an optional Skip button that allows advancing without selecting an answer
9. WHEN THE Student clicks the Next button, THE Phase3 Final Test System SHALL record the selected answer and advance to the next question
10. WHEN THE Student is on the last question and clicks Next, THE Phase3 Final Test System SHALL complete the test and navigate to the Result Screen

### Requirement 5: Phase 3 Test Results Display

**User Story:** As a student who completed the test, I want to see my overall score and per-unit performance breakdown, so that I understand my strengths and weaknesses across Phase 3 topics

#### Acceptance Criteria

1. WHEN THE Test Session completes, THE Result Screen SHALL display the title "Phase 3 Final Test Completed!"
2. THE Result Screen SHALL display the student's overall score in the format "Score: X / 30" where X is the number of correct answers
3. THE Result Screen SHALL calculate and display overall accuracy as a percentage in the format "Accuracy: Y%" where Y equals (correct answers / 30) * 100
4. THE Result Screen SHALL display a breakdown section showing performance by unit
5. THE Result Screen SHALL display Unit 12 performance as "Stories & Retelling: X / 6" where X is correct answers for Unit 12
6. THE Result Screen SHALL display Unit 13 performance as "Connectors & Complex Sent.: X / 7" where X is correct answers for Unit 13
7. THE Result Screen SHALL display Unit 14 performance as "Passive Voice: X / 5" where X is correct answers for Unit 14
8. THE Result Screen SHALL display Unit 15 performance as "Reported Speech: X / 5" where X is correct answers for Unit 15
9. THE Result Screen SHALL display Unit 16 performance as "Functional English: X / 4" where X is correct answers for Unit 16
10. THE Result Screen SHALL display Unit 17 performance as "Projects & General Use: X / 3" where X is correct answers for Unit 17
11. WHEN THE Student scores 24 or more correct answers, THE Result Screen SHALL display status "PASSED ✅" with message "You have mastered Phase 3"
12. WHEN THE Student scores less than 24 correct answers, THE Result Screen SHALL display status "NOT PASSED ❌" with message "You are close! Review Phase 3 lessons and try again"
13. THE Result Screen SHALL provide a "Review Mistakes" button to view incorrect answers
14. WHEN THE Student scores 24 or more correct answers, THE Result Screen SHALL provide a "Continue" button
15. WHEN THE Student scores less than 24 correct answers, THE Result Screen SHALL provide a "Retry Test" button

### Requirement 6: Phase 3 Test Review

**User Story:** As a student who made mistakes on the test, I want to review my incorrect answers with the correct solutions, so that I can learn from my errors

#### Acceptance Criteria

1. WHEN THE Student clicks "Review Mistakes" on the Result Screen, THE Review Screen SHALL display all incorrectly answered questions
2. WHEN THE Student answered all questions correctly, THE Review Screen SHALL display a message "Perfect score! No mistakes to review"
3. THE Review Screen SHALL display each incorrect question with its original question text
4. THE Review Screen SHALL display the correct answer for each incorrect question
5. THE Review Screen SHALL display the student's selected answer for each incorrect question
6. THE Review Screen SHALL visually distinguish the correct answer from the incorrect answer using color coding
7. THE Review Screen SHALL provide a "Back to Results" button to return to the Result Screen
8. THE Review Screen SHALL display questions in the order they appeared in the test

### Requirement 7: Phase 3 Test Persistence and Phase 4 Unlock

**User Story:** As a student who passed the final test, I want my achievement to be saved and Phase 4 to be unlocked, so that I can continue my learning journey

#### Acceptance Criteria

1. WHEN THE Student scores 24 or more correct answers, THE Local Storage Service SHALL save phase3FinalTestPassed with value true
2. WHEN THE Student scores 24 or more correct answers, THE Local Storage Service SHALL save phase3FinalTestScore with the numeric score value
3. WHEN THE Student scores 24 or more correct answers, THE Local Storage Service SHALL save phase3FinalTestTakenAt with the current timestamp
4. WHEN THE Student scores 24 or more correct answers, THE Local Storage Service SHALL save phase4Unlocked with value true
5. WHEN THE Student scores less than 24 correct answers, THE Local Storage Service SHALL save phase3FinalTestPassed with value false
6. WHEN THE Student scores less than 24 correct answers, THE Local Storage Service SHALL save the score and timestamp but not unlock Phase 4
7. THE Local Storage Service SHALL persist test results across app sessions
8. WHEN THE Student retakes the test, THE Local Storage Service SHALL update the stored values with the most recent test results
9. THE Phase3 Final Test System SHALL read phase3FinalTestPassed value to determine Phase 4 accessibility

### Requirement 8: Phase 3 Test Routing

**User Story:** As a student navigating the app, I want the final test to be accessible through proper routing, so that I can easily find and access the test

#### Acceptance Criteria

1. THE Phase3 Final Test System SHALL register the route "/phase3/finalTest" in the app router
2. WHEN THE Student navigates to "/phase3/finalTest", THE Phase3 Final Test System SHALL display the Phase 3 Final Test screen
3. THE Phase3 Final Test System SHALL support deep linking to the final test route
4. THE Phase3 Final Test System SHALL provide navigation from the Phase 3 lesson list screen to the final test
5. WHEN THE Student has not mastered all required Phase 3 lessons, THE Phase3 Final Test System SHALL display a locked state preventing test access

### Requirement 9: Debug Mode Activation

**User Story:** As a developer testing the app, I want to activate a hidden debug mode, so that I can bypass gating logic and test all features without completing prerequisites

#### Acceptance Criteria

1. WHEN THE Developer long-presses the app title on the Home Screen 5 times consecutively, THE Debug Screen SHALL become accessible
2. THE Phase3 Final Test System SHALL provide a navigation option to the Debug Screen after activation
3. THE Debug Screen SHALL display the title "Debug Mode"
4. THE Debug Screen SHALL provide a toggle switch labeled "Enable Debug Mode"
5. WHEN THE Developer toggles the switch to enabled, THE Local Storage Service SHALL save debugModeEnabled with value true
6. WHEN THE Developer toggles the switch to disabled, THE Local Storage Service SHALL save debugModeEnabled with value false
7. THE Local Storage Service SHALL persist debugModeEnabled value across app sessions
8. WHEN debugModeEnabled is true, THE Home Screen SHALL display a small "Debug Mode ON" or "DEV" label in the app bar

### Requirement 10: Debug Mode Unlock All

**User Story:** As a developer testing the app, I want to unlock all phases and lessons with one tap, so that I can quickly test any feature without manual progression

#### Acceptance Criteria

1. THE Debug Screen SHALL provide a button labeled "Unlock All Phases & Lessons"
2. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL save phase1FinalTestPassed with value true
3. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL save phase2FinalTestPassed with value true
4. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL save phase3FinalTestPassed with value true
5. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL save phase2Unlocked with value true
6. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL save phase3Unlocked with value true
7. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL save phase4Unlocked with value true
8. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL create or update UserLessonStatus for every lesson across all phases with isMastered set to true
9. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL set masteryBestScore to 1.0 for every lesson
10. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL set quizBestScore to 1.0 for every lesson
11. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL set timesAttempted to 1 for every lesson
12. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Local Storage Service SHALL set completedAt to the current timestamp for every lesson
13. WHEN THE Developer clicks "Unlock All Phases & Lessons", THE Phase3 Final Test System SHALL immediately reflect the unlocked state in all UI components

### Requirement 11: Debug Mode Reset All

**User Story:** As a developer testing the app, I want to reset all progress to a fresh state, so that I can test the onboarding and progression flow from the beginning

#### Acceptance Criteria

1. THE Debug Screen SHALL provide a button labeled "Reset All Progress"
2. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL clear all UserLessonStatus data for all lessons
3. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL set phase1FinalTestPassed to false
4. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL set phase2FinalTestPassed to false
5. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL set phase3FinalTestPassed to false
6. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL clear all phaseXFinalTestScore values
7. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL set phase2Unlocked to false
8. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL set phase3Unlocked to false
9. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL set phase4Unlocked to false
10. WHEN THE Developer clicks "Reset All Progress", THE Local Storage Service SHALL set debugModeEnabled to false
11. WHEN THE Developer clicks "Reset All Progress", THE Phase3 Final Test System SHALL immediately reflect the reset state in all UI components
12. THE Debug Screen SHALL provide a "Close" button to exit the Debug Screen

### Requirement 12: Debug Mode Gating Bypass

**User Story:** As a developer with debug mode enabled, I want all gating logic to be bypassed, so that I can access any phase or lesson regardless of completion status

#### Acceptance Criteria

1. WHEN debugModeEnabled is true, THE Phase3 Final Test System SHALL treat all phases as unlocked
2. WHEN debugModeEnabled is true, THE Phase3 Final Test System SHALL treat all lessons as unlocked
3. WHEN debugModeEnabled is true, THE Phase3 Final Test System SHALL allow access to all final tests regardless of lesson completion
4. WHEN debugModeEnabled is true, THE Phase3 Final Test System SHALL still display accurate mastery status from local storage
5. WHEN debugModeEnabled is true, THE Phase3 Final Test System SHALL still allow normal progression and status updates
6. WHEN debugModeEnabled is false, THE Phase3 Final Test System SHALL enforce all normal gating logic
7. THE Phase3 Final Test System SHALL check debugModeEnabled value before applying any access restrictions

### Requirement 13: Phase 3 Test UI Consistency

**User Story:** As a student taking the test, I want the interface to be clean and consistent with the app design, so that I can focus on answering questions without confusion

#### Acceptance Criteria

1. THE Phase3 Final Test System SHALL use consistent typography and spacing matching the existing app theme
2. THE Phase3 Final Test System SHALL display questions with sufficient font size for readability (minimum 16sp)
3. THE Phase3 Final Test System SHALL provide adequate touch targets for radio buttons (minimum 48x48 logical pixels)
4. THE Phase3 Final Test System SHALL use color coding to indicate selected options
5. THE Phase3 Final Test System SHALL display the progress bar with a visually distinct color
6. THE Phase3 Final Test System SHALL maintain consistent padding and margins throughout the test interface
7. THE Phase3 Final Test System SHALL use the app's primary color scheme for buttons and interactive elements
8. THE Phase3 Final Test System SHALL ensure text contrast meets accessibility standards (minimum 4.5:1 ratio)
