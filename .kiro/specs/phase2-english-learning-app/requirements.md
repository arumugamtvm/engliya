# Requirements Document

## Introduction

This document specifies the requirements for Phase 2 of Engliya, an English learning mobile application for Tamil-speaking learners. Phase 2 builds upon Phase 1's foundation by introducing intermediate grammar concepts including continuous tenses, perfect tenses, time and place language, questions, negatives, and advanced pronouns/adjectives/adverbs. Phase 2 maintains the offline-first architecture and mastery-based progression model established in Phase 1, while expanding the content from 6 lessons to 25 lessons across 5 new units (Units 7-11).

## Glossary

- **Engliya_App**: The Flutter-based mobile application for English learning
- **Learner**: A Tamil-speaking user who wants to learn English communication
- **Phase1**: The first learning phase covering basic English fundamentals (6 lessons)
- **Phase2**: The second learning phase covering intermediate grammar and conversation (25 lessons across 5 units)
- **Unit**: A collection of related lessons covering a specific grammar topic area
- **Lesson**: A structured learning unit covering a specific English language topic
- **LessonScreen**: The generic screen displaying lesson content across 6 tabs
- **Tab**: A section within a Lesson (Explain, Examples, Listen, Speak, Practice, Mastery)
- **Mastery_Test**: An assessment that determines if a Learner has mastered a Lesson
- **Progress_Store**: Local storage mechanism for tracking Learner progress
- **Phase1_Final_Test**: The comprehensive test that must be passed to unlock Phase2
- **Phase2_Unit**: One of five units (Unit 7-11) in Phase2
- **JSON_Asset**: Local JSON file containing lesson content and questions
- **TTS**: Text-to-speech functionality for audio playback
- **Mock_Score**: Simulated score for speaking exercises until real STT integration

## Requirements

### Requirement 1: Phase 2 Access Control

**User Story:** As a Learner, I want Phase 2 to be locked until I complete Phase 1 Final Test, so that I learn concepts in the correct progression.

#### Acceptance Criteria

1. THE Engliya_App SHALL lock Phase2 access until phase1FinalTestPassed equals true in Progress_Store
2. WHEN a Learner taps the Phase2 entry point while Phase2 is locked, THE Engliya_App SHALL display a dialog message "Please complete Phase 1 Final Test before starting Phase 2"
3. WHEN phase1FinalTestPassed equals true, THE Engliya_App SHALL unlock Phase2 access
4. THE Engliya_App SHALL persist Phase2 unlock status across app sessions
5. WHEN Phase2 is unlocked, THE Engliya_App SHALL display the Phase2 entry point as accessible with visual indication

### Requirement 2: Phase 2 Navigation Entry Point

**User Story:** As a Learner, I want to access Phase 2 from the home screen, so that I can continue my learning journey after completing Phase 1.

#### Acceptance Criteria

1. THE Engliya_App SHALL display a Phase2 tile on the home screen
2. THE Engliya_App SHALL display the Phase2 tile with title "Phase 2", description, and lock status indicator
3. WHEN a Learner taps the unlocked Phase2 tile, THE Engliya_App SHALL navigate to Phase2UnitScreen
4. THE Engliya_App SHALL display Phase2 progress summary showing mastered lessons count in format "X / 25 lessons mastered"
5. WHEN Phase2 is locked, THE Engliya_App SHALL display a lock icon on the Phase2 tile

### Requirement 3: Phase 2 Unit Screen

**User Story:** As a Learner, I want to view all Phase 2 units with their lesson counts and progress, so that I can select which unit to study.

#### Acceptance Criteria

1. THE Engliya_App SHALL display Phase2UnitScreen containing 5 units: Unit 7, Unit 8, Unit 9, Unit 10, and Unit 11
2. THE Engliya_App SHALL display each unit tile with unit number, title, short description, and mastery progress indicator
3. THE Engliya_App SHALL display mastery progress for each unit in format "X / Y lessons mastered"
4. WHEN a Learner taps a unit tile, THE Engliya_App SHALL navigate to Phase2LessonListScreen for that unit
5. THE Engliya_App SHALL display Unit 7 as "Time & Place Language" with 3 lessons
6. THE Engliya_App SHALL display Unit 8 as "Continuous Tenses" with 4 lessons
7. THE Engliya_App SHALL display Unit 9 as "Perfect & Perfect Continuous" with 5 lessons
8. THE Engliya_App SHALL display Unit 10 as "Questions & Negatives" with 5 lessons
9. THE Engliya_App SHALL display Unit 11 as "Advanced Pronouns, Adjectives & Adverbs" with 5 lessons

### Requirement 4: Phase 2 Lesson List Screen

**User Story:** As a Learner, I want to view all lessons within a Phase 2 unit with their lock status, so that I can select the next available lesson.

