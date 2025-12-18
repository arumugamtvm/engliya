# Requirements Document

## Introduction

Phase 4 – Fluency, Pronunciation & Conversation is a B2-level fluency training module for the Engliya Flutter app. This phase focuses on improving pronunciation, stress, rhythm, and intonation while building speaking fluency through real-life conversations and discussion skills. The module consists of 4 units (Units 18-21) with 17 lessons total, emphasizing speaking-heavy exercises while maintaining compatibility with the existing LessonScreen architecture.

## Glossary

- **Phase 4**: The fourth learning phase in Engliya, focused on fluency and pronunciation (B2 level)
- **STT (Speech-to-Text)**: Device speech recognition service for capturing user speech
- **Mock Scoring**: Fallback scoring mechanism when STT is unavailable
- **Unit**: A collection of related lessons grouped by topic (e.g., Unit 18 - Pronunciation & Sound)
- **Lesson**: An individual learning module with Explain, Examples, Listen, Speak, Practice, and Mastery tabs
- **LessonScreen**: The shared Flutter screen component that renders lesson content across all phases
- **Dialogue**: A conversation exchange between two or more speakers used in conversation lessons
- **Syllable**: A unit of pronunciation having one vowel sound
- **Word Stress**: Emphasis placed on a particular syllable in a word
- **Sentence Stress**: Emphasis placed on content words in a sentence
- **Fluency**: The ability to speak smoothly and continuously without excessive pauses
- **Paraphrasing**: Expressing the same idea using different words
- **Debug Mode**: A developer feature that bypasses unlock requirements for testing

## Requirements

### Requirement 1

**User Story:** As a learner who has completed Phase 3, I want to access Phase 4 content, so that I can continue improving my English fluency and pronunciation skills.

#### Acceptance Criteria

1. WHEN a user has passed the Phase 3 Final Test THEN the System SHALL unlock Phase 4 and display it as accessible on the home screen
2. WHEN a user taps on a locked Phase 4 card THEN the System SHALL display a dialog stating "Finish Phase 3 Final Test to unlock Phase 4 Fluency Training"
3. WHEN debug mode is enabled THEN the System SHALL unlock Phase 4 regardless of Phase 3 completion status
4. WHEN Phase 4 is unlocked THEN the System SHALL display a Phase 4 card with title "Phase 4 – Fluency & Pronunciation" and status indicator (Locked/In Progress/Completed)

### Requirement 2

**User Story:** As a learner, I want to navigate through Phase 4 units and lessons, so that I can systematically learn pronunciation and fluency skills.

#### Acceptance Criteria

1. WHEN a user opens Phase 4 THEN the System SHALL display Phase4UnitScreen showing all 4 units (Unit 18-21) with progress indicators
2. WHEN a user taps on a unit THEN the System SHALL navigate to Phase4LessonListScreen displaying all lessons in that unit
3. WHEN displaying a unit card THEN the System SHALL show the count of mastered lessons out of total lessons (e.g., "2/4 lessons mastered")
4. WHEN a user taps on an unlocked lesson THEN the System SHALL open the existing LessonScreen with the lesson content

### Requirement 3

**User Story:** As a learner, I want lessons to unlock progressively within each unit, so that I learn concepts in the correct order.

#### Acceptance Criteria

1. WHEN Phase 4 is unlocked THEN the System SHALL unlock the first lesson of Unit 18 automatically
2. WHEN a lesson is mastered THEN the System SHALL unlock the next lesson in the same unit
3. WHEN all lessons in a unit are mastered THEN the System SHALL unlock the first lesson of the next unit
4. WHEN debug mode is enabled THEN the System SHALL unlock all Phase 4 lessons regardless of mastery status

### Requirement 4

**User Story:** As a learner, I want to learn pronunciation fundamentals in Unit 18, so that I can understand English sounds, syllables, and stress patterns.

#### Acceptance Criteria

1. WHEN loading Unit 18 lessons THEN the System SHALL provide 4 lessons: Sounds & Syllables, Word Stress, Sentence Stress & Rhythm, and Common Pronunciation Problems
2. WHEN displaying Lesson 18.1 (Sounds & Syllables) THEN the System SHALL include explanations of consonant vs vowel sounds and syllable counting with Tamil translations
3. WHEN displaying Lesson 18.2 (Word Stress) THEN the System SHALL include examples showing primary stress patterns (e.g., PHOtograph vs phoTOGraphy)
4. WHEN displaying Lesson 18.3 (Sentence Stress) THEN the System SHALL include exercises for identifying content word stress in sentences
5. WHEN displaying Lesson 18.4 (Pronunciation Problems) THEN the System SHALL address common issues for Tamil speakers (e.g., /w/ vs /v/, initial consonant clusters)

