# Requirements Document

## Introduction

The Phase 4 Final Test is a hybrid listening, speaking, and comprehension assessment that evaluates learners' pronunciation awareness, fluency, listening comprehension, dialogue response skills, and functional conversation ability. This test serves as the gateway to unlocking Phase 5 – Professional English. The test consists of 20 questions across 4 sections with a maximum score of 24 points, requiring 75% (18 points) to pass.

## Glossary

- **Phase 4 Final Test**: A comprehensive assessment covering pronunciation, fluency, listening, and speaking skills
- **Pronunciation MCQ**: Multiple-choice question testing syllable stress, rhythm, and natural sound patterns
- **Dialogue Response MCQ**: Multiple-choice question testing ability to choose the best reply in conversations
- **Listening Comprehension**: Questions based on audio or displayed dialogue content
- **Speaking Task**: Prompted speaking exercise scored on fluency, clarity, and natural pauses
- **STT (Speech-to-Text)**: Device speech recognition service for capturing and analyzing user speech
- **Mock Scoring**: Fallback scoring mechanism when STT is unavailable
- **Passing Score**: Minimum 18 out of 24 points (75%) required to pass the test
- **Phase 5**: The next learning phase (Professional English) unlocked upon passing Phase 4 Final Test

## Requirements

### Requirement 1

**User Story:** As a learner who has mastered all Phase 4 lessons, I want to take the Phase 4 Final Test, so that I can demonstrate my fluency and pronunciation skills and unlock Phase 5.

#### Acceptance Criteria

1. WHEN a user has mastered all lessons in Units 18, 19, 20, and 21 THEN the System SHALL enable the Phase 4 Final Test button
2. WHEN a user attempts to access the Phase 4 Final Test without mastering all Phase 4 lessons THEN the System SHALL display "Please master all Phase 4 lessons before taking the Final Test"
3. WHEN debug mode is enabled THEN the System SHALL allow access to the Phase 4 Final Test regardless of lesson mastery status
4. WHEN a user starts the Phase 4 Final Test THEN the System SHALL present 20 questions in sequence


### Requirement 2

**User Story:** As a learner, I want the test to evaluate my pronunciation awareness, so that I can demonstrate understanding of English stress, rhythm, and natural sounds.

#### Acceptance Criteria

1. WHEN the test includes pronunciation MCQs THEN the System SHALL present 6 questions testing syllable stress, rhythm, and natural sound patterns
2. WHEN displaying a pronunciation MCQ THEN the System SHALL show a prompt asking which sentence sounds more natural or has correct stress
3. WHEN a user selects an answer for a pronunciation MCQ THEN the System SHALL award 1 point for a correct answer and 0 points for incorrect
4. WHEN generating pronunciation questions THEN the System SHALL extract questions from Phase 4 lesson practice and mastery content

### Requirement 3

**User Story:** As a learner, I want the test to evaluate my dialogue response skills, so that I can demonstrate ability to choose appropriate replies in conversations.

#### Acceptance Criteria

1. WHEN the test includes dialogue response MCQs THEN the System SHALL present 6 questions testing best reply selection in real-life conversations
2. WHEN displaying a dialogue response MCQ THEN the System SHALL show a conversation prompt (e.g., "Waiter: Would you like anything else?") with multiple response options
3. WHEN a user selects an answer for a dialogue MCQ THEN the System SHALL award 1 point for a correct answer and 0 points for incorrect
4. WHEN generating dialogue questions THEN the System SHALL extract questions from Unit 20 and Unit 21 lesson content

### Requirement 4

**User Story:** As a learner, I want the test to evaluate my listening comprehension, so that I can demonstrate understanding of spoken English conversations.

#### Acceptance Criteria

1. WHEN the test includes listening comprehension questions THEN the System SHALL present 4 questions based on short audio or displayed dialogue
2. WHEN displaying a listening question THEN the System SHALL show the dialogue text or play audio followed by a comprehension question
3. WHEN a user selects an answer for a listening MCQ THEN the System SHALL award 1 point for a correct answer and 0 points for incorrect
4. WHEN generating listening questions THEN the System SHALL use listening questions from Phase 4 lesson content

### Requirement 5

**User Story:** As a learner, I want the test to evaluate my speaking fluency, so that I can demonstrate ability to speak clearly and naturally.

#### Acceptance Criteria

