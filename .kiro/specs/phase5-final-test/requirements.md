# Requirements Document

## Introduction

The Phase 5 Final Test is the ultimate certification assessment that evaluates learners' professional English mastery. This test covers business communication, interview English, presentation skills, and advanced writing. It consists of 35 tasks across 5 sections with a maximum score of 60 points, requiring 75% (45 points) to pass. Passing this test marks the completion of the entire English Communication Mastery Program and sets the `englishMasteryCompleted` flag to true.

## Glossary

- **Phase 5 Final Test**: The ultimate certification assessment covering professional English skills
- **Business English MCQ**: Multiple-choice question testing professional grammar, tone, and workplace communication
- **Interview Response MCQ**: Multiple-choice question testing ability to select the best interview answers
- **Presentation Language MCQ**: Multiple-choice question testing presentation structure and professional language
- **Writing Logic MCQ**: Multiple-choice question testing advanced writing structure and opinion expression
- **Speaking Task (Professional)**: Prompted speaking exercise requiring professional-level responses (30-60 seconds)
- **STT (Speech-to-Text)**: Device speech recognition service for capturing and analyzing user speech
- **Mock Scoring**: Fallback scoring mechanism when STT is unavailable
- **Passing Score**: Minimum 45 out of 60 points (75%) required to pass the test
- **English Mastery Completed**: Flag indicating the learner has completed the entire English Communication Mastery Program
- **Phase 5**: Professional English phase covering Units 22-25 (Business, Interview, Presentation, Advanced Writing)

## Requirements

### Requirement 1

**User Story:** As a learner who has mastered all Phase 5 lessons, I want to take the Phase 5 Final Test, so that I can demonstrate my professional English mastery and earn certification.

#### Acceptance Criteria

1. WHEN a user has mastered all lessons in Units 22, 23, 24, and 25 THEN the System SHALL enable the Phase 5 Final Test button
2. WHEN a user attempts to access the Phase 5 Final Test without mastering all Phase 5 lessons THEN the System SHALL display "Please master all Phase 5 lessons before taking the Final Test"
3. WHEN debug mode is enabled THEN the System SHALL allow access to the Phase 5 Final Test regardless of lesson mastery status
4. WHEN a user starts the Phase 5 Final Test THEN the System SHALL present 35 tasks in sequence

### Requirement 2

**User Story:** As a learner, I want the test to evaluate my business English skills, so that I can demonstrate understanding of professional grammar and workplace communication.

#### Acceptance Criteria

1. WHEN the test includes Business English MCQs THEN the System SHALL present 8 questions testing professional tone, grammar, and workplace communication
2. WHEN displaying a Business English MCQ THEN the System SHALL show a prompt asking which sentence is most professional or appropriate for workplace communication
3. WHEN a user selects an answer for a Business English MCQ THEN the System SHALL award 1 point for a correct answer and 0 points for incorrect
4. WHEN generating Business English questions THEN the System SHALL extract questions from Unit 22 lesson practice and mastery content

### Requirement 3

**User Story:** As a learner, I want the test to evaluate my interview response skills, so that I can demonstrate ability to answer interview questions professionally.

#### Acceptance Criteria

1. WHEN the test includes Interview Response MCQs THEN the System SHALL present 7 questions testing best interview answer selection
2. WHEN displaying an Interview Response MCQ THEN the System SHALL show an interviewer question with multiple response options
3. WHEN a user selects an answer for an Interview MCQ THEN the System SHALL award 1 point for a correct answer and 0 points for incorrect
4. WHEN generating Interview questions THEN the System SHALL extract questions from Unit 23 lesson content

### Requirement 4

**User Story:** As a learner, I want the test to evaluate my presentation language skills, so that I can demonstrate understanding of professional presentation structure.

#### Acceptance Criteria

1. WHEN the test includes Presentation Language MCQs THEN the System SHALL present 6 questions testing presentation openings, transitions, and conclusions
2. WHEN displaying a Presentation Language MCQ THEN the System SHALL show a prompt asking for the best presentation phrase or structure
3. WHEN a user selects an answer for a Presentation MCQ THEN the System SHALL award 1 point for a correct answer and 0 points for incorrect
4. WHEN generating Presentation questions THEN the System SHALL extract questions from Unit 24 lesson content

### Requirement 5

**User Story:** As a learner, I want the test to evaluate my advanced writing skills, so that I can demonstrate understanding of professional writing structure and opinion expression.

#### Acceptance Criteria

1. WHEN the test includes Writing Logic MCQs THEN the System SHALL present 6 questions testing writing structure, conclusions, and opinion expression
2. WHEN displaying a Writing Logic MCQ THEN the System SHALL show a prompt asking for the best writing structure or concluding sentence
3. WHEN a user selects an answer for a Writing MCQ THEN the System SHALL award 1 point for a correct answer and 0 points for incorrect
4. WHEN generating Writing questions THEN the System SHALL extract questions from Unit 25 lesson content

### Requirement 6

**User Story:** As a learner, I want the test to evaluate my professional speaking ability, so that I can demonstrate confidence in professional verbal communication.

#### Acceptance Criteria

