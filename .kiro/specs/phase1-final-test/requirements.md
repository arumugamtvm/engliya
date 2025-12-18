# Requirements Document

## Introduction

The Phase 1 Final Mastery Test is a comprehensive assessment feature that evaluates students' understanding of all six Phase 1 lessons (Pronouns, Be Verb, Nouns & Articles, Object Pronouns, Action Verbs, and Simple Present). This test will be accessible after students complete Lesson 6 and will consist of 20 randomly generated questions from the existing lesson content. The feature includes a test screen, result screen, and review screen to provide students with feedback on their performance and unlock access to Phase 2 content upon successful completion.

## Glossary

- **Final Test System**: The complete testing feature including question generation, test execution, scoring, and result persistence
- **Test Generator Service**: The service responsible for loading lesson JSON files and creating randomized test questions
- **Test Question**: A single assessment item derived from practiceQuestions or masteryQuestions in lesson JSON files
- **Test Session**: A single attempt at the Phase 1 Final Test consisting of 20 questions
- **Result Screen**: The UI component that displays the test score and completion status
- **Review Screen**: The UI component that shows incorrect answers with correct solutions
- **Local Storage Service**: The persistence layer that stores test results and completion status
- **Phase Unlock**: The mechanism that grants access to Phase 2 content after passing the final test
- **Passing Threshold**: The minimum score (80% or 16/20 questions) required to pass the test

## Requirements

### Requirement 1

**User Story:** As a student who has completed Lesson 6, I want to access a comprehensive final test, so that I can demonstrate my mastery of all Phase 1 content

#### Acceptance Criteria

1. WHEN THE Student completes Lesson 6, THE Final Test System SHALL display a navigation option to access the Phase 1 Final Test
2. WHEN THE Student navigates to the final test route, THE Final Test System SHALL display a screen with title "Phase 1 – Final Test" and subtitle "Covering Lessons 1 to 6"
3. THE Final Test System SHALL provide a back navigation button to return to the previous screen
4. WHEN THE Student has not yet started the test, THE Final Test System SHALL display a start button to begin the test session

### Requirement 2

**User Story:** As a student taking the final test, I want questions to be randomly selected from all six lessons, so that each test attempt feels unique and comprehensive

#### Acceptance Criteria

1. WHEN THE Test Generator Service creates a test, THE Test Generator Service SHALL load all six Phase 1 lesson JSON files from the assets directory
2. WHEN THE Test Generator Service processes lesson data, THE Test Generator Service SHALL extract questions from both practiceQuestions and masteryQuestions arrays
3. THE Test Generator Service SHALL select exactly 4 questions from Lesson 1 (Pronouns)
4. THE Test Generator Service SHALL select exactly 4 questions from Lesson 2 (Be Verb)
5. THE Test Generator Service SHALL select exactly 4 questions from Lesson 3 (Nouns & Articles)
6. THE Test Generator Service SHALL select exactly 3 questions from Lesson 4 (Object Pronouns)
7. THE Test Generator Service SHALL select exactly 3 questions from Lesson 5 (Action Verbs)
8. THE Test Generator Service SHALL select exactly 2 questions from Lesson 6 (Simple Present)
9. WHEN THE Test Generator Service completes question selection, THE Test Generator Service SHALL shuffle the final list of 20 questions to randomize order
10. WHEN THE Test Generator Service encounters insufficient questions in a lesson, THE Test Generator Service SHALL log an error and use all available questions

### Requirement 3

**User Story:** As a student taking the test, I want to answer multiple-choice questions one at a time, so that I can focus on each question without distraction

#### Acceptance Criteria

1. THE Final Test System SHALL display one question at a time with its four answer options
2. THE Final Test System SHALL display a progress indicator showing "Question X/20" where X is the current question number
3. THE Final Test System SHALL display a visual progress bar showing percentage completion (current question / 20 * 100)
4. THE Final Test System SHALL render the question text in English from the promptEn field
5. THE Final Test System SHALL display four radio button options corresponding to the question's options array
6. WHEN THE Student has not selected an option, THE Final Test System SHALL disable the Next button
7. WHEN THE Student selects an option, THE Final Test System SHALL enable the Next button
8. WHEN THE Student clicks the Next button, THE Final Test System SHALL record the selected answer and advance to the next question
9. WHEN THE Student is on the last question and clicks Next, THE Final Test System SHALL complete the test and navigate to the Result Screen