1. WHEN the test includes speaking tasks THEN the System SHALL present 4 speaking prompts requiring 20-30 seconds of speech
2. WHEN displaying a speaking task THEN the System SHALL show a prompt (e.g., "Describe your last shopping experience in 3-4 sentences")
3. WHEN STT service is available THEN the System SHALL capture user speech and score based on word count, clarity, and sentence completeness
4. WHEN STT service is unavailable THEN the System SHALL use mock scoring with randomized variance (±1) for natural feel
5. WHEN scoring a speaking task THEN the System SHALL award 0-3 points: 3 for good fluency (20+ words, clear recognition), 2 for okay but short, 1 for very short (<10 words), 0 for no output


### Requirement 6

**User Story:** As a learner, I want to see my test results clearly, so that I can understand my performance and know if I passed.

#### Acceptance Criteria

1. WHEN a user completes the Phase 4 Final Test THEN the System SHALL display the result screen with total score out of 24 and percentage
2. WHEN a user scores 18 or more points (75%+) THEN the System SHALL display a congratulations message and indicate Phase 5 is unlocked
3. WHEN a user scores less than 18 points THEN the System SHALL display a "Not Passed" message with encouragement to review Phase 4 lessons
4. WHEN displaying results THEN the System SHALL provide options to "Review Mistakes" and either "Continue" (if passed) or "Retry" (if failed)

### Requirement 7

**User Story:** As a learner, I want to review my mistakes after the test, so that I can learn from incorrect answers.

#### Acceptance Criteria

1. WHEN a user taps "Review Mistakes" THEN the System SHALL navigate to the review screen showing only incorrectly answered MCQ questions
2. WHEN displaying a mistake THEN the System SHALL show the question, the correct answer, and the user's incorrect selection
3. WHEN reviewing mistakes THEN the System SHALL exclude speaking tasks from the review (only MCQs are reviewable)
4. WHEN a user finishes reviewing THEN the System SHALL provide navigation back to results or home screen

### Requirement 8

**User Story:** As a learner who passed the test, I want Phase 5 to be unlocked, so that I can continue my learning journey.

#### Acceptance Criteria

1. WHEN a user passes the Phase 4 Final Test THEN the System SHALL set phase4FinalTestPassed to true in storage
2. WHEN a user passes the Phase 4 Final Test THEN the System SHALL set phase5Unlocked to true in storage
3. WHEN a user passes the Phase 4 Final Test THEN the System SHALL persist the test score (phase4FinalTestScore) in storage
4. WHEN Phase 5 unlock status is checked THEN the System SHALL return true only if phase4FinalTestPassed is true

### Requirement 9

**User Story:** As a developer, I want the test to use a consistent question model structure, so that the code is maintainable and extensible.

#### Acceptance Criteria

1. WHEN creating pronunciation questions THEN the System SHALL use PronunciationQuestion model with prompt, options list, and correctIndex
2. WHEN creating dialogue questions THEN the System SHALL use DialogueQuestion model with prompt, options list, and correctIndex
3. WHEN creating listening questions THEN the System SHALL reuse existing MCQ structure with optional audioText or audioId fields
4. WHEN creating speaking tasks THEN the System SHALL use SpeakingTask model with prompt field

### Requirement 10

**User Story:** As a developer, I want the test service to build questions dynamically from lesson content, so that the test reflects actual learning material.

#### Acceptance Criteria

1. WHEN building the test THEN the System SHALL load Phase 4 lesson JSON files from assets/lessons/phase4/
2. WHEN selecting questions THEN the System SHALL randomly select 6 pronunciation, 6 dialogue, 4 listening, and 4 speaking questions from available content
3. WHEN questions are insufficient in lesson content THEN the System SHALL use fallback hardcoded questions to ensure 20 total questions
4. WHEN building the test THEN the System SHALL group questions by unit (18-21) for balanced coverage


### Requirement 11

**User Story:** As a developer, I want proper routing and navigation for the test screens, so that users can access the test seamlessly.

#### Acceptance Criteria

1. WHEN navigating to the Phase 4 Final Test THEN the System SHALL use route /phase4/finalTest
2. WHEN the test is completed THEN the System SHALL navigate to the result screen with test data
3. WHEN reviewing mistakes THEN the System SHALL navigate to the review screen with incorrect answers data
4. WHEN returning from test screens THEN the System SHALL navigate appropriately to home or Phase 4 unit screen

### Requirement 12

**User Story:** As a learner, I want a clear and intuitive test UI, so that I can focus on answering questions without confusion.

#### Acceptance Criteria

1. WHEN displaying the test screen THEN the System SHALL show the current question number out of 20 and a progress bar
2. WHEN displaying an MCQ question THEN the System SHALL show the prompt and selectable options with clear visual feedback on selection
3. WHEN displaying a speaking task THEN the System SHALL show the prompt, a microphone button to start/stop recording, and recording status
4. WHEN navigating between questions THEN the System SHALL provide Next and Skip buttons with appropriate enabled/disabled states

