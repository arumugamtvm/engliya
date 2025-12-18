# Requirements Document

## Introduction

Phase 3 – Real-Life Communication extends the English learning app to B1 level proficiency, focusing on practical communication skills. This phase introduces learners to story comprehension and retelling, complex sentence structures with connectors, passive voice, reported speech, functional everyday English, and culminates in speaking and writing projects. The phase builds upon the grammar foundation from Phase 1 and 2, enabling learners to engage in natural, extended conversations and produce coherent multi-sentence paragraphs.

## Glossary

- **Phase3System**: The complete implementation of Phase 3 including Units 12-17, lesson content, navigation, and progress tracking
- **LessonScreen**: The existing reusable screen component with six tabs (Explain, Examples, Listen, Speak, Practice, Mastery)
- **UserLessonStatus**: Data model tracking completion status, scores, and mastery for individual lessons
- **MasteryThreshold**: The minimum score (80%) required to mark a lesson as mastered and unlock subsequent lessons
- **Phase2FinalTestPassed**: Boolean flag indicating successful completion of Phase 2's final test, used as gating condition
- **StorageService**: Local persistence layer for saving user progress and lesson status
- **LessonRepository**: Data access layer for loading lesson content from JSON files
- **Phase3UnitScreen**: Screen displaying all six units (12-17) within Phase 3
- **Phase3LessonListScreen**: Screen showing all lessons within a specific Phase 3 unit
- **StoryRetelling**: Learning activity where users listen to a story and reproduce it verbally
- **ConnectorSentences**: Complex sentences using conjunctions and linking words (and, but, because, although, etc.)
- **PassiveVoice**: Grammatical construction focusing on the action rather than the actor
- **ReportedSpeech**: Indirect speech construction for conveying what someone said
- **FunctionalEnglish**: Practical communication patterns for everyday situations
- **SpeakingProject**: Extended speaking activity requiring 30-60 seconds of continuous speech
- **WritingProject**: Paragraph composition activity requiring 6-10 coherent sentences

## Requirements

### Requirement 1

**User Story:** As a learner who has completed Phase 2, I want to access Phase 3 content, so that I can advance to real-life communication skills

#### Acceptance Criteria

1. WHEN the Phase3System initializes, THE Phase3System SHALL verify Phase2FinalTestPassed status from StorageService
2. WHILE Phase2FinalTestPassed equals false, THE Phase3System SHALL display Phase 3 as locked on the home screen
3. WHEN a user taps the locked Phase 3 entry, THE Phase3System SHALL display a dialog message stating "Complete Phase 2 Final Test to unlock Phase 3"
4. WHILE Phase2FinalTestPassed equals true, THE Phase3System SHALL display Phase 3 as unlocked and accessible
5. WHEN a user taps the unlocked Phase 3 entry, THE Phase3System SHALL navigate to Phase3UnitScreen

### Requirement 2

**User Story:** As a learner, I want to see all Phase 3 units organized clearly, so that I can understand the learning path and track my progress

#### Acceptance Criteria

1. WHEN Phase3UnitScreen loads, THE Phase3System SHALL display six units numbered 12 through 17
2. THE Phase3System SHALL display each unit with title, description, and mastery count in format "X/Y mastered"
3. WHEN Phase3UnitScreen renders Unit 12, THE Phase3System SHALL display title "Story Listening & Retelling" with lesson count "0/4 mastered"
4. WHEN Phase3UnitScreen renders Unit 13, THE Phase3System SHALL display title "Complex Sentences & Connectors" with lesson count "0/5 mastered"
5. WHEN Phase3UnitScreen renders Unit 14, THE Phase3System SHALL display title "Passive Voice" with lesson count "0/4 mastered"
6. WHEN Phase3UnitScreen renders Unit 15, THE Phase3System SHALL display title "Reported Speech" with lesson count "0/4 mastered"
7. WHEN Phase3UnitScreen renders Unit 16, THE Phase3System SHALL display title "Functional English" with lesson count "0/5 mastered"
8. WHEN Phase3UnitScreen renders Unit 17, THE Phase3System SHALL display title "Speaking & Writing Projects" with lesson count "0/5 mastered"
9. WHEN a user taps any unit card, THE Phase3System SHALL navigate to Phase3LessonListScreen with the selected unit identifier