#### Acceptance Criteria

1. THE Engliya_App SHALL display Phase2LessonListScreen showing all lessons for the selected unit
2. THE Engliya_App SHALL display each lesson with lesson number, title, description, and status indicator
3. THE Engliya_App SHALL mark each lesson status as one of: Locked, In Progress, or Mastered
4. THE Engliya_App SHALL unlock the first lesson of Unit 7 by default when Phase2 is unlocked
5. WHEN a Learner taps an unlocked lesson, THE Engliya_App SHALL navigate to LessonScreen with that lesson data
6. WHEN a Learner taps a locked lesson, THE Engliya_App SHALL display a message indicating the previous lesson must be mastered first

### Requirement 5: Phase 2 Lesson Unlocking Logic

**User Story:** As a Learner, I want Phase 2 lessons to unlock sequentially as I master them, so that I learn concepts in the correct order.

#### Acceptance Criteria

1. THE Engliya_App SHALL unlock Lesson 7.1 by default when Phase2 is unlocked
2. WHEN a Learner achieves masteryBestScore greater than or equal to 0.8 on a lesson, THE Engliya_App SHALL mark that lesson as mastered
3. WHEN a lesson is marked as mastered, THE Engliya_App SHALL unlock the next sequential lesson within the same unit
4. WHEN the last lesson of a unit is mastered, THE Engliya_App SHALL unlock the first lesson of the next unit
5. THE Engliya_App SHALL persist lesson unlock status in Progress_Store across app sessions

### Requirement 6: Phase 2 Lesson Content Structure

**User Story:** As a Learner, I want Phase 2 lessons to use the same familiar structure as Phase 1, so that I can focus on learning new content without learning a new interface.

#### Acceptance Criteria

1. THE Engliya_App SHALL display Phase2 lessons using the existing LessonScreen component
2. THE Engliya_App SHALL display 6 tabs for each Phase2 lesson: Explain, Examples, Listen, Speak, Practice, Mastery
3. THE Engliya_App SHALL load Phase2 lesson content from JSON_Asset files in assets/lessons/phase2/ directory
4. THE Engliya_App SHALL parse Phase2 JSON files using the same schema as Phase1 lessons
5. THE Engliya_App SHALL apply the same tab completion rules to Phase2 lessons as Phase1 lessons

### Requirement 7: Unit 7 Lesson Content - Time & Place Language

**User Story:** As a Learner, I want to learn time and place prepositions and expressions, so that I can describe when and where actions occur.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide Lesson 7.1 covering time prepositions: on, in, at, since, for, ago, before, by
2. THE Engliya_App SHALL provide Lesson 7.2 covering place and movement prepositions: in, on, at, under, above, across, through, into, from, towards
3. THE Engliya_App SHALL provide Lesson 7.3 covering daily time expressions: always, usually, sometimes, often, every day, now, right now
4. THE Engliya_App SHALL provide at least 3 example sentences for each preposition or expression in Unit 7 lessons
5. THE Engliya_App SHALL provide Tamil translations for all Unit 7 explanations and examples

### Requirement 8: Unit 8 Lesson Content - Continuous Tenses

**User Story:** As a Learner, I want to learn continuous tenses, so that I can describe ongoing actions in present, past, and future.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide Lesson 8.1 covering present continuous tense with am/is/are + V-ing structure
2. THE Engliya_App SHALL provide Lesson 8.2 covering past continuous tense with was/were + V-ing structure
3. THE Engliya_App SHALL provide Lesson 8.3 covering future continuous tense with will be + V-ing structure
4. THE Engliya_App SHALL provide Lesson 8.4 covering continuous tenses in conversational context with question-answer patterns
5. THE Engliya_App SHALL provide at least 5 example sentences for each continuous tense form in Unit 8 lessons
6. THE Engliya_App SHALL provide Tamil translations for all Unit 8 explanations and examples

### Requirement 9: Unit 9 Lesson Content - Perfect & Perfect Continuous

**User Story:** As a Learner, I want to learn perfect tenses, so that I can describe completed actions and experiences.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide Lesson 9.1 covering present perfect tense with have/has + past participle structure
2. THE Engliya_App SHALL provide Lesson 9.2 covering past perfect tense with had + past participle structure
3. THE Engliya_App SHALL provide Lesson 9.3 covering future perfect tense with will have + past participle structure
4. THE Engliya_App SHALL provide Lesson 9.4 covering present perfect continuous tense with have/has been + V-ing structure
5. THE Engliya_App SHALL provide Lesson 9.5 comparing perfect tenses with simple past tense usage
6. THE Engliya_App SHALL provide at least 2 example sentences for each perfect tense form in Unit 9 lessons
7. THE Engliya_App SHALL provide Tamil translations for all Unit 9 explanations and examples

