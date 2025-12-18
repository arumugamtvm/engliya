# Implementation Plan

- [x] 1. Create Phase 3 data models and core infrastructure
  - Create `Phase3Unit` model class in `lib/features/learn/data/models/phase3_unit.dart` with id, order, title, description, lessonCount, and masteredCount properties
  - Model should include progress calculation method returning mastered/total ratio
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_

- [x] 2. Extend LessonRepository for Phase 3 lesson loading
  - [x] 2.1 Add Phase 3 lesson ID to file name mapping
    - Extend `_getPhase3AssetPath()` method in `LessonRepository` to map all 27 Phase 3 lesson IDs to their JSON file names
    - Map format: `'phase3_lesson12_1': 'lesson12_1_story_listening.json'` for all lessons in units 12-17
    - Return asset path in format `'assets/lessons/phase3/{fileName}'`
    - _Requirements: 5.1, 5.2, 6.1, 7.1, 8.1, 9.1, 10.1_
  
  - [x] 2.2 Implement Phase 3 unit lesson loading logic
    - Create `_loadPhase3UnitLessons(String unitId)` method that loads all lessons for a Phase 3 unit
    - Create `_getPhase3LessonIds(String unitId)` method returning lesson ID arrays for each unit (12-17)
    - Unit 12: 4 lessons, Unit 13: 5 lessons, Unit 14: 4 lessons, Unit 15: 4 lessons, Unit 16: 5 lessons, Unit 17: 5 lessons
    - Sort loaded lessons by order property before returning
    - _Requirements: 5.1, 6.1, 7.1, 8.1, 9.1, 10.1_
  
  - [x] 2.3 Integrate Phase 3 into main lesson loading flow
    - Modify `loadUnitLessons()` method to detect `phase3_unit*` pattern and call `_loadPhase3UnitLessons()`
    - Ensure graceful error handling continues loading other lessons if one fails
    - _Requirements: 5.1, 12.1, 12.2_

- [x] 3. Create Phase3UnitProvider for state management
  - Create `Phase3UnitProvider` class in `lib/features/learn/presentation/providers/phase3_unit_provider.dart`
  - Implement state properties: `_units` list, `_isLoading` bool, `_error` string
  - Implement `loadUnits()` method that initializes 6 Phase3Unit objects with correct titles, descriptions, and lesson counts
  - Implement `_calculateUnitMasteredCount()` method that queries ProgressProvider for mastered lesson count per unit
  - Implement `reload()` and `clearError()` methods
  - Provider should extend ChangeNotifier and depend on ProgressProvider
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 13.1, 13.2_

- [x] 4. Build Phase3UnitScreen UI
  - [x] 4.1 Create Phase3UnitScreen widget structure
    - Create `Phase3UnitScreen` StatefulWidget in `lib/features/learn/presentation/screens/phase3_unit_screen.dart`
    - Add AppBar with title "Phase 3: Real-Life Communication"
    - Implement initState to call `Phase3UnitProvider.loadUnits()` on screen load
    - _Requirements: 2.1, 2.9_
  
  - [x] 4.2 Implement unit list display with Consumer
    - Use Consumer<Phase3UnitProvider> to rebuild on state changes
    - Display CircularProgressIndicator when `isLoading` is true
    - Display error state with error icon, message, and retry button when `error` is not null
    - Display ListView.builder with UnitCard widgets for each unit when data loaded
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 13.3_
  
  - [x] 4.3 Implement unit card tap navigation
    - Create `_navigateToLessonList()` method that navigates to Phase3LessonListScreen with unitId and unitTitle arguments
    - Call `Phase3UnitProvider.reload()` after returning from lesson list to refresh progress
    - _Requirements: 2.9, 14.5_