### Requirement 5

**User Story:** As a learner, I want to practice fluency techniques in Unit 19, so that I can speak more smoothly and naturally.

#### Acceptance Criteria

1. WHEN loading Unit 19 lessons THEN the System SHALL provide 4 lessons: Speaking Without Stopping, Sentence Expansion, Paraphrasing, and Handling Hesitation & Fillers
2. WHEN displaying Lesson 19.1 (Speaking Without Stopping) THEN the System SHALL include timed speaking prompts with completion percentage scoring
3. WHEN displaying Lesson 19.2 (Sentence Expansion) THEN the System SHALL include guided exercises for expanding simple sentences progressively
4. WHEN displaying Lesson 19.3 (Paraphrasing) THEN the System SHALL include exercises for expressing ideas in alternative ways
5. WHEN displaying Lesson 19.4 (Hesitation & Fillers) THEN the System SHALL include exercises for identifying and reducing excessive filler usage

### Requirement 6

**User Story:** As a learner, I want to practice real-life conversations in Unit 20, so that I can communicate effectively in common situations.

#### Acceptance Criteria

1. WHEN loading Unit 20 lessons THEN the System SHALL provide 5 lessons: Shopping & Money, Restaurant & Food, Travel & Hotel, Workplace English, and Emergencies & Health
2. WHEN displaying conversation lessons THEN the System SHALL include dialogue exchanges with role labels (e.g., Customer, Shopkeeper)
3. WHEN displaying Unit 20 lessons THEN the System SHALL emphasize Listen, Speak, and role-play exercises over written practice
4. WHEN a lesson contains dialogues THEN the System SHALL store them in a "dialogues" field with roleA, roleB, and lines array

### Requirement 7

**User Story:** As a learner, I want to develop discussion skills in Unit 21, so that I can express opinions and engage in conversations effectively.

#### Acceptance Criteria

1. WHEN loading Unit 21 lessons THEN the System SHALL provide 4 lessons: Agreeing & Disagreeing Politely, Giving Opinions & Reasons, Asking Follow-up Questions, and Mini Discussion Practice
2. WHEN displaying Lesson 21.1 (Agreeing & Disagreeing) THEN the System SHALL include polite phrases for agreement and disagreement
3. WHEN displaying Lesson 21.2 (Opinions & Reasons) THEN the System SHALL include sentence starters for expressing opinions with supporting reasons
4. WHEN displaying Lesson 21.4 (Mini Discussion) THEN the System SHALL include short discussion topics with multiple speaking prompts

### Requirement 8

**User Story:** As a learner, I want speaking exercises to provide feedback, so that I can improve my pronunciation and fluency.

#### Acceptance Criteria

1. WHEN STT service is available THEN the System SHALL use speech recognition to capture user speech and compare against target sentences
2. WHEN STT service is unavailable THEN the System SHALL use mock scoring fallback to provide approximate feedback
3. WHEN displaying speaking feedback THEN the System SHALL show encouragement messages (e.g., "Great rhythm!", "Try to say it a bit smoother next time")
4. WHEN a user completes a speaking exercise THEN the System SHALL record the attempt and allow retry

### Requirement 9

**User Story:** As a developer, I want Phase 4 lesson data stored in JSON files, so that content can be easily updated and maintained.

#### Acceptance Criteria

1. WHEN the app loads Phase 4 content THEN the System SHALL read JSON files from assets/lessons/phase4/ directory
2. WHEN parsing Phase 4 JSON files THEN the System SHALL use the same schema as Phases 1-3 with id, order, unitId, title, description, level, explain, examples, listeningQuestions, speakSentences, practiceQuestions, and masteryQuestions fields
3. WHEN a lesson contains dialogues THEN the System SHALL parse the optional "dialogues" field containing roleA, roleB, and lines array
4. WHEN registering Phase 4 assets THEN the System SHALL add "assets/lessons/phase4/" to pubspec.yaml

### Requirement 10

**User Story:** As a developer, I want Phase 4 to integrate with existing services, so that progress tracking and navigation work consistently.

#### Acceptance Criteria

1. WHEN tracking Phase 4 progress THEN the System SHALL use the existing UserLessonStatus map with Phase 4 lesson IDs
2. WHEN checking Phase 4 unlock status THEN the System SHALL use the existing GatingService with phase4Unlocked flag
3. WHEN navigating to Phase 4 screens THEN the System SHALL use routes /phase4, /phase4/unit/:unitId, and /phase4/lesson/:lessonId
4. WHEN loading Phase 4 lessons THEN the System SHALL extend LessonRepository to handle phase4_unit* patterns

