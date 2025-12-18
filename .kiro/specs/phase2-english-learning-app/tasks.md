# Implementation Plan

- [x] 1. Extend LessonRepository for Phase 2 support
  - Add Phase 2 lesson ID to filename mapping for all 25 lessons
  - Extend `_getAssetPath` method to handle phase2_ prefixed lesson IDs
  - Extend `loadUnitLessons` method to support phase2_unit7 through phase2_unit11
  - Add helper method `_loadPhase2UnitLessons` to load lessons by unit
  - _Requirements: 16.1, 16.2, 16.3, 16.5_

- [x] 2. Extend ProgressProvider for Phase 2 functionality
  - Add `getUnitLessons` method to filter lessons by unitId
  - Add `isPhase2Unlocked` getter to check phase1FinalTestPassed flag
  - Add `phase2Progress` getter to calculate Phase 2 mastery summary
  - Extend `isLessonUnlocked` method to handle Phase 2 unlock logic
  - Add `_getPreviousLessonId` helper method for Phase 2 lesson sequence
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 15.1, 15.2_

- [x] 3. Create Phase2Unit model and Phase2UnitProvider
  - Create Phase2Unit data class with id, order, title, description, lessonCount, masteredCount
  - Create Phase2UnitProvider with unit loading and progress calculation
  - Implement `loadUnits` method to initialize 5 Phase 2 units
  - Calculate mastered lesson count for each unit
  - Add loading and error state management
  - _Requirements: 3.1, 3.2, 3.3, 19.4_

- [x] 4. Create Phase2UnitScreen
  - Create Phase2UnitScreen stateful widget
  - Add AppBar with title "Phase 2: Intermediate English"
  - Integrate Phase2UnitProvider for state management
  - Display loading indicator while units load
  - Display error message if unit loading fails
  - Render ListView with 5 unit cards
  - Implement navigation to Phase2LessonListScreen on unit tap
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 5. Create UnitCard widget
  - Create UnitCard widget to display unit information
  - Display unit number badge with colored background
  - Display unit title and description
  - Display mastery progress "X / Y lessons mastered"
  - Add arrow icon for navigation affordance
  - Apply card styling with elevation and rounded corners
  - _Requirements: 3.2, 3.3, 17.2, 17.3_

- [x] 6. Create Phase2LessonListScreen
  - Create Phase2LessonListScreen stateful widget accepting unitId parameter
  - Add AppBar with dynamic unit title
  - Integrate ProgressProvider for lesson data and unlock status
  - Display loading indicator while lessons load
  - Display error message if lesson loading fails
  - Render ListView with LessonCard widgets (reused from Phase 1)
  - Implement lesson tap handling with unlock check
  - Show locked message snackbar for locked lessons
  - Navigate to LessonScreen for unlocked lessons
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

- [x] 7. Update HomeScreen for Phase 2 entry
  - Add Phase 2 tile to HomeScreen below Phase 1 tile
  - Display Phase 2 title "Phase 2: Intermediate English"
  - Display Phase 2 description "25 lessons across 5 units"
  - Display Phase 2 progress summary "X / 25 lessons mastered"
  - Add lock icon when Phase 2 is locked
  - Implement Phase 2 tap handler with lock check
  - Show lock dialog when tapped while locked: "Please complete Phase 1 Final Test before starting Phase 2"
  - Navigate to Phase2UnitScreen when unlocked
  - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.1, 2.2, 2.3, 2.4_

- [x] 8. Update app routes for Phase 2 navigation
  - Add phase2Unit route constant to AppRoutes
  - Add phase2LessonList route constant to AppRoutes
  - Add route case for phase2Unit in generateRoute
  - Add route case for phase2LessonList with unitId argument in generateRoute
  - Verify lesson route works for both Phase 1 and Phase 2 lesson IDs
  - _Requirements: 2.4, 3.4, 4.5_

- [x] 9. Register Phase2UnitProvider in app providers
  - Add Phase2UnitProvider to MultiProvider in main.dart
  - Ensure Phase2UnitProvider receives ProgressProvider dependency
  - Verify provider disposal on app close
  - _Requirements: 19.4, 19.5_

- [x] 10. Create Unit 7 lesson JSON files
- [x] 10.1 Create lesson7_1_time_prepositions.json
  - Add lesson metadata: id, order, unitId, title, description, level
  - Write Tamil and English explanations for time prepositions
  - Create table with on/in/at/since/for/ago/before/by examples
  - Add 5 example sentences with Tamil translations
  - Add 3 listening questions
  - Add 3 speak sentences
  - Add 5 practice MCQ questions
  - Add 5 mastery MCQ questions
  - _Requirements: 7.1, 7.4, 7.5, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

- [x] 10.2 Create lesson7_2_place_prepositions.json
  - Add lesson metadata for place and movement prepositions
  - Write Tamil and English explanations
  - Add 5 example sentences: in/on/at/under/above/across/through/into/from/towards
  - Add 3 listening questions
  - Add 3 speak sentences
  - Add 5 practice questions
  - Add 5 mastery questions
  - _Requirements: 7.2, 7.4, 7.5, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