- [x] 5. Build Phase3LessonListScreen UI
  - [x] 5.1 Create Phase3LessonListScreen widget structure
    - Create `Phase3LessonListScreen` StatefulWidget in `lib/features/learn/presentation/screens/phase3_lesson_list_screen.dart`
    - Accept `unitId` as required constructor parameter
    - Add AppBar with unit title using `_getUnitTitle()` helper method
    - Implement initState to call `ProgressProvider.loadAllData()` on screen load
    - _Requirements: 3.1, 3.2, 3.3_
  
  - [x] 5.2 Implement lesson list display with lock status
    - Use Consumer<ProgressProvider> to access lesson data
    - Get lessons for current unit using `progressProvider.getUnitLessons(unitId)`
    - Display loading/error states similar to Phase3UnitScreen
    - Build ListView with LessonCard widgets showing lesson title, description, and status badge
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 12.1, 12.2_
  
  - [x] 5.3 Implement lesson unlock logic
    - For each lesson, call `progressProvider.isLessonUnlocked(lessonId)` to determine lock status
    - First lesson of Unit 12 (`phase3_lesson12_1`) unlocks when Phase 2 Final Test passed
    - Subsequent lessons unlock when previous lesson has `masteryBestScore >= 80.0`
    - Display appropriate status badge: Locked / In Progress / Mastered
    - _Requirements: 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [x] 5.4 Implement lesson tap handling
    - Create `_handleLessonTap()` method that checks if lesson is unlocked
    - If unlocked, navigate to LessonScreen with lessonId argument
    - If locked, show SnackBar with message "Please master the previous lesson first"
    - Reload progress after returning from lesson screen
    - _Requirements: 3.7, 3.8, 12.1_
  
  - [x] 5.5 Add Phase 3 Final Test placeholder card
    - Add Final Test card at bottom of lesson list (index = lessons.length)
    - Card shows "Phase 3 Final Test" title, "Units 12-17 • TBD Questions" subtitle
    - Display locked status until all 27 Phase 3 lessons mastered
    - Show message "Locked - Master all lessons first" when locked
    - Tapping locked card shows SnackBar explaining requirement
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [x] 6. Integrate Phase 3 into app navigation and routing
  - [x] 6.1 Add Phase 3 routes to AppRoutes
    - Add route constants: `phase3Unit = '/phase3'`, `phase3LessonList = '/phase3/unit/:unitId'`, `phase3FinalTest = '/phase3/finalTest'`
    - Add route handlers in `onGenerateRoute()` for all three Phase 3 routes
    - Phase3UnitScreen route should use `_buildRoute()` helper
    - Phase3LessonListScreen route should extract unitId from arguments map
    - Phase3FinalTest route should display placeholder screen with "Coming Soon" message
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 15.1, 15.2, 15.3_
  
  - [x] 6.2 Add Phase 3 entry point to HomeScreen
    - Add Phase 3 card/tile to HomeScreen after Phase 2 entry
    - Check `phase2FinalTestPassed` flag from storage to determine lock status
    - Display locked icon and "Locked" badge when Phase 2 not completed
    - Display unlocked icon and "Available" badge when Phase 2 completed
    - Tapping locked Phase 3 shows dialog: "Complete Phase 2 Final Test to unlock Phase 3"
    - Tapping unlocked Phase 3 navigates to Phase3UnitScreen
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
  
  - [x] 6.3 Register Phase3UnitProvider in app providers
    - Add Phase3UnitProvider to provider list in main.dart
    - Provider should receive ProgressProvider as dependency via ProxyProvider pattern
    - Ensure provider is available before Phase3UnitScreen is accessed
    - _Requirements: 2.1, 13.1_

- [x] 7. Create Unit 12 lesson JSON files (Story Listening & Retelling)
  - [x] 7.1 Create lesson12_1_story_listening.json
    - Create file in `assets/lessons/phase3/` directory
    - Include 4-6 line story about a simple everyday event
    - Add 3 listening comprehension questions (multiple choice)
    - Add 3 speak sentences for retelling practice
    - Add 5 practice questions about story details
    - Add 8 mastery questions mixing comprehension and retelling
    - Include Tamil and English explanations about story listening strategies
    - _Requirements: 5.2, 5.3, 5.6, 5.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 7.2 Create lesson12_2_story_qa.json
    - Create file with story and Who/What/Where/Why comprehension questions
    - Include 4 listening questions targeting different question types
    - Add practice and mastery questions focusing on question answering strategies
    - _Requirements: 5.2, 5.4, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 7.3 Create lesson12_3_story_retell.json
    - Create file with guided retelling prompts
    - Include 5 speak sentences with sentence starters for retelling
    - Add practice questions that build retelling skills progressively
    - _Requirements: 5.2, 5.5, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 7.4 Create lesson12_4_story_tense_change.json
    - Create file with tense transformation exercises
    - Include examples showing present to past tense changes
    - Add practice questions requiring tense conversion
    - _Requirements: 5.2, 5.6, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_

