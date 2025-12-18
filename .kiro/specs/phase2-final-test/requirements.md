# Requirements Document

## Introduction

The Phase 2 Final Mastery Test is a comprehensive assessment feature that evaluates students' understanding of all five Phase 2 units (Units 7-11: Time & Place Prepositions, Continuous Tenses, Perfect Tenses, Questions & Negatives, and Advanced Pronouns/Adjectives/Adverbs). This test will be accessible after students master all Phase 2 lessons and will consist of 25 randomly generated questions from the existing Phase 2 lesson content. The feature includes a test screen, result screen with unit-level breakdown, and review screen to provide students with detailed feedback on their performance and unlock access to Phase 3 content upon successful completion.

## Glossary

- **Phase2 Final Test System**: The complete testing feature including question generation, test execution, scoring, result persistence, and Phase 3 unlocking
- **Test Generator Service**: The service responsible for loading Phase 2 lesson JSON files and creating randomized test questions with proper unit distribution
- **Test Question**: A single assessment item derived from practiceQuestions or masteryQuestions in Phase 2 lesson JSON files
- **Test Session**: A single attempt at the Phase 2 Final Test consisting of 25 questions
- **Result Screen**: The UI component that displays the test score, accuracy, unit-level breakdown, and completion status
- **Review Screen**: The UI component that shows incorrect answers with correct solutions
- **Unit Distribution**: The allocation of questions across five Phase 2 units (Unit 7: 5 questions, Unit 8: 6 questions, Unit 9: 5 questions, Unit 10: 5 questions, Unit 11: 4 questions)
- **Local Storage Service**: The persistence layer that stores test results and completion status
- **Phase Unlock**: The mechanism that grants access to Phase 3 content after passing the final test
- **Passing Threshold**: The minimum score (80% or 20/25 questions) required to pass the test
- **Unit Summary**: Per-unit performance breakdown showing correct/total questions for each unit

## Requirements

### Requirement 1

**User Story:** As a student who has mastered all Phase 2 lessons, I want to access a comprehensive final test, so that I can demonstrate my mastery of all Phase 2 content

#### Acceptance Criteria

1. WHEN THE Student masters all Phase 2 lessons, THE Phase2 Final Test System SHALL display a navigation option to access the Phase 2 Final Test
2. WHEN THE Student navigates to the final test route, THE Phase2 Final Test System SHALL display a screen with title "Phase 2 – Final Test" and subtitle "Units 7–11 • 25 Questions"
3. THE Phase2 Final Test System SHALL provide a back navigation button to return to the previous screen
4. WHEN THE Student has not mastered all Phase 2 lessons, THE Phase2 Final Test System SHALL display a locked state with message "Please master all Phase 2 lessons before taking the final test"
5. WHEN THE Student has not yet started the test, THE Phase2 Final Test System SHALL display a start button to begin the test session

### Requirement 2

**User Story:** As a student taking the final test, I want questions to be randomly selected from all five Phase 2 units with proper distribution, so that each test attempt comprehensively covers all Phase 2 topics

#### Acceptance Criteria

1. WHEN THE Test Generator Service creates a test, THE Test Generator Service SHALL load all Phase 2 lesson JSON files from the assets/lessons/phase2 directory
2. WHEN THE Test Generator Service processes lesson data, THE Test Generator Service SHALL extract questions from both practiceQuestions and masteryQuestions arrays
3. THE Test Generator Service SHALL select exactly 5 questions from Unit 7 lessons (Time & Place Prepositions)
4. THE Test Generator Service SHALL select exactly 6 questions from Unit 8 lessons (Continuous Tenses)
5. THE Test Generator Service SHALL select exactly 5 questions from Unit 9 lessons (Perfect Tenses)
6. THE Test Generator Service SHALL select exactly 5 questions from Unit 10 lessons (Questions & Negatives)
7. THE Test Generator Service SHALL select exactly 4 questions from Unit 11 lessons (Advanced Pronouns, Adjectives & Adverbs)
8. WHEN THE Test Generator Service completes question selection, THE Test Generator Service SHALL shuffle the final list of 25 questions to randomize order
9. WHEN THE Test Generator Service encounters insufficient questions in a unit, THE Test Generator Service SHALL log an error and use all available questions
10. THE Test Generator Service SHALL tag each question with its source unitId for result breakdown purposes

