# Requirements Document

## Introduction

This document specifies the requirements for Phase 1 of Engliya, an English learning mobile application designed for Tamil-speaking beginners. The application focuses on mastery-based learning with a structured progression through fundamental English concepts. Phase 1 operates entirely offline using local data and assets, with no backend integration.

## Glossary

- **Engliya_App**: The Flutter-based mobile application for English learning
- **Learner**: A Tamil-speaking user who wants to learn basic English communication
- **Lesson**: A structured learning unit covering a specific English language topic
- **Mastery_Test**: An assessment that determines if a Learner has mastered a Lesson
- **Tab**: A section within a Lesson (Explain, Examples, Listen, Speak, Practice, Mastery)
- **Progress_Store**: Local storage mechanism for tracking Learner progress
- **Phase1_Unit**: Collection of 6 sequential Lessons covering basic English fundamentals
- **TTS**: Text-to-speech functionality for audio playback
- **Mock_Score**: Simulated score for speaking exercises until real STT integration

## Requirements

### Requirement 1: Onboarding and Level Selection

**User Story:** As a Learner, I want to select my learning level when I first open the app, so that I can start learning at an appropriate difficulty.

#### Acceptance Criteria

1. WHEN the Engliya_App launches for the first time, THE Engliya_App SHALL display an onboarding screen with level selection options
2. THE Engliya_App SHALL provide at least one selectable level option labeled "Beginner" or "School Student"
3. WHEN a Learner selects a level and confirms, THE Engliya_App SHALL store the selection in Progress_Store
4. WHEN a Learner completes onboarding, THE Engliya_App SHALL navigate to the home screen
5. WHEN the Engliya_App launches after initial onboarding, THE Engliya_App SHALL skip the onboarding screen and display the home screen directly

### Requirement 2: Home Screen Navigation

**User Story:** As a Learner, I want to see my learning progress and access lessons from the home screen, so that I can continue my learning journey.

#### Acceptance Criteria

1. THE Engliya_App SHALL display a home screen containing the app title, a "Start Learning" button, and progress summary
2. WHEN a Learner has previously accessed a Lesson, THE Engliya_App SHALL display a "Continue where you left off" section showing the last accessed Lesson
3. THE Engliya_App SHALL display the count of mastered Lessons in the format "Lessons mastered: X / 6"
4. WHEN a Learner taps "Start Learning", THE Engliya_App SHALL navigate to the Phase1_Unit overview screen
5. WHEN a Learner taps the last accessed Lesson card, THE Engliya_App SHALL navigate directly to that Lesson

### Requirement 3: Phase 1 Unit Overview

**User Story:** As a Learner, I want to view all available lessons in Phase 1 with their status, so that I can understand my learning path and select the next lesson.

#### Acceptance Criteria

1. THE Engliya_App SHALL display a list of 6 Lessons in sequential order on the Phase1_Unit screen
2. THE Engliya_App SHALL display each Lesson with title, short description, and status indicator
3. THE Engliya_App SHALL mark each Lesson status as one of: Locked, In Progress, or Mastered
4. THE Engliya_App SHALL display a progress indicator for each Lesson showing completion percentage or icon
5. WHEN a Learner taps an unlocked Lesson, THE Engliya_App SHALL navigate to the Lesson screen
6. WHEN a Learner taps a locked Lesson, THE Engliya_App SHALL display a message "Please master the previous lesson first"

### Requirement 4: Lesson Unlocking Logic

**User Story:** As a Learner, I want lessons to unlock sequentially as I master them, so that I learn concepts in the correct order.

#### Acceptance Criteria

1. THE Engliya_App SHALL unlock the first Lesson in Phase1_Unit by default
2. WHEN a Learner achieves mastery on a Lesson, THE Engliya_App SHALL unlock the next sequential Lesson
3. THE Engliya_App SHALL keep all Lessons after an unmastered Lesson in locked state
4. THE Engliya_App SHALL persist unlock status in Progress_Store across app sessions
5. WHEN a Learner reopens the Engliya_App, THE Engliya_App SHALL restore the unlock status from Progress_Store

### Requirement 5: Lesson Screen Structure

**User Story:** As a Learner, I want to navigate through different learning activities within a lesson, so that I can learn through multiple modalities.

#### Acceptance Criteria