### Requirement 4

**User Story:** As a student who completed the test, I want to see my score and performance feedback, so that I understand how well I mastered Phase 1 content

#### Acceptance Criteria

1. WHEN THE Test Session completes, THE Result Screen SHALL display the title "Phase 1 Final Test – Completed!"
2. THE Result Screen SHALL display the student's score in the format "Score: X / 20" where X is the number of correct answers
3. THE Result Screen SHALL calculate and display accuracy as a percentage in the format "Accuracy: Y%" where Y = (correct answers / 20) * 100
4. WHEN THE Student scores 16 or more correct answers, THE Result Screen SHALL display a success message "You have mastered the entire Phase 1 foundation"
5. WHEN THE Student scores less than 16 correct answers, THE Result Screen SHALL display a message "Keep practicing to master Phase 1 content"
6. THE Result Screen SHALL provide a "Review Mistakes" button to view incorrect answers
7. WHEN THE Student scores 16 or more correct answers, THE Result Screen SHALL provide a "Continue to Phase 2" button
8. WHEN THE Student scores less than 16 correct answers, THE Result Screen SHALL provide a "Retry Test" button

### Requirement 5

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

### Requirement 6

**User Story:** As a student who passed the final test, I want my achievement to be saved and Phase 2 to be unlocked, so that I can continue my learning journey

#### Acceptance Criteria

1. WHEN THE Student scores 16 or more correct answers, THE Local Storage Service SHALL save phase1FinalTestPassed with value true
2. WHEN THE Student scores 16 or more correct answers, THE Local Storage Service SHALL save phase1FinalTestScore with the numeric score value
3. WHEN THE Student scores 16 or more correct answers, THE Local Storage Service SHALL save phase1FinalTestDate with the current timestamp
4. WHEN THE Student scores less than 16 correct answers, THE Local Storage Service SHALL save phase1FinalTestPassed with value false
5. WHEN THE Student scores less than 16 correct answers, THE Local Storage Service SHALL save the score and date but not unlock Phase 2
6. THE Local Storage Service SHALL persist test results across app sessions
7. WHEN THE Student retakes the test, THE Local Storage Service SHALL update the stored values with the most recent test results
8. THE Final Test System SHALL read phase1FinalTestPassed value to determine Phase 2 accessibility

### Requirement 7

**User Story:** As a student navigating the app, I want the final test to be accessible through proper routing, so that I can easily find and access the test

#### Acceptance Criteria

1. THE Final Test System SHALL register the route "/phase1/finalTest" in the app router
2. WHEN THE Student navigates to "/phase1/finalTest", THE Final Test System SHALL display the Phase 1 Final Test screen
3. THE Final Test System SHALL support deep linking to the final test route
4. WHEN THE Student has not completed Lesson 6, THE Final Test System SHALL display a message indicating the test is locked
5. THE Final Test System SHALL provide navigation from the Phase 1 Unit Screen to the final test

### Requirement 8

**User Story:** As a student taking the test, I want the interface to be clean and student-friendly, so that I can focus on answering questions without confusion

#### Acceptance Criteria

1. THE Final Test System SHALL use consistent typography and spacing matching the existing app theme
2. THE Final Test System SHALL display questions with sufficient font size for readability (minimum 16sp)
3. THE Final Test System SHALL provide adequate touch targets for radio buttons (minimum 48x48 logical pixels)
4. THE Final Test System SHALL use color coding to indicate selected options
5. THE Final Test System SHALL display the progress bar with a visually distinct color
6. THE Final Test System SHALL maintain consistent padding and margins throughout the test interface
7. THE Final Test System SHALL use the app's primary color scheme for buttons and interactive elements
8. THE Final Test System SHALL ensure text contrast meets accessibility standards (minimum 4.5:1 ratio)