### Requirement 3

**User Story:** As a learner, I want to see all lessons within a unit with their status, so that I know which lessons I can access and which I have completed

#### Acceptance Criteria

1. WHEN Phase3LessonListScreen loads for a unit, THE Phase3System SHALL retrieve all lesson definitions for that unit from LessonRepository
2. THE Phase3System SHALL display each lesson with title, short description, and status badge
3. THE Phase3System SHALL display lesson status as one of three states: "Locked", "In Progress", or "Mastered"
4. WHEN Phase3LessonListScreen loads for Unit 12 Lesson 1 and Phase2FinalTestPassed equals true, THE Phase3System SHALL display the lesson as unlocked
5. WHEN a lesson has mastery score below MasteryThreshold, THE Phase3System SHALL display status as "In Progress"
6. WHEN a lesson has mastery score at or above MasteryThreshold, THE Phase3System SHALL display status as "Mastered"
7. WHEN a user taps an unlocked lesson, THE Phase3System SHALL navigate to LessonScreen with the lesson identifier
8. WHEN a user taps a locked lesson, THE Phase3System SHALL display a message indicating the previous lesson must be mastered first

### Requirement 4

**User Story:** As a learner, I want each lesson to unlock only after mastering the previous one, so that I progress through content in the correct sequence

#### Acceptance Criteria

1. WHEN Phase3System evaluates lesson unlock status, THE Phase3System SHALL retrieve UserLessonStatus for the previous lesson in sequence
2. WHEN the previous lesson mastery score is at or above MasteryThreshold, THE Phase3System SHALL mark the current lesson as unlocked
3. WHEN the previous lesson mastery score is below MasteryThreshold, THE Phase3System SHALL mark the current lesson as locked
4. WHEN evaluating Unit 12 Lesson 1 unlock status, THE Phase3System SHALL unlock the lesson if Phase2FinalTestPassed equals true
5. WHEN evaluating any lesson after Unit 12 Lesson 1, THE Phase3System SHALL require the immediately preceding lesson to be mastered

### Requirement 5

**User Story:** As a learner, I want to access story-based lessons in Unit 12, so that I can practice listening comprehension and retelling skills

#### Acceptance Criteria

1. WHEN LessonRepository loads Unit 12 lessons, THE Phase3System SHALL load JSON files from path "assets/lessons/phase3/"
2. THE Phase3System SHALL load lesson12_1_story_listening.json containing story lines, listening questions, and retelling prompts
3. THE Phase3System SHALL load lesson12_2_story_qa.json containing comprehension questions with who, what, where, why patterns
4. THE Phase3System SHALL load lesson12_3_story_retell.json containing guided retelling activities with 3-5 sentence prompts
5. THE Phase3System SHALL load lesson12_4_story_tense_change.json containing tense transformation exercises
6. WHEN a story field exists in lesson JSON, THE Phase3System SHALL parse the story array containing line objects
7. WHEN LessonScreen displays a Unit 12 lesson, THE Phase3System SHALL render story content in the Explain tab

### Requirement 6

**User Story:** As a learner, I want to practice complex sentences with connectors in Unit 13, so that I can express relationships between ideas

#### Acceptance Criteria

1. WHEN LessonRepository loads Unit 13 lessons, THE Phase3System SHALL load five JSON files for connectors lessons
2. THE Phase3System SHALL load lesson13_1_connectors_and.json for coordinating conjunctions
3. THE Phase3System SHALL load lesson13_2_because_so.json for cause and effect relationships
4. THE Phase3System SHALL load lesson13_3_when_while.json for time relationships
5. THE Phase3System SHALL load lesson13_4_although_however.json for contrast relationships
6. THE Phase3System SHALL load lesson13_5_paragraph_writing.json containing paragraph samples and writing prompts
7. WHEN a sampleParagraph field exists in lesson JSON, THE Phase3System SHALL display the paragraph in the Examples tab