### Requirement 10: Unit 10 Lesson Content - Questions & Negatives

**User Story:** As a Learner, I want to learn how to form questions and negatives, so that I can ask questions and express negative statements correctly.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide Lesson 10.1 covering be-verb questions with am/is/are/was/were question formation
2. THE Engliya_App SHALL provide Lesson 10.2 covering do/does/did questions with proper word order
3. THE Engliya_App SHALL provide Lesson 10.3 covering WH-questions using who, what, when, where, why, how
4. THE Engliya_App SHALL provide Lesson 10.4 covering negatives using don't, doesn't, didn't, wasn't, weren't
5. THE Engliya_App SHALL provide Lesson 10.5 with real question-answer practice dialogues mixing all question types
6. THE Engliya_App SHALL provide at least 3 example questions for each question type in Unit 10 lessons
7. THE Engliya_App SHALL provide Tamil translations for all Unit 10 explanations and examples

### Requirement 11: Unit 11 Lesson Content - Advanced Pronouns, Adjectives & Adverbs

**User Story:** As a Learner, I want to learn advanced pronouns, adjectives, and adverbs, so that I can make my sentences more detailed and expressive.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide Lesson 11.1 covering possessive pronouns and adjectives: my, your, his, her, its, our, their, mine, yours, hers, ours, theirs
2. THE Engliya_App SHALL provide Lesson 11.2 covering reflexive pronouns: myself, yourself, himself, herself, itself, ourselves, yourselves, themselves
3. THE Engliya_App SHALL provide Lesson 11.3 covering demonstrative pronouns: this, that, these, those
4. THE Engliya_App SHALL provide Lesson 11.4 covering common adjectives: big, small, beautiful, clean, exciting, outstanding
5. THE Engliya_App SHALL provide Lesson 11.5 covering common adverbs: slowly, quickly, carefully, always, often
6. THE Engliya_App SHALL provide at least 3 example sentences for each pronoun, adjective, or adverb type in Unit 11 lessons
7. THE Engliya_App SHALL provide Tamil translations for all Unit 11 explanations and examples

### Requirement 12: Phase 2 JSON Asset Files

**User Story:** As a developer, I want Phase 2 lesson content stored in JSON files with consistent schema, so that the app can load and display content generically.

#### Acceptance Criteria

1. THE Engliya_App SHALL store Phase2 lesson JSON files in assets/lessons/phase2/ directory
2. THE Engliya_App SHALL name JSON files using pattern: lessonX_Y_topic_name.json where X is unit number and Y is lesson number
3. THE Engliya_App SHALL structure each JSON file with fields: id, order, unitId, title, description, level, explain, examples, listeningQuestions, speakSentences, practiceQuestions, masteryQuestions
4. THE Engliya_App SHALL use lesson ID format phase2_lessonX_Y for Phase2 lessons
5. THE Engliya_App SHALL use unitId format phase2_unitX for Phase2 units
6. THE Engliya_App SHALL register all Phase2 JSON files in pubspec.yaml assets section

### Requirement 13: Phase 2 Lesson Content Completeness - Units 7 & 8

**User Story:** As a Learner, I want Units 7 and 8 to have comprehensive content, so that I can thoroughly learn time/place language and continuous tenses.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide each Unit 7 lesson with at least 1 Tamil explanation paragraph and 1 English explanation paragraph
2. THE Engliya_App SHALL provide each Unit 7 lesson with at least 3 example sentences with Tamil translations
3. THE Engliya_App SHALL provide each Unit 7 lesson with at least 2 listening questions
4. THE Engliya_App SHALL provide each Unit 7 lesson with at least 3 speak sentences
5. THE Engliya_App SHALL provide each Unit 7 lesson with at least 3 practice questions
6. THE Engliya_App SHALL provide each Unit 7 lesson with at least 3 mastery questions
7. THE Engliya_App SHALL provide each Unit 8 lesson with at least 1 Tamil explanation paragraph and 1 English explanation paragraph
8. THE Engliya_App SHALL provide each Unit 8 lesson with at least 5 example sentences with Tamil translations
9. THE Engliya_App SHALL provide each Unit 8 lesson with at least 2 listening questions
10. THE Engliya_App SHALL provide each Unit 8 lesson with at least 3 speak sentences
11. THE Engliya_App SHALL provide each Unit 8 lesson with at least 5 practice questions
12. THE Engliya_App SHALL provide each Unit 8 lesson with at least 5 mastery questions

### Requirement 14: Phase 2 Lesson Content Completeness - Units 9, 10 & 11

**User Story:** As a Learner, I want Units 9, 10, and 11 to have sufficient content for learning, so that I can understand and practice the concepts.