- [x] 8. Create Unit 13 lesson JSON files (Complex Sentences & Connectors)
  - [x] 8.1 Create lesson13_1_connectors_and.json
    - Create file teaching AND/BUT/OR coordinating conjunctions
    - Include explanation with examples of joining simple sentences
    - Add 3 example sentences demonstrating each connector
    - Add 5 practice questions on choosing correct connector
    - Add 10 mastery questions mixing all three connectors
    - _Requirements: 6.2, 6.3, 6.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 8.2 Create lesson13_2_because_so.json
    - Create file teaching cause-effect relationships
    - Include examples: "I was tired because I worked hard" vs "I worked hard, so I was tired"
    - Add practice questions on cause-effect sentence construction
    - _Requirements: 6.2, 6.4, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 8.3 Create lesson13_3_when_while.json
    - Create file teaching time connectors (when/while/after/before)
    - Include examples showing simultaneous and sequential actions
    - Add practice questions on time relationship expression
    - _Requirements: 6.2, 6.5, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 8.4 Create lesson13_4_although_however.json
    - Create file teaching contrast connectors
    - Include examples: "Although it rained, we went out" vs "It rained. However, we went out."
    - Add practice questions on expressing contrast
    - _Requirements: 6.2, 6.6, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 8.5 Create lesson13_5_paragraph_writing.json
    - Create file with paragraph writing guidance
    - Include sampleParagraph field with 8-10 sentence example paragraph
    - Add practice questions on paragraph structure and connector usage
    - Add mastery questions requiring identification of connectors in context
    - _Requirements: 6.2, 6.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_

- [x] 9. Create Unit 14 lesson JSON files (Passive Voice)
  - [x] 9.1 Create lesson14_1_passive_present.json
    - Create file teaching simple present passive (is/are + past participle)
    - Include examples: "The book is written by the author"
    - Add practice questions on active-to-passive transformation
    - _Requirements: 7.2, 7.3, 7.6, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 9.2 Create lesson14_2_passive_past.json
    - Create file teaching simple past passive (was/were + past participle)
    - Include examples: "The house was built in 1990"
    - Add practice questions on past passive construction
    - _Requirements: 7.2, 7.4, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 9.3 Create lesson14_3_passive_perfect_future.json
    - Create file teaching perfect and future passive forms
    - Include examples: "The work has been completed", "The project will be finished"
    - Add practice questions on advanced passive forms
    - _Requirements: 7.2, 7.5, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 9.4 Create lesson14_4_when_to_use_passive.json
    - Create file teaching appropriate passive voice usage contexts
    - Include examples from news, reports, and process descriptions
    - Add practice questions on choosing active vs passive voice
    - _Requirements: 7.2, 7.6, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_

- [x] 10. Create Unit 15 lesson JSON files (Reported Speech)
  - [x] 10.1 Create lesson15_1_reported_statements.json
    - Create file teaching indirect statements (He said that...)
    - Include examples showing tense backshift: "I am tired" → "He said he was tired"
    - Add practice questions on statement conversion
    - _Requirements: 8.2, 8.3, 8.6, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 10.2 Create lesson15_2_reported_questions.json
    - Create file teaching indirect questions (She asked where/if...)
    - Include examples: "Where do you live?" → "She asked where I lived"
    - Add practice questions on question conversion
    - _Requirements: 8.2, 8.4, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 10.3 Create lesson15_3_reported_commands.json
    - Create file teaching indirect commands (told to/asked to)
    - Include examples: "Close the door" → "He told me to close the door"
    - Add practice questions on command conversion
    - _Requirements: 8.2, 8.5, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 10.4 Create lesson15_4_dialogue_indirect.json
    - Create file with dialogue-to-reported-speech conversion exercises
    - Include multi-turn dialogue examples
    - Add practice questions requiring full dialogue conversion
    - _Requirements: 8.2, 8.6, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_