### Requirement 7

**User Story:** As a learner, I want to learn passive voice constructions in Unit 14, so that I can understand and use formal and news-style English

#### Acceptance Criteria

1. WHEN LessonRepository loads Unit 14 lessons, THE Phase3System SHALL load four JSON files for passive voice lessons
2. THE Phase3System SHALL load lesson14_1_passive_present.json for simple present passive constructions
3. THE Phase3System SHALL load lesson14_2_passive_past.json for simple past passive constructions
4. THE Phase3System SHALL load lesson14_3_passive_perfect_future.json for perfect and future passive constructions
5. THE Phase3System SHALL load lesson14_4_when_to_use_passive.json for appropriate passive voice usage contexts
6. WHEN LessonScreen displays Unit 14 lessons, THE Phase3System SHALL render passive voice examples with active-passive transformations

### Requirement 8

**User Story:** As a learner, I want to practice reported speech in Unit 15, so that I can convey what others have said indirectly

#### Acceptance Criteria

1. WHEN LessonRepository loads Unit 15 lessons, THE Phase3System SHALL load four JSON files for reported speech lessons
2. THE Phase3System SHALL load lesson15_1_reported_statements.json for indirect statements
3. THE Phase3System SHALL load lesson15_2_reported_questions.json for indirect questions
4. THE Phase3System SHALL load lesson15_3_reported_commands.json for indirect commands and requests
5. THE Phase3System SHALL load lesson15_4_dialogue_indirect.json for dialogue-to-reported-speech conversion exercises
6. WHEN LessonScreen displays Unit 15 lessons, THE Phase3System SHALL render direct-to-indirect speech transformations

### Requirement 9

**User Story:** As a learner, I want to practice functional everyday English in Unit 16, so that I can handle common real-life communication situations

#### Acceptance Criteria

1. WHEN LessonRepository loads Unit 16 lessons, THE Phase3System SHALL load five JSON files for functional English lessons
2. THE Phase3System SHALL load lesson16_1_introductions.json for self-introduction patterns
3. THE Phase3System SHALL load lesson16_2_phone_calls.json for telephone and online call communication
4. THE Phase3System SHALL load lesson16_3_help_clarify.json for asking help and clarification patterns
5. THE Phase3System SHALL load lesson16_4_polite_requests.json for polite request and offer patterns
6. THE Phase3System SHALL load lesson16_5_complaints_apologies.json for complaint and apology patterns
7. WHEN LessonScreen displays Unit 16 lessons, THE Phase3System SHALL render dialogue examples for each functional pattern

### Requirement 10

**User Story:** As a learner, I want to complete speaking and writing projects in Unit 17, so that I can demonstrate comprehensive communication skills

#### Acceptance Criteria

1. WHEN LessonRepository loads Unit 17 lessons, THE Phase3System SHALL load five JSON files for project lessons
2. THE Phase3System SHALL load lesson17_1_daily_routine_project.json containing 10-sentence writing and speaking prompts
3. THE Phase3System SHALL load lesson17_2_description_project.json for describing places, people, or events
4. THE Phase3System SHALL load lesson17_3_opinion_writing.json for opinion paragraph composition
5. THE Phase3System SHALL load lesson17_4_mock_interview.json containing interview question sets
6. THE Phase3System SHALL load lesson17_5_mini_presentation.json for 30-60 second presentation topics
7. WHEN interviewQuestions field exists in lesson JSON, THE Phase3System SHALL parse and display the question array

### Requirement 11

**User Story:** As a learner, I want my Phase 3 progress saved locally, so that I can continue from where I left off across app sessions

#### Acceptance Criteria