1. WHEN the test includes Professional Speaking Tasks THEN the System SHALL present 8 speaking prompts requiring 30-60 seconds of professional speech
2. WHEN displaying a Speaking Task THEN the System SHALL show a professional prompt (e.g., "Introduce yourself as a software developer in 30 seconds")
3. WHEN STT service is available THEN the System SHALL capture user speech and score based on word count, sentence structure, clarity, and minimal repetition
4. WHEN STT service is unavailable THEN the System SHALL use mock scoring with randomized variance (±1) for natural feel
5. WHEN scoring a Speaking Task THEN the System SHALL award 0-4 points: 4 for clear, confident, structured (40-80 words), 3 for good but slightly short, 2 for basic lacks structure, 1 for very weak, 0 for no response

### Requirement 7

**User Story:** As a learner, I want to see my test results clearly, so that I can understand my performance and know if I achieved certification.

#### Acceptance Criteria

1. WHEN a user completes the Phase 5 Final Test THEN the System SHALL display the result screen with total score out of 60 and percentage
2. WHEN a user scores 45 or more points (75%+) THEN the System SHALL display a congratulations message indicating English Mastery Certification achieved
3. WHEN a user scores less than 45 points THEN the System SHALL display a "Not Passed" message with encouragement to review Phase 5 lessons
4. WHEN displaying results THEN the System SHALL provide options to "Review Mistakes" and either "View Certificate" (if passed) or "Retry" (if failed)

### Requirement 8

**User Story:** As a learner, I want to review my mistakes after the test, so that I can learn from incorrect answers.

#### Acceptance Criteria

1. WHEN a user taps "Review Mistakes" THEN the System SHALL navigate to the review screen showing only incorrectly answered MCQ questions
2. WHEN displaying a mistake THEN the System SHALL show the question, the correct answer, and the user's incorrect selection
3. WHEN reviewing mistakes THEN the System SHALL exclude speaking tasks from the review (only MCQs are reviewable)
4. WHEN a user finishes reviewing THEN the System SHALL provide navigation back to results or home screen

### Requirement 9

**User Story:** As a learner who passed the test, I want my English Mastery to be recorded, so that my achievement is permanently saved.

#### Acceptance Criteria

1. WHEN a user passes the Phase 5 Final Test THEN the System SHALL set phase5FinalTestPassed to true in storage
2. WHEN a user passes the Phase 5 Final Test THEN the System SHALL set englishMasteryCompleted to true in storage
3. WHEN a user passes the Phase 5 Final Test THEN the System SHALL persist the test score (phase5FinalTestScore) in storage
4. WHEN a user passes the Phase 5 Final Test THEN the System SHALL persist the test date (phase5FinalTestDate) in storage

### Requirement 10

**User Story:** As a developer, I want the test to use a consistent question model structure, so that the code is maintainable and extensible.

#### Acceptance Criteria

1. WHEN creating Business English questions THEN the System SHALL use Phase5FinalTestQuestion model with type businessEnglish, prompt, options list, and correctIndex
2. WHEN creating Interview questions THEN the System SHALL use Phase5FinalTestQuestion model with type interview, prompt, options list, and correctIndex
3. WHEN creating Presentation questions THEN the System SHALL use Phase5FinalTestQuestion model with type presentation, prompt, options list, and correctIndex
4. WHEN creating Writing questions THEN the System SHALL use Phase5FinalTestQuestion model with type writing, prompt, options list, and correctIndex
5. WHEN creating Speaking Tasks THEN the System SHALL use Phase5SpeakingTask model with prompt field

### Requirement 11

**User Story:** As a developer, I want the test service to build questions dynamically from lesson content, so that the test reflects actual learning material.

#### Acceptance Criteria

1. WHEN building the test THEN the System SHALL load Phase 5 lesson JSON files from assets/lessons/phase5/
2. WHEN selecting questions THEN the System SHALL randomly select 8 business, 7 interview, 6 presentation, 6 writing, and 8 speaking questions from available content
3. WHEN questions are insufficient in lesson content THEN the System SHALL use fallback hardcoded questions to ensure 35 total tasks
4. WHEN building the test THEN the System SHALL group questions by unit (22-25) for balanced coverage

### Requirement 12

**User Story:** As a developer, I want proper routing and navigation for the test screens, so that users can access the test seamlessly.

#### Acceptance Criteria

1. WHEN navigating to the Phase 5 Final Test THEN the System SHALL use route /phase5/finalTest
2. WHEN the test is completed THEN the System SHALL navigate to the result screen with test data
3. WHEN reviewing mistakes THEN the System SHALL navigate to the review screen with incorrect answers data
4. WHEN returning from test screens THEN the System SHALL navigate appropriately to home or Phase 5 unit screen

### Requirement 13

**User Story:** As a learner, I want a clear and intuitive test UI, so that I can focus on answering questions without confusion.

#### Acceptance Criteria

1. WHEN displaying the test screen THEN the System SHALL show the current question number out of 35 and a progress bar
2. WHEN displaying an MCQ question THEN the System SHALL show the prompt and selectable options with clear visual feedback on selection
3. WHEN displaying a Speaking Task THEN the System SHALL show the prompt, a microphone button to start/stop recording, and recording status
4. WHEN navigating between questions THEN the System SHALL provide Next and Skip buttons with appropriate enabled/disabled states