- [x] 11. Create Unit 16 lesson JSON files (Functional English)
  - [x] 11.1 Create lesson16_1_introductions.json
    - Create file teaching self-introduction patterns
    - Include examples: "My name is...", "I'm from...", "I work as..."
    - Add 5 speak sentences for introduction practice
    - Add practice questions on introduction dialogue completion
    - _Requirements: 9.2, 9.3, 9.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 11.2 Create lesson16_2_phone_calls.json
    - Create file teaching phone/online call communication patterns
    - Include examples: "May I speak to...", "Could you hold on?", "I'll call back later"
    - Add practice questions on phone conversation scenarios
    - _Requirements: 9.2, 9.4, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 11.3 Create lesson16_3_help_clarify.json
    - Create file teaching help-asking and clarification patterns
    - Include examples: "Could you help me with...", "What do you mean by...", "Let me check if I understand"
    - Add practice questions on clarification dialogues
    - _Requirements: 9.2, 9.5, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 11.4 Create lesson16_4_polite_requests.json
    - Create file teaching polite request and offer patterns
    - Include examples: "Would you mind...", "Could I possibly...", "Would you like me to..."
    - Add practice questions on politeness levels
    - _Requirements: 9.2, 9.6, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 11.5 Create lesson16_5_complaints_apologies.json
    - Create file teaching complaint and apology patterns
    - Include examples: "I'm afraid there's a problem", "I'm terribly sorry", "I apologize for..."
    - Add practice questions on appropriate responses
    - _Requirements: 9.2, 9.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_

- [x] 12. Create Unit 17 lesson JSON files (Speaking & Writing Projects)
  - [x] 12.1 Create lesson17_1_daily_routine_project.json
    - Create file with daily routine project guidance
    - Include sampleParagraph field with 10-sentence daily routine example
    - Add 5 speak sentences for describing daily activities
    - Add practice questions on time sequencing and routine vocabulary
    - Add mastery questions requiring routine description
    - _Requirements: 10.2, 10.3, 10.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 12.2 Create lesson17_2_description_project.json
    - Create file with description project guidance (place/person/event)
    - Include examples of descriptive paragraphs
    - Add practice questions on descriptive vocabulary and structure
    - _Requirements: 10.2, 10.4, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 12.3 Create lesson17_3_opinion_writing.json
    - Create file with opinion paragraph writing guidance
    - Include sampleParagraph with opinion structure: statement, reasons, conclusion
    - Add practice questions on opinion expression and supporting arguments
    - _Requirements: 10.2, 10.5, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 12.4 Create lesson17_4_mock_interview.json
    - Create file with mock interview guidance
    - Include interviewQuestions field with 5 common interview questions
    - Add 5 speak sentences with sample interview responses
    - Add practice questions on interview response strategies
    - _Requirements: 10.2, 10.6, 10.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
  
  - [x] 12.5 Create lesson17_5_mini_presentation.json
    - Create file with mini presentation guidance (30-60 seconds)
    - Include presentation structure: introduction, main points, conclusion
    - Add 5 speak sentences with presentation phrases
    - Add practice questions on presentation organization
    - _Requirements: 10.2, 10.7, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_

- [x] 13. Update pubspec.yaml to include Phase 3 assets
  - Add `assets/lessons/phase3/` directory to assets section in pubspec.yaml
  - Ensure all 27 Phase 3 JSON files are included in app bundle
  - Run `flutter pub get` to update asset manifest
  - _Requirements: 5.1, 6.1, 7.1, 8.1, 9.1, 10.1_

- [x] 14. Verify Phase 3 integration and unlock flow
  - Test Phase 3 locked state when Phase 2 not completed
  - Test Phase 3 unlocks after Phase 2 Final Test passed
  - Test first lesson of Unit 12 is accessible immediately after Phase 3 unlock
  - Test sequential lesson unlocking within and across units
  - Test progress persistence across app restarts
  - Test all 27 lessons load without errors
  - Test navigation flow: Home → Phase3Unit → LessonList → Lesson → back navigation
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.2, 4.3, 4.4, 4.5, 11.1, 11.2, 11.3, 11.4, 11.5, 13.4, 13.5_