1. WHEN a user completes any Phase 3 lesson activity, THE Phase3System SHALL save UserLessonStatus to StorageService
2. THE Phase3System SHALL persist lesson identifier, completion percentage, mastery score, and timestamp for each Phase 3 lesson
3. WHEN Phase3System initializes, THE Phase3System SHALL retrieve all Phase 3 lesson statuses from StorageService
4. WHEN StorageService returns saved status for a lesson, THE Phase3System SHALL restore the lesson state including scores and completion
5. WHEN a lesson reaches MasteryThreshold, THE Phase3System SHALL persist the mastered status and unlock the next lesson

### Requirement 12

**User Story:** As a learner, I want to use the same familiar lesson interface for Phase 3, so that I can focus on content without learning new navigation

#### Acceptance Criteria

1. WHEN a user opens any Phase 3 lesson, THE Phase3System SHALL display the existing LessonScreen component
2. THE Phase3System SHALL populate all six tabs (Explain, Examples, Listen, Speak, Practice, Mastery) with Phase 3 lesson content
3. WHEN lesson JSON contains unknown fields like story or sampleParagraph, THE LessonScreen SHALL ignore unrecognized fields without errors
4. THE Phase3System SHALL render Explain tab content using the explain field from lesson JSON
5. THE Phase3System SHALL render Examples tab content using the examples array from lesson JSON
6. THE Phase3System SHALL render Listen tab content using the listeningQuestions array from lesson JSON
7. THE Phase3System SHALL render Speak tab content using the speakSentences array from lesson JSON
8. THE Phase3System SHALL render Practice tab content using the practiceQuestions array from lesson JSON
9. THE Phase3System SHALL render Mastery tab content using the masteryQuestions array from lesson JSON

### Requirement 13

**User Story:** As a learner, I want to see Phase 3 progress reflected in the app, so that I can track my advancement through real-life communication skills

#### Acceptance Criteria

1. WHEN Phase3UnitScreen displays a unit, THE Phase3System SHALL calculate mastered lesson count by counting lessons with mastery score at or above MasteryThreshold
2. THE Phase3System SHALL display mastery count in format "X/Y mastered" where X is mastered lessons and Y is total lessons
3. WHEN all lessons in a unit reach mastered status, THE Phase3System SHALL display the unit with visual indication of completion
4. WHEN Phase3System calculates overall Phase 3 progress, THE Phase3System SHALL count total mastered lessons across all six units
5. THE Phase3System SHALL update progress displays immediately after any lesson mastery status changes

### Requirement 14

**User Story:** As a developer, I want Phase 3 routing integrated into the app navigation, so that users can access Phase 3 screens through standard navigation patterns

#### Acceptance Criteria

1. THE Phase3System SHALL register route "/phase3" mapping to Phase3UnitScreen
2. THE Phase3System SHALL register route "/phase3/unit/:unitId" mapping to Phase3LessonListScreen with unit parameter
3. THE Phase3System SHALL register route "/phase3/lesson/:lessonId" mapping to LessonScreen with Phase 3 lesson parameter
4. WHEN a user navigates to "/phase3", THE Phase3System SHALL display Phase3UnitScreen
5. WHEN a user navigates to "/phase3/unit/12", THE Phase3System SHALL display Phase3LessonListScreen for Unit 12
6. WHEN a user navigates to "/phase3/lesson/12_1", THE Phase3System SHALL display LessonScreen with lesson12_1_story_listening content

### Requirement 15

**User Story:** As a learner, I want a placeholder for Phase 3 Final Test, so that I know there will be a comprehensive assessment after completing all units

#### Acceptance Criteria

1. THE Phase3System SHALL register route "/phase3/finalTest" for Phase 3 Final Test
2. WHEN a user navigates to "/phase3/finalTest", THE Phase3System SHALL display a placeholder screen
3. THE Phase3System SHALL display message indicating the final test is not yet implemented
4. WHEN Phase3System evaluates Phase 3 Final Test unlock status, THE Phase3System SHALL require all 27 Phase 3 lessons to be mastered
5. WHILE any Phase 3 lesson remains unmastered, THE Phase3System SHALL display Phase 3 Final Test as locked