1. THE Engliya_App SHALL display a Lesson screen with a tab bar containing 6 tabs: Explain, Examples, Listen, Speak, Practice, Mastery
2. THE Engliya_App SHALL display the Lesson title and back button in the app bar
3. THE Engliya_App SHALL display a progress indicator showing completed tabs out of total tabs
4. THE Engliya_App SHALL display a bottom navigation bar with "Previous Step" and "Next Step" buttons
5. WHEN a Learner taps "Next Step", THE Engliya_App SHALL navigate to the next tab in sequence
6. WHEN a Learner taps "Previous Step", THE Engliya_App SHALL navigate to the previous tab in sequence
7. WHEN a Learner is on the first tab, THE Engliya_App SHALL disable the "Previous Step" button
8. WHEN a Learner is on the last tab, THE Engliya_App SHALL disable the "Next Step" button

### Requirement 6: Explain Tab Content

**User Story:** As a Learner, I want to read explanations in both Tamil and English, so that I can understand new concepts clearly.

#### Acceptance Criteria

1. THE Engliya_App SHALL display Tamil explanation text for the Lesson topic in the Explain tab
2. THE Engliya_App SHALL display English explanation text for the Lesson topic in the Explain tab
3. WHERE the Lesson includes tabular data, THE Engliya_App SHALL display a formatted table with English and Tamil descriptions
4. THE Engliya_App SHALL provide a scrollable view for explanation content
5. WHEN a Learner scrolls to the bottom of the explanation, THE Engliya_App SHALL mark the Explain tab as completed

### Requirement 7: Examples Tab Content

**User Story:** As a Learner, I want to see example sentences with translations and hear them spoken, so that I can understand usage in context.

#### Acceptance Criteria

1. THE Engliya_App SHALL display between 6 and 10 example sentences in the Examples tab
2. THE Engliya_App SHALL display each example sentence with English text and Tamil translation
3. THE Engliya_App SHALL provide an audio play icon for each example sentence
4. WHEN a Learner taps the audio play icon, THE Engliya_App SHALL play the sentence using TTS
5. WHEN a Learner has played audio for at least 3 example sentences, THE Engliya_App SHALL mark the Examples tab as completed

### Requirement 8: Listen Tab Content

**User Story:** As a Learner, I want to practice listening comprehension with multiple choice questions, so that I can improve my listening skills.

#### Acceptance Criteria

1. THE Engliya_App SHALL display between 3 and 5 listening questions in the Listen tab
2. THE Engliya_App SHALL provide an audio play button for each listening question
3. WHEN a Learner taps the play button, THE Engliya_App SHALL play the audio using TTS
4. THE Engliya_App SHALL display 3 answer options for each listening question
5. WHEN a Learner selects an answer, THE Engliya_App SHALL indicate whether the answer is correct or incorrect
6. WHEN a Learner completes at least 3 listening questions with 70 percent or higher accuracy, THE Engliya_App SHALL mark the Listen tab as completed

### Requirement 9: Speak Tab Content

**User Story:** As a Learner, I want to practice speaking English sentences, so that I can improve my pronunciation and speaking confidence.

#### Acceptance Criteria

1. THE Engliya_App SHALL display between 3 and 5 target sentences for speaking practice in the Speak tab
2. THE Engliya_App SHALL display a microphone button for each speaking exercise
3. WHEN a Learner taps the microphone button, THE Engliya_App SHALL generate a Mock_Score between 70 and 100 percent
4. THE Engliya_App SHALL display the Mock_Score as a percentage after each speaking attempt
5. THE Engliya_App SHALL display placeholder text "You said: ..." for future STT integration
6. WHEN a Learner completes at least 3 speaking exercises with average Mock_Score of 70 percent or higher, THE Engliya_App SHALL mark the Speak tab as completed

### Requirement 10: Practice Tab Content

**User Story:** As a Learner, I want to complete practice quizzes to test my understanding, so that I can identify areas needing improvement.

#### Acceptance Criteria

1. THE Engliya_App SHALL display between 5 and 10 multiple choice questions in the Practice tab
2. THE Engliya_App SHALL display each question with English prompt and Tamil translation
3. THE Engliya_App SHALL provide between 2 and 4 answer options for each question
4. WHEN a Learner selects an answer, THE Engliya_App SHALL indicate whether the answer is correct or incorrect
5. WHEN a Learner completes all practice questions, THE Engliya_App SHALL calculate and display the total score as a percentage
6. WHEN a Learner achieves 60 percent or higher on the practice quiz, THE Engliya_App SHALL mark the Practice tab as completed
7. THE Engliya_App SHALL store the best practice quiz score in Progress_Store