#### Acceptance Criteria

1. THE Engliya_App SHALL provide each Unit 9, 10, and 11 lesson with at least 1 explanation paragraph in Tamil and English
2. THE Engliya_App SHALL provide each Unit 9, 10, and 11 lesson with at least 2 example sentences with Tamil translations
3. THE Engliya_App SHALL provide each Unit 9, 10, and 11 lesson with at least 2 practice questions
4. THE Engliya_App SHALL provide each Unit 9, 10, and 11 lesson with at least 2 mastery questions

### Requirement 15: Phase 2 Progress Tracking

**User Story:** As a Learner, I want my Phase 2 progress to be saved automatically, so that I can continue learning from where I left off.

#### Acceptance Criteria

1. THE Engliya_App SHALL extend Progress_Store to track progress for all Phase2 lesson IDs
2. THE Engliya_App SHALL store the same progress fields for Phase2 lessons as Phase1 lessons: explainDone, examplesDone, listeningScore, speakingScore, quizBestScore, masteryBestScore, isMastered, lastAccessed
3. THE Engliya_App SHALL persist Phase2 progress data across app sessions
4. WHEN the Engliya_App launches, THE Engliya_App SHALL restore Phase2 progress from Progress_Store
5. THE Engliya_App SHALL update Phase2 progress after each tab completion

### Requirement 16: Phase 2 Lesson Repository Extension

**User Story:** As a developer, I want the lesson repository to load Phase 2 lessons using the same logic as Phase 1, so that the codebase remains maintainable.

#### Acceptance Criteria

1. THE Engliya_App SHALL extend LessonRepository to load Phase2 lessons from assets/lessons/phase2/ directory
2. THE Engliya_App SHALL filter lessons by unitId when loading unit-specific lessons
3. THE Engliya_App SHALL parse Phase2 JSON files using the existing Lesson model
4. THE Engliya_App SHALL cache Phase2 lessons in memory during the session
5. THE Engliya_App SHALL handle asset loading errors for Phase2 lessons with user-friendly messages

### Requirement 17: Phase 2 UI Consistency

**User Story:** As a Learner, I want Phase 2 screens to look and behave like Phase 1 screens, so that I can navigate confidently without confusion.

#### Acceptance Criteria

1. THE Engliya_App SHALL reuse the existing LessonScreen component for Phase2 lessons without modification
2. THE Engliya_App SHALL apply the same theme, colors, and fonts to Phase2 screens as Phase1 screens
3. THE Engliya_App SHALL use the same status indicators (Locked, In Progress, Mastered) for Phase2 lessons
4. THE Engliya_App SHALL use the same tab completion logic for Phase2 lessons as Phase1 lessons
5. THE Engliya_App SHALL display Phase2 progress using the same format as Phase1 progress

### Requirement 18: Phase 2 Offline Operation

**User Story:** As a Learner, I want Phase 2 to work completely offline, so that I can learn without internet connectivity.

#### Acceptance Criteria

1. THE Engliya_App SHALL load all Phase2 lesson content from local JSON_Asset files
2. THE Engliya_App SHALL store all Phase2 progress in local Progress_Store
3. THE Engliya_App SHALL operate Phase2 functionality without requiring network connectivity
4. THE Engliya_App SHALL use TTS for Phase2 audio playback without network requests
5. THE Engliya_App SHALL load Phase2 lesson content within 2 seconds on standard mobile devices

### Requirement 19: Phase 2 State Management

**User Story:** As a developer, I want Phase 2 to use the existing state management architecture, so that the codebase remains consistent and maintainable.

#### Acceptance Criteria

1. THE Engliya_App SHALL reuse existing LessonProvider for Phase2 lesson state management
2. THE Engliya_App SHALL reuse existing ProgressProvider for Phase2 progress state management
3. THE Engliya_App SHALL extend HomeProvider to include Phase2 access status and progress
4. THE Engliya_App SHALL create Phase2UnitProvider for managing Phase2 unit screen state
5. THE Engliya_App SHALL dispose providers properly when Phase2 screens are closed

### Requirement 20: Phase 2 Error Handling

**User Story:** As a Learner, I want clear error messages if Phase 2 content fails to load, so that I understand what went wrong and can take action.

#### Acceptance Criteria

1. WHEN a Phase2 JSON_Asset file is missing, THE Engliya_App SHALL display error message "Unable to load lesson content"
2. WHEN Phase2 progress fails to save, THE Engliya_App SHALL display error message "Progress not saved. Please try again"
3. WHEN Phase2 lesson parsing fails, THE Engliya_App SHALL log the error and display user-friendly message
4. THE Engliya_App SHALL implement retry logic for Phase2 storage failures
5. THE Engliya_App SHALL continue Phase2 operation without audio if TTS fails