- [x] 10.3 Create lesson7_3_time_expressions.json
  - Add lesson metadata for daily time expressions
  - Write Tamil and English explanations
  - Add 5 example sentences: always/usually/sometimes/often/every day/now/right now
  - Add 3 listening questions
  - Add 3 speak sentences
  - Add 5 practice questions
  - Add 5 mastery questions
  - _Requirements: 7.3, 7.4, 7.5, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

- [x] 11. Create Unit 8 lesson JSON files
- [x] 11.1 Create lesson8_1_present_continuous.json
  - Add lesson metadata for present continuous tense
  - Write Tamil and English explanations for am/is/are + V-ing structure
  - Add 5 example sentences with present continuous
  - Add 3 listening questions
  - Add 3 speak sentences
  - Add 5 practice questions
  - Add 5 mastery questions
  - _Requirements: 8.1, 8.5, 8.6, 13.7, 13.8, 13.9, 13.10, 13.11, 13.12_

- [x] 11.2 Create lesson8_2_past_continuous.json
  - Add lesson metadata for past continuous tense
  - Write Tamil and English explanations for was/were + V-ing structure
  - Add 5 example sentences with past continuous
  - Add 3 listening questions
  - Add 3 speak sentences
  - Add 5 practice questions
  - Add 5 mastery questions
  - _Requirements: 8.2, 8.5, 8.6, 13.7, 13.8, 13.9, 13.10, 13.11, 13.12_

- [x] 11.3 Create lesson8_3_future_continuous.json
  - Add lesson metadata for future continuous tense
  - Write Tamil and English explanations for will be + V-ing structure
  - Add 5 example sentences with future continuous
  - Add 3 listening questions
  - Add 3 speak sentences
  - Add 5 practice questions
  - Add 5 mastery questions
  - _Requirements: 8.3, 8.5, 8.6, 13.7, 13.8, 13.9, 13.10, 13.11, 13.12_

- [x] 11.4 Create lesson8_4_continuous_conversations.json
  - Add lesson metadata for continuous tenses in conversation
  - Write Tamil and English explanations with question-answer patterns
  - Add 5 conversational example sentences
  - Add 3 listening questions with questions and answers
  - Add 3 speak sentences
  - Add 5 practice questions
  - Add 5 mastery questions
  - _Requirements: 8.4, 8.5, 8.6, 13.7, 13.8, 13.9, 13.10, 13.11, 13.12_

- [x] 12. Create Unit 9 lesson JSON files
- [x] 12.1 Create lesson9_1_present_perfect.json
  - Add lesson metadata for present perfect tense
  - Write Tamil and English explanation for have/has + past participle
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 9.1, 9.6, 9.7, 14.1, 14.2, 14.3, 14.4_

- [x] 12.2 Create lesson9_2_past_perfect.json
  - Add lesson metadata for past perfect tense
  - Write Tamil and English explanation for had + past participle
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 9.2, 9.6, 9.7, 14.1, 14.2, 14.3, 14.4_

- [x] 12.3 Create lesson9_3_future_perfect.json
  - Add lesson metadata for future perfect tense
  - Write Tamil and English explanation for will have + past participle
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 9.3, 9.6, 9.7, 14.1, 14.2, 14.3, 14.4_

- [x] 12.4 Create lesson9_4_present_perfect_continuous.json
  - Add lesson metadata for present perfect continuous
  - Write Tamil and English explanation for have/has been + V-ing
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 9.4, 9.6, 9.7, 14.1, 14.2, 14.3, 14.4_

- [x] 12.5 Create lesson9_5_perfect_vs_past.json
  - Add lesson metadata comparing perfect and simple past
  - Write Tamil and English explanation of differences
  - Add 3 example sentences showing contrast
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 9.5, 9.6, 9.7, 14.1, 14.2, 14.3, 14.4_

- [x] 13. Create Unit 10 lesson JSON files
- [x] 13.1 Create lesson10_1_be_questions.json
  - Add lesson metadata for be-verb questions
  - Write Tamil and English explanation for am/is/are/was/were questions
  - Add 3 example questions
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 10.1, 10.6, 10.7, 14.1, 14.2, 14.3, 14.4_

- [x] 13.2 Create lesson10_2_do_does_did_questions.json
  - Add lesson metadata for do/does/did questions
  - Write Tamil and English explanation with word order
  - Add 3 example questions
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 10.2, 10.6, 10.7, 14.1, 14.2, 14.3, 14.4_

- [x] 13.3 Create lesson10_3_wh_questions.json
  - Add lesson metadata for WH-questions
  - Write Tamil and English explanation for who/what/when/where/why/how
  - Add 3 example questions
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 10.3, 10.6, 10.7, 14.1, 14.2, 14.3, 14.4_

- [x] 13.4 Create lesson10_4_negatives.json
  - Add lesson metadata for negative statements
  - Write Tamil and English explanation for don't/doesn't/didn't/wasn't/weren't
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 10.4, 10.6, 10.7, 14.1, 14.2, 14.3, 14.4_