### Requirement 11: Mastery Tab and Testing

**User Story:** As a Learner, I want to take a mastery test to prove I have learned the lesson content, so that I can unlock the next lesson.

#### Acceptance Criteria

1. THE Engliya_App SHALL display a summary view in the Mastery tab showing previous quiz scores and listening results
2. THE Engliya_App SHALL provide a "Start Mastery Test" button in the Mastery tab
3. WHEN a Learner taps "Start Mastery Test", THE Engliya_App SHALL present between 8 and 10 mixed questions
4. THE Engliya_App SHALL include questions from both Practice and Listen question pools in the Mastery_Test
5. WHEN a Learner completes the Mastery_Test, THE Engliya_App SHALL calculate and display the final score as a percentage
6. WHEN a Learner achieves 80 percent or higher on the Mastery_Test, THE Engliya_App SHALL mark the Lesson as mastered
7. WHEN a Lesson is marked as mastered, THE Engliya_App SHALL unlock the next sequential Lesson
8. THE Engliya_App SHALL store the best mastery score in Progress_Store

### Requirement 12: Local Data Storage

**User Story:** As a Learner, I want my progress to be saved automatically, so that I can continue learning from where I left off.

#### Acceptance Criteria

1. THE Engliya_App SHALL store all Learner progress data in Progress_Store using local storage
2. THE Engliya_App SHALL persist the following data for each Lesson: explainDone, examplesDone, listeningScore, speakingScore, quizBestScore, masteryBestScore, isMastered
3. WHEN the Engliya_App closes, THE Engliya_App SHALL save all progress data to Progress_Store
4. WHEN the Engliya_App launches, THE Engliya_App SHALL load all progress data from Progress_Store
5. THE Engliya_App SHALL maintain progress data across app restarts without data loss

### Requirement 13: Lesson Content Loading

**User Story:** As a Learner, I want lesson content to load quickly from local storage, so that I can learn without internet connectivity.

#### Acceptance Criteria

1. THE Engliya_App SHALL load all Lesson content from local JSON files in the assets directory
2. THE Engliya_App SHALL store Lesson JSON files in the path "assets/lessons/phase1/"
3. WHEN the Engliya_App needs Lesson content, THE Engliya_App SHALL parse the corresponding JSON file
4. THE Engliya_App SHALL operate without requiring network connectivity
5. THE Engliya_App SHALL load Lesson content within 2 seconds on standard mobile devices

### Requirement 14: Phase 1 Lesson Content

**User Story:** As a Learner, I want to learn fundamental English concepts through 6 structured lessons, so that I can build a strong foundation.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide 6 Lessons in Phase1_Unit covering: Subject Pronouns, Be Verb, Basic Nouns and Articles, Object Pronouns, Basic Action Verbs, and Simple Present Sentences
2. THE Engliya_App SHALL provide complete content for Lesson 1 covering subject pronouns: I, You, He, She, It, We, They
3. THE Engliya_App SHALL provide complete content for Lesson 2 covering be verb forms: am, is, are
4. THE Engliya_App SHALL provide placeholder content for Lessons 3 through 6 following the same structure as Lessons 1 and 2
5. THE Engliya_App SHALL include Tamil translations for all explanations and example sentences
6. THE Engliya_App SHALL structure each Lesson with all 6 tabs: Explain, Examples, Listen, Speak, Practice, Mastery

### Requirement 15: User Interface Design

**User Story:** As a Learner, I want a clean and friendly interface with clear navigation, so that I can focus on learning without confusion.

#### Acceptance Criteria

1. THE Engliya_App SHALL use large, readable fonts suitable for school-age students
2. THE Engliya_App SHALL use clear, recognizable icons for audio playback, microphone, and answer feedback
3. THE Engliya_App SHALL use a volume icon for audio playback controls
4. THE Engliya_App SHALL use a microphone icon for speaking exercises
5. THE Engliya_App SHALL use check and cross icons to indicate correct and incorrect answers
6. THE Engliya_App SHALL use consistent color scheme and spacing throughout the application
7. THE Engliya_App SHALL provide visual feedback for all interactive elements within 200 milliseconds