### Requirement 3

**User Story:** As a student taking the test, I want to answer multiple-choice questions one at a time with clear progress tracking, so that I can focus on each question without distraction

#### Acceptance Criteria

1. THE Phase2 Final Test System SHALL display one question at a time with its answer options
2. THE Phase2 Final Test System SHALL display a progress indicator showing "Question X / 25" where X is the current question number
3. THE Phase2 Final Test System SHALL display a visual progress bar showing percentage completion calculated as (current question / 25 * 100)
4. THE Phase2 Final Test System SHALL render the question text in English from the promptEn field
5. THE Phase2 Final Test System SHALL display answer options as radio buttons corresponding to the question's options array
6. WHEN THE Student has not selected an option, THE Phase2 Final Test System SHALL disable the Next button
7. WHEN THE Student selects an option, THE Phase2 Final Test System SHALL enable the Next button
8. THE Phase2 Final Test System SHALL provide an optional Skip button that allows advancing without selecting an answer
9. WHEN THE Student clicks the Next button, THE Phase2 Final Test System SHALL record the selected answer and advance to the next question
10. WHEN THE Student is on the last question and clicks Next, THE Phase2 Final Test System SHALL complete the test and navigate to the Result Screen

### Requirement 4

**User Story:** As a student who completed the test, I want to see my overall score and per-unit performance breakdown, so that I understand my strengths and weaknesses across Phase 2 topics

#### Acceptance Criteria

1. WHEN THE Test Session completes, THE Result Screen SHALL display the title "Phase 2 Final Test Completed!"
2. THE Result Screen SHALL display the student's overall score in the format "Score: X / 25" where X is the number of correct answers
3. THE Result Screen SHALL calculate and display overall accuracy as a percentage in the format "Accuracy: Y%" where Y equals (correct answers / 25) * 100
4. THE Result Screen SHALL display a summary section showing performance breakdown by unit
5. THE Result Screen SHALL display Unit 7 performance as "Time & Place: X / 5" where X is correct answers for Unit 7
6. THE Result Screen SHALL display Unit 8 performance as "Continuous Tenses: X / 6" where X is correct answers for Unit 8
7. THE Result Screen SHALL display Unit 9 performance as "Perfect Tenses: X / 5" where X is correct answers for Unit 9
8. THE Result Screen SHALL display Unit 10 performance as "Questions/Neg: X / 5" where X is correct answers for Unit 10
9. THE Result Screen SHALL display Unit 11 performance as "Adj/Adv/Pronouns: X / 4" where X is correct answers for Unit 11
10. WHEN THE Student scores 20 or more correct answers, THE Result Screen SHALL display a success message "You have mastered Phase 2"
11. WHEN THE Student scores less than 20 correct answers, THE Result Screen SHALL display a message "You scored X%. Try again to pass Phase 2"
12. THE Result Screen SHALL provide a "Review Mistakes" button to view incorrect answers
13. WHEN THE Student scores 20 or more correct answers, THE Result Screen SHALL provide a "Continue" button
14. WHEN THE Student scores less than 20 correct answers, THE Result Screen SHALL provide a "Retry Test" button

### Requirement 5

**User Story:** As a student who made mistakes on the test, I want to review my incorrect answers with the correct solutions, so that I can learn from my errors

#### Acceptance Criteria

1. WHEN THE Student clicks "Review Mistakes" on the Result Screen, THE Review Screen SHALL display all incorrectly answered questions
2. WHEN THE Student answered all questions correctly, THE Review Screen SHALL display a message "Perfect score! No mistakes to review"
3. THE Review Screen SHALL display each incorrect question with its original question text
4. THE Review Screen SHALL display the correct answer for each incorrect question
5. THE Review Screen SHALL display the student's selected answer for each incorrect question
6. THE Review Screen SHALL visually distinguish the correct answer from the incorrect answer using color coding
7. THE Review Screen SHALL display the unit and lesson source for each incorrect question
8. THE Review Screen SHALL provide a "Back to Results" button to return to the Result Screen
9. THE Review Screen SHALL display questions in the order they appeared in the test