- [x] 13.5 Create lesson10_5_real_qa.json
  - Add lesson metadata for real Q&A practice
  - Write Tamil and English explanation
  - Add 3 mini dialogue examples
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 10.5, 10.6, 10.7, 14.1, 14.2, 14.3, 14.4_

- [x] 14. Create Unit 11 lesson JSON files
- [x] 14.1 Create lesson11_1_possessive_pronouns.json
  - Add lesson metadata for possessive pronouns and adjectives
  - Write Tamil and English explanation for my/your/his/her/its/our/their and mine/yours/hers/ours/theirs
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 11.1, 11.6, 11.7, 14.1, 14.2, 14.3, 14.4_

- [x] 14.2 Create lesson11_2_reflexive_pronouns.json
  - Add lesson metadata for reflexive pronouns
  - Write Tamil and English explanation for myself/yourself/himself/herself/itself/ourselves/yourselves/themselves
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 11.2, 11.6, 11.7, 14.1, 14.2, 14.3, 14.4_

- [x] 14.3 Create lesson11_3_demonstrative_pronouns.json
  - Add lesson metadata for demonstrative pronouns
  - Write Tamil and English explanation for this/that/these/those
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 11.3, 11.6, 11.7, 14.1, 14.2, 14.3, 14.4_

- [x] 14.4 Create lesson11_4_adjectives.json
  - Add lesson metadata for common adjectives
  - Write Tamil and English explanation for big/small/beautiful/clean/exciting/outstanding
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 11.4, 11.6, 11.7, 14.1, 14.2, 14.3, 14.4_

- [x] 14.5 Create lesson11_5_adverbs.json
  - Add lesson metadata for common adverbs
  - Write Tamil and English explanation for slowly/quickly/carefully/always/often
  - Add 3 example sentences
  - Add 2 practice questions
  - Add 2 mastery questions
  - _Requirements: 11.5, 11.6, 11.7, 14.1, 14.2, 14.3, 14.4_

- [x] 15. Register Phase 2 assets in pubspec.yaml
  - Add assets/lessons/phase2/ directory to assets section
  - Verify all 25 JSON files are included
  - Run flutter pub get to register assets
  - _Requirements: 12.6, 18.1_

- [x] 16. Test Phase 2 repository extensions
  - Verify LessonRepository loads all 25 Phase 2 lessons correctly
  - Test asset path mapping for all Phase 2 lesson IDs
  - Test loadUnitLessons for each Phase 2 unit
  - Verify error handling for missing Phase 2 assets
  - Test lesson caching for Phase 2 lessons
  - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5_

- [x] 17. Test Phase 2 unlock logic
  - Test Phase 2 locked when phase1FinalTestPassed is false
  - Test Phase 2 unlocked when phase1FinalTestPassed is true
  - Test Lesson 7.1 unlocked by default when Phase 2 unlocked
  - Test sequential lesson unlocking within Unit 7
  - Test cross-unit unlocking from Unit 7 to Unit 8
  - Test unlock logic for all 25 Phase 2 lessons
  - _Requirements: 1.1, 1.2, 1.3, 5.1, 5.2, 5.3, 5.4_

- [x] 18. Test Phase 2 navigation flow
  - Test HomeScreen displays Phase 2 tile with lock status
  - Test Phase 2 lock dialog appears when tapped while locked
  - Test navigation to Phase2UnitScreen when unlocked
  - Test navigation from Phase2UnitScreen to Phase2LessonListScreen
  - Test navigation from Phase2LessonListScreen to LessonScreen
  - Test back navigation preserves state
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.4, 4.5_

- [x] 19. Test Phase 2 progress persistence
  - Complete Phase 2 lessons and verify progress saves
  - Close and reopen app, verify Phase 2 progress restored
  - Test unlock status persists across app sessions
  - Test last accessed lesson tracking for Phase 2
  - Verify Phase 2 progress summary updates correctly
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [x] 20. Test Phase 2 lesson content display
  - Open each Unit 7 lesson and verify all tabs display correctly
  - Open each Unit 8 lesson and verify all tabs display correctly
  - Verify Tamil and English text displays correctly
  - Verify TTS audio works for Phase 2 examples and listening questions
  - Test quiz and mastery scoring for Phase 2 lessons
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 17.1, 17.2, 17.4, 17.5_

- [x] 21. Test Phase 2 error handling
  - Test missing Phase 2 JSON file shows appropriate error
  - Test invalid Phase 2 JSON shows appropriate error
  - Test Phase 2 progress save failure with retry logic
  - Verify error messages are user-friendly
  - _Requirements: 16.5, 20.1, 20.2, 20.3, 20.4, 20.5_

- [x] 22. Verify Phase 2 offline operation
  - Disable network connectivity
  - Navigate through all Phase 2 screens
  - Complete Phase 2 lessons without network
  - Verify all functionality works offline
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_
