import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/features/home/presentation/screens/home_screen.dart';
import 'package:engliya/features/home/presentation/providers/home_provider.dart';
import 'package:engliya/features/home/services/home_service.dart';
import 'package:engliya/features/learn/presentation/screens/phase_unit_screen.dart';
import 'package:engliya/features/learn/presentation/screens/phase_lesson_list_screen.dart';
import 'package:engliya/features/learn/presentation/screens/lesson_screen.dart';
import 'package:engliya/features/learn/presentation/providers/progress_provider.dart';
import 'package:engliya/features/learn/presentation/providers/lesson_provider.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/features/learn/data/repositories/test_repository_impl.dart';
import 'package:engliya/features/learn/domain/entities/phase_config.dart';
import 'package:engliya/features/learn/domain/repositories/test_repository.dart';
import 'package:engliya/features/learn/services/gating_service.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:engliya/features/learn/data/models/user_lesson_status.dart';
import 'package:engliya/app/routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Offline Operation Tests', () {
    late StorageService storageService;
    late ProgressRepository progressRepository;
    late LessonRepository lessonRepository;
    late HomeService homeService;
    late GatingService gatingService;
    late TestRepository testRepository;

    setUp(() async {
      // Drop any asset futures left pending by a previous widget test's
      // fake-async zone (they would never complete in this test).
      rootBundle.clear();

      // Initialize mock SharedPreferences (simulates offline storage)
      SharedPreferences.setMockInitialValues({});

      storageService = StorageService();
      await storageService.init();
      progressRepository = ProgressRepository(storageService);
      lessonRepository = LessonRepository();
      homeService = HomeService(
        lessonRepo: lessonRepository,
        progressRepo: progressRepository,
        storageService: storageService,
      );
      gatingService = GatingService(
        storageService: storageService,
        progressRepository: progressRepository,
      );
      testRepository = TestRepositoryImpl(
        lessonRepository: lessonRepository,
        storageService: storageService,
      );

      // Clear any existing data
      await progressRepository.clearAllProgress();

      // Unlock Phase 2 (legacy key is still honored by gating)
      await storageService.setBool('phase1FinalTestPassed', true);
    });

    tearDown(() {
      lessonRepository.clearCache();
    });

    /// Pump a number of frames so async loads and entrance animations finish.
    /// (HomeScreen has a repeating pulse animation, so pumpAndSettle would
    /// never settle - timed pumps are required.)
    Future<void> pumpUi(WidgetTester tester, {int frames = 12}) async {
      await tester.pump();
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    /// Make sure [text] is visible, scrolling the nearest Scrollable when the
    /// widget is not currently built (ListViews build children lazily, so a
    /// previously scrolled list may have disposed off-screen items).
    Future<void> revealText(WidgetTester tester, String text) async {
      final finder = find.text(text);
      if (finder.evaluate().isEmpty) {
        final scrollable = find.byType(Scrollable).first;
        // Jump back to the top first - the target may be above the viewport.
        await tester.fling(scrollable, const Offset(0, 2000), 5000);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(finder, 150, scrollable: scrollable);
        }
      } else {
        await tester.ensureVisible(finder);
      }
      await tester.pump();
    }

    /// Create a ProgressProvider with the unlock-status cache refreshed.
    /// With gating active (no dev bypass), the cached phase unlock flags must
    /// be refreshed from storage before unlock getters return valid values.
    Future<ProgressProvider> createProgressProvider() async {
      final provider = ProgressProvider(
        progressRepo: progressRepository,
        lessonRepo: lessonRepository,
        storageService: storageService,
        gatingService: gatingService,
      );
      await provider.refreshPhaseUnlockStatus();
      return provider;
    }

    /// Helper to create test app with providers (simulating offline environment)
    Widget createOfflineTestApp({required Widget home}) {
      return MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<LessonRepository>.value(value: lessonRepository),
          Provider<ProgressRepository>.value(value: progressRepository),
          Provider<GatingService>.value(value: gatingService),
          Provider<TestRepository>.value(value: testRepository),
          ChangeNotifierProvider(
            create: (_) => ProgressProvider(
              progressRepo: progressRepository,
              lessonRepo: lessonRepository,
              storageService: storageService,
              gatingService: gatingService,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => HomeProvider(
              homeService: homeService,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => LessonProvider(
              lessonRepo: lessonRepository,
              progressRepo: progressRepository,
            ),
          ),
        ],
        child: MaterialApp(
          home: home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
    }

    group('Navigate Through All Phase 2 Screens Without Network', () {
      testWidgets('HomeScreen displays Phase 2 tile offline',
          (WidgetTester tester) async {
        // Build app in offline mode
        await tester.pumpWidget(createOfflineTestApp(
          home: const HomeScreen(),
        ));

        await pumpUi(tester);

        // Verify Phase 2 tile is displayed
        expect(find.text('Phase 2'), findsOneWidget);
      });

      testWidgets('Phase 2 unit screen loads all units offline',
          (WidgetTester tester) async {
        // Navigate to the Phase 2 unit screen
        await tester.pumpWidget(createOfflineTestApp(
          home: const PhaseUnitScreen(phaseType: PhaseType.phase2),
        ));

        await pumpUi(tester);

        // Verify all 5 units are displayed
        expect(find.text('Time & Place Language'), findsOneWidget);
        expect(find.text('Continuous Tenses'), findsOneWidget);
        expect(find.text('Perfect & Perfect Continuous'), findsOneWidget);
        expect(find.text('Questions & Negatives'), findsOneWidget);
        expect(find.text('Advanced Pronouns, Adjectives & Adverbs'),
            findsOneWidget);

        // Verify unit descriptions are displayed
        expect(find.text('Learn prepositions and time expressions'),
            findsOneWidget);
        expect(find.text('Present, past, and future continuous'),
            findsOneWidget);
      });

      testWidgets('PhaseLessonListScreen loads lessons offline',
          (WidgetTester tester) async {
        // Navigate to the lesson list for Unit 7
        await tester.pumpWidget(createOfflineTestApp(
          home: const PhaseLessonListScreen(unitId: 'phase2_unit7'),
        ));

        await pumpUi(tester);

        // Verify lessons are displayed
        expect(find.text('Time Prepositions'), findsOneWidget);
        expect(find.text('Place & Movement Prepositions'), findsOneWidget);
        expect(find.text('Daily Time Expressions'), findsOneWidget);
      });

      testWidgets('LessonScreen loads Phase 2 lesson content offline',
          (WidgetTester tester) async {
        // Navigate to LessonScreen for a Phase 2 lesson
        await tester.pumpWidget(createOfflineTestApp(
          home: const LessonScreen(lessonId: 'phase2_lesson7_1'),
        ));

        await pumpUi(tester);

        // Verify lesson content is displayed
        expect(find.text('Time Prepositions'), findsOneWidget);

        // Verify tabs are available
        expect(find.text('Explain'), findsOneWidget);
        expect(find.text('Examples'), findsOneWidget);
        expect(find.text('Listen'), findsOneWidget);
        expect(find.text('Speak'), findsOneWidget);
        expect(find.text('Practice'), findsOneWidget);
        expect(find.text('Mastery'), findsOneWidget);
      });

      testWidgets('Complete navigation flow through all Phase 2 screens offline',
          (WidgetTester tester) async {
        // Master Unit 7 lessons so the first Unit 8 lesson is unlocked
        // (gating is active - no dev-mode bypass).
        for (final lessonId in [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson7_3',
        ]) {
          await progressRepository.saveLessonProgress(UserLessonStatus(
            lessonId: lessonId,
            isMastered: true,
            masteryBestScore: 0.9,
          ));
        }

        // Start on HomeScreen
        await tester.pumpWidget(createOfflineTestApp(
          home: const HomeScreen(),
        ));

        await pumpUi(tester);

        // Navigate to the Phase 2 unit screen
        await revealText(tester, 'Phase 2');
        await tester.tap(find.text('Phase 2'));
        await pumpUi(tester);
        expect(find.byType(PhaseUnitScreen), findsOneWidget);

        // Navigate to PhaseLessonListScreen (Unit 8)
        final unit8Card = find.ancestor(
          of: find.text('Continuous Tenses'),
          matching: find.byType(InkWell),
        );
        await revealText(tester, 'Continuous Tenses');
        await tester.tap(unit8Card);
        await pumpUi(tester);
        expect(find.byType(PhaseLessonListScreen), findsOneWidget);
        expect(find.text('Unit 8: Continuous Tenses'), findsOneWidget);

        // Navigate to LessonScreen
        final lesson1Card = find.ancestor(
          of: find.text('Present Continuous'),
          matching: find.byType(InkWell),
        ).first;
        await tester.tap(lesson1Card);
        await pumpUi(tester);
        expect(find.byType(LessonScreen), findsOneWidget);

        // Navigate back through screens
        await tester.pageBack();
        await pumpUi(tester);
        expect(find.byType(PhaseLessonListScreen), findsOneWidget);

        await tester.pageBack();
        await pumpUi(tester);
        expect(find.byType(PhaseUnitScreen), findsOneWidget);

        await tester.pageBack();
        await pumpUi(tester);
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('Complete Phase 2 Lessons Without Network', () {
      testWidgets('Can complete lesson tabs offline',
          (WidgetTester tester) async {
        // Navigate to a Phase 2 lesson
        await tester.pumpWidget(createOfflineTestApp(
          home: const LessonScreen(lessonId: 'phase2_lesson7_1'),
        ));

        await pumpUi(tester);

        // Verify Explain tab is accessible
        final explainTab = find.text('Explain');
        expect(explainTab, findsOneWidget);
        await tester.tap(explainTab);
        await tester.pump();

        // Verify Examples tab is accessible
        final examplesTab = find.text('Examples');
        expect(examplesTab, findsOneWidget);
        await tester.tap(examplesTab);
        await pumpUi(tester, frames: 3);

        // Verify Practice tab is accessible
        final practiceTab = find.text('Practice');
        expect(practiceTab, findsOneWidget);
        await tester.tap(practiceTab);
        await pumpUi(tester, frames: 3);
      });

      test('Lesson content loads from local JSON assets offline', () async {
        // Load a Phase 2 lesson
        final lesson = await lessonRepository.loadLesson('phase2_lesson7_1');

        // Verify lesson loaded successfully
        expect(lesson, isNotNull);
        expect(lesson.id, 'phase2_lesson7_1');
        expect(lesson.title, 'Time Prepositions');
        expect(lesson.unitId, 'phase2_unit7');

        // Verify content is present
        expect(lesson.explain.ta, isNotEmpty);
        expect(lesson.explain.en, isNotEmpty);
        expect(lesson.examples, isNotEmpty);
        expect(lesson.practiceQuestions, isNotEmpty);
        expect(lesson.masteryQuestions, isNotEmpty);
      });

      test('All Phase 2 lessons load from local assets offline', () async {
        // Test loading all 25 Phase 2 lessons
        final allLessonIds = [
          // Unit 7
          'phase2_lesson7_1', 'phase2_lesson7_2', 'phase2_lesson7_3',
          // Unit 8
          'phase2_lesson8_1', 'phase2_lesson8_2', 'phase2_lesson8_3',
          'phase2_lesson8_4',
          // Unit 9
          'phase2_lesson9_1', 'phase2_lesson9_2', 'phase2_lesson9_3',
          'phase2_lesson9_4', 'phase2_lesson9_5',
          // Unit 10
          'phase2_lesson10_1', 'phase2_lesson10_2', 'phase2_lesson10_3',
          'phase2_lesson10_4', 'phase2_lesson10_5',
          // Unit 11
          'phase2_lesson11_1', 'phase2_lesson11_2', 'phase2_lesson11_3',
          'phase2_lesson11_4', 'phase2_lesson11_5',
        ];

        // Load each lesson
        for (final lessonId in allLessonIds) {
          final lesson = await lessonRepository.loadLesson(lessonId);
          expect(lesson, isNotNull, reason: '$lessonId should load offline');
          expect(lesson.id, lessonId);
        }
      });

      test('Progress saves to local storage offline', () async {
        // Create progress for a Phase 2 lesson
        final status = UserLessonStatus(
          lessonId: 'phase2_lesson8_1',
          explainDone: true,
          examplesDone: true,
          quizBestScore: 0.85,
          masteryBestScore: 0.90,
          isMastered: true,
          lastAccessed: DateTime.now(),
        );

        // Save progress (should work offline)
        await progressRepository.saveLessonProgress(status);

        // Load progress back
        final loadedStatus =
            await progressRepository.loadLessonProgress('phase2_lesson8_1');

        // Verify progress was saved
        expect(loadedStatus, isNotNull);
        expect(loadedStatus!.explainDone, true);
        expect(loadedStatus.examplesDone, true);
        expect(loadedStatus.quizBestScore, 0.85);
        expect(loadedStatus.masteryBestScore, 0.90);
        expect(loadedStatus.isMastered, true);
      });

      test('Multiple Phase 2 lessons can be completed offline', () async {
        // Complete multiple lessons
        final lessons = [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson8_1',
        ];

        for (final lessonId in lessons) {
          final status = UserLessonStatus(
            lessonId: lessonId,
            explainDone: true,
            examplesDone: true,
            isMastered: true,
            masteryBestScore: 0.85,
          );
          await progressRepository.saveLessonProgress(status);
        }

        // Verify all progress was saved
        final allProgress = await progressRepository.loadAllProgress();
        for (final lessonId in lessons) {
          expect(allProgress.containsKey(lessonId), true);
          expect(allProgress[lessonId]!.isMastered, true);
        }
      });
    });

    group('Verify All Functionality Works Offline', () {
      test('Phase 2 unlock status works offline', () async {
        // Set Phase 2 as unlocked
        await storageService.setBool('phase1FinalTestPassed', true);

        // Create provider (refreshes the cached unlock status)
        final provider = await createProgressProvider();

        // Verify Phase 2 is unlocked
        expect(provider.isPhase2Unlocked, true);
      });

      test('Lesson unlock logic works offline', () async {
        // Create provider (refreshes the cached unlock status)
        final provider = await createProgressProvider();

        // First lesson should be unlocked
        expect(provider.isLessonUnlocked('phase2_lesson7_1'), true);

        // Second lesson should be locked initially
        expect(provider.isLessonUnlocked('phase2_lesson7_2'), false);

        // Master first lesson
        final status = UserLessonStatus(
          lessonId: 'phase2_lesson7_1',
          isMastered: true,
          masteryBestScore: 0.85,
        );
        await progressRepository.saveLessonProgress(status);
        await provider.refreshLessonProgress('phase2_lesson7_1');

        // Second lesson should now be unlocked
        expect(provider.isLessonUnlocked('phase2_lesson7_2'), true);
      });

      test('Unit lesson filtering works offline', () async {
        // Create provider
        final provider = await createProgressProvider();

        // Load lessons for Unit 7
        await provider.loadAllData();
        final unit7Lessons = provider.getUnitLessons('phase2_unit7');

        // Verify correct lessons are returned
        expect(unit7Lessons.length, 3);
        expect(unit7Lessons[0].id, 'phase2_lesson7_1');
        expect(unit7Lessons[1].id, 'phase2_lesson7_2');
        expect(unit7Lessons[2].id, 'phase2_lesson7_3');
      });

      test('Phase 2 progress summary calculates offline', () async {
        // Master some Phase 2 lessons
        final masteredLessons = [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson8_1',
        ];

        for (final lessonId in masteredLessons) {
          final status = UserLessonStatus(
            lessonId: lessonId,
            isMastered: true,
            masteryBestScore: 0.85,
          );
          await progressRepository.saveLessonProgress(status);
        }

        // Load progress
        final allProgress = await progressRepository.loadAllProgress();

        // Count mastered Phase 2 lessons
        final masteredCount = allProgress.values
            .where((s) => s.lessonId.startsWith('phase2_') && s.isMastered)
            .length;

        // Verify count is correct
        expect(masteredCount, 3);
      });

      test('Lesson caching works offline', () async {
        // Load a lesson
        final lesson1 = await lessonRepository.loadLesson('phase2_lesson7_1');
        expect(lessonRepository.isCached('phase2_lesson7_1'), true);

        // Load same lesson again
        final lesson2 = await lessonRepository.loadLesson('phase2_lesson7_1');

        // Should be same instance from cache
        expect(identical(lesson1, lesson2), true);
      });

      test('Unit lessons load and cache offline', () async {
        // Load all lessons for a unit
        final lessons = await lessonRepository.loadUnitLessons('phase2_unit8');

        // Verify lessons loaded
        expect(lessons.length, 4);

        // Verify lessons are cached
        expect(lessonRepository.isCached('phase2_lesson8_1'), true);
        expect(lessonRepository.isCached('phase2_lesson8_2'), true);
        expect(lessonRepository.isCached('phase2_lesson8_3'), true);
        expect(lessonRepository.isCached('phase2_lesson8_4'), true);
      });

      test('Cross-unit unlock logic works offline', () async {
        // Create provider (refreshes the cached unlock status)
        final provider = await createProgressProvider();

        // Master all Unit 7 lessons
        final unit7Lessons = [
          'phase2_lesson7_1',
          'phase2_lesson7_2',
          'phase2_lesson7_3',
        ];
        for (final lessonId in unit7Lessons) {
          final status = UserLessonStatus(
            lessonId: lessonId,
            isMastered: true,
            masteryBestScore: 0.85,
          );
          await progressRepository.saveLessonProgress(status);
          await provider.refreshLessonProgress(lessonId);
        }

        // First lesson of Unit 8 should be unlocked
        expect(provider.isLessonUnlocked('phase2_lesson8_1'), true);
      });

      test('Last accessed lesson tracking works offline', () async {
        // Create provider
        final provider = await createProgressProvider();

        // Access a lesson
        final status = UserLessonStatus(
          lessonId: 'phase2_lesson9_2',
          lastAccessed: DateTime.now(),
        );
        await progressRepository.saveLessonProgress(status);
        await provider.refreshLessonProgress('phase2_lesson9_2');

        // Verify last accessed is tracked
        expect(provider.lastAccessedLessonId, 'phase2_lesson9_2');
      });

      test('Progress persistence works offline', () async {
        // Save progress
        final status = UserLessonStatus(
          lessonId: 'phase2_lesson10_3',
          explainDone: true,
          examplesDone: true,
          isMastered: true,
          masteryBestScore: 0.92,
        );
        await progressRepository.saveLessonProgress(status);

        // Create new repository (simulating app restart)
        final newStorageService = StorageService();
        await newStorageService.init();
        final newProgressRepository = ProgressRepository(newStorageService);

        // Load progress
        final loadedStatus = await newProgressRepository
            .loadLessonProgress('phase2_lesson10_3');

        // Verify progress persisted
        expect(loadedStatus, isNotNull);
        expect(loadedStatus!.explainDone, true);
        expect(loadedStatus.examplesDone, true);
        expect(loadedStatus.isMastered, true);
        expect(loadedStatus.masteryBestScore, 0.92);
      });

      test('All Phase 2 units load offline', () async {
        // Load lessons for all units
        final units = [
          'phase2_unit7',
          'phase2_unit8',
          'phase2_unit9',
          'phase2_unit10',
          'phase2_unit11',
        ];

        for (final unitId in units) {
          final lessons = await lessonRepository.loadUnitLessons(unitId);
          expect(lessons, isNotEmpty, reason: '$unitId should have lessons');
        }
      });

      test('Error handling works offline', () async {
        // Try to load non-existent lesson
        expect(
          () => lessonRepository.loadLesson('phase2_lesson99_1'),
          throwsA(isA<LessonLoadException>()),
        );

        // A well-formed but non-existent unit is rejected
        expect(
          () => lessonRepository.loadUnitLessons('phase2_unit99'),
          throwsA(isA<LessonLoadException>()),
        );

        // A malformed unit ID is rejected with a LessonLoadException
        expect(
          () => lessonRepository.loadUnitLessons('not_a_valid_unit'),
          throwsA(isA<LessonLoadException>()),
        );
      });
    });

    group('Offline Performance Tests', () {
      test('Phase 2 lessons load quickly offline', () async {
        // Measure load time for a lesson
        final stopwatch = Stopwatch()..start();
        await lessonRepository.loadLesson('phase2_lesson7_1');
        stopwatch.stop();

        // Should load within 2 seconds (as per requirements)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('Multiple Phase 2 lessons load efficiently offline', () async {
        // Load multiple lessons
        final stopwatch = Stopwatch()..start();
        await lessonRepository.loadLesson('phase2_lesson7_1');
        await lessonRepository.loadLesson('phase2_lesson8_1');
        await lessonRepository.loadLesson('phase2_lesson9_1');
        stopwatch.stop();

        // Should load within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Cached lessons load instantly offline', () async {
        // Load lesson first time
        await lessonRepository.loadLesson('phase2_lesson7_1');

        // Load from cache
        final stopwatch = Stopwatch()..start();
        await lessonRepository.loadLesson('phase2_lesson7_1');
        stopwatch.stop();

        // Cached load should be very fast (< 10ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });

      test('Unit lessons load efficiently offline', () async {
        // Load all lessons for a unit
        final stopwatch = Stopwatch()..start();
        await lessonRepository.loadUnitLessons('phase2_unit8');
        stopwatch.stop();

        // Should load within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });
    });
  });
}