### Requirement 6

**User Story:** As a student who passed the final test, I want my achievement to be saved and Phase 3 to be unlocked, so that I can continue my learning journey

#### Acceptance Criteria

1. WHEN THE Student scores 20 or more correct answers, THE Local Storage Service SHALL save phase2FinalTestPassed with value true
2. WHEN THE Student scores 20 or more correct answers, THE Local Storage Service SHALL save phase2FinalTestScore with the numeric score value
3. WHEN THE Student scores 20 or more correct answers, THE Local Storage Service SHALL save phase2FinalTestTakenAt with the current timestamp
4. WHEN THE Student scores 20 or more correct answers, THE Local Storage Service SHALL save phase3Unlocked with value true
5. WHEN THE Student scores less than 20 correct answers, THE Local Storage Service SHALL save phase2FinalTestPassed with value false
6. WHEN THE Student scores less than 20 correct answers, THE Local Storage Service SHALL save the score and timestamp but not unlock Phase 3
7. THE Local Storage Service SHALL persist test results across app sessions
8. WHEN THE Student retakes the test, THE Local Storage Service SHALL update the stored values with the most recent test results
9. THE Phase2 Final Test System SHALL read phase2FinalTestPassed value to determine Phase 3 accessibility

### Requirement 7

**User Story:** As a student navigating the app, I want the final test to be accessible through proper routing, so that I can easily find and access the test

#### Acceptance Criteria

1. THE Phase2 Final Test System SHALL register the route "/phase2/finalTest" in the app router
2. WHEN THE Student navigates to "/phase2/finalTest", THE Phase2 Final Test System SHALL display the Phase 2 Final Test screen
3. THE Phase2 Final Test System SHALL support deep linking to the final test route
4. THE Phase2 Final Test System SHALL provide navigation from the Phase 2 lesson list screen to the final test
5. WHEN THE Student has not mastered all Phase 2 lessons, THE Phase2 Final Test System SHALL display a locked state preventing test access

### Requirement 8

**User Story:** As a student taking the test, I want the interface to be clean and consistent with the app design, so that I can focus on answering questions without confusion

#### Acceptance Criteria

1. THE Phase2 Final Test System SHALL use consistent typography and spacing matching the existing app theme
2. THE Phase2 Final Test System SHALL display questions with sufficient font size for readability (minimum 16sp)
3. THE Phase2 Final Test System SHALL provide adequate touch targets for radio buttons (minimum 48x48 logical pixels)
4. THE Phase2 Final Test System SHALL use color coding to indicate selected options
5. THE Phase2 Final Test System SHALL display the progress bar with a visually distinct color
6. THE Phase2 Final Test System SHALL maintain consistent padding and margins throughout the test interface
7. THE Phase2 Final Test System SHALL use the app's primary color scheme for buttons and interactive elements
8. THE Phase2 Final Test System SHALL ensure text contrast meets accessibility standards (minimum 4.5:1 ratio)

### Requirement 9

**User Story:** As a student viewing the home screen, I want to see my Phase 2 Final Test status, so that I know whether I need to take or retake the test

#### Acceptance Criteria

1. WHEN THE Student has passed the Phase 2 Final Test, THE Home Screen SHALL display "Phase 2: Completed (Score: X/25)"
2. WHEN THE Student has attempted but not passed the test, THE Home Screen SHALL display "Phase 2 Final Test: Last score X/25"
3. WHEN THE Student has not attempted the test, THE Home Screen SHALL display "Phase 2 Final Test: Ready" if all lessons are mastered
4. WHEN THE Student has not mastered all Phase 2 lessons, THE Home Screen SHALL display "Phase 2 Final Test: Locked"
5. THE Home Screen SHALL provide a visual indicator (icon or badge) showing test completion status
