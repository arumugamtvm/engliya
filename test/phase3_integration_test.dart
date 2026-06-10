import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/app/routes.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3 Integration and Unlock Flow Tests', () {
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

      await progressRepository.clearAllProgress();
      await storageService.remove('phase1FinalTestPassed');
      await storageService.remove('phase2FinalTestPassed');
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

    Widget createTestApp({
      required Widget home,
      bool phase3Unlocked = false,
    }) {
      if (phase3Unlocked) {
        storageService.setBool('phase2FinalTestPassed', true);
      }

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

    /// The home phase tile is a GestureDetector-wrapped card containing the
    /// phase title text.
    Finder phaseTile(String title) => find
        .ancestor(of: find.text(title), matching: find.byType(GestureDetector))
        .first;

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

    group('Phase 3 Locked State Tests', () {
      testWidgets('Phase 3 displays as locked when Phase 2 not completed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: false,
        ));

        await pumpUi(tester);

        expect(find.text('Phase 3'), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsWidgets);

        // Verify the lock message is displayed on the Phase 3 tile
        await revealText(tester, 'Phase 3');
        expect(
          find.descendant(
            of: phaseTile('Phase 3'),
            matching: find.textContaining('Complete previous phase to unlock'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('Phase 3 lock dialog appears when tapped while locked',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: false,
        ));

        await pumpUi(tester);

        await revealText(tester, 'Phase 3');
        await tester.tap(find.text('Phase 3'));
        await pumpUi(tester, frames: 3);

        expect(find.textContaining('Phase 3 Locked'), findsOneWidget);
        expect(
          find.textContaining(
              'Complete Phase 2 Final Test to unlock Phase 3.'),
          findsOneWidget,
        );
      });
    });

    group('Phase 3 Unlock Tests', () {
      testWidgets('Phase 3 unlocks after Phase 2 Final Test passed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: true,
        ));

        await pumpUi(tester);

        expect(find.text('Phase 3'), findsOneWidget);

        // The Phase 3 tile must not show the locked message anymore
        await revealText(tester, 'Phase 3');
        expect(
          find.descendant(
            of: phaseTile('Phase 3'),
            matching: find.textContaining('Complete previous phase to unlock'),
          ),
          findsNothing,
        );
      });

      testWidgets('Navigation to Phase 3 unit screen when Phase 3 is unlocked',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: true,
        ));

        await pumpUi(tester);

        await revealText(tester, 'Phase 3');
        await tester.tap(find.text('Phase 3'));
        await pumpUi(tester);

        expect(find.byType(PhaseUnitScreen), findsOneWidget);
        await revealText(tester, 'Story Listening & Retelling');
        expect(find.text('Story Listening & Retelling'), findsOneWidget);
        await revealText(tester, 'Complex Sentences & Connectors');
        expect(find.text('Complex Sentences & Connectors'), findsOneWidget);
      });
    });

    group('First Lesson Accessibility Tests', () {
      test('First lesson of Unit 12 is accessible after Phase 3 unlock',
          () async {
        await storageService.setBool('phase2FinalTestPassed', true);

        final progressProvider = await createProgressProvider();

        expect(progressProvider.isLessonUnlocked('phase3_lesson12_1'), true);
      });

      testWidgets('First lesson loads without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const PhaseLessonListScreen(unitId: 'phase3_unit12'),
          phase3Unlocked: true,
        ));

        await pumpUi(tester);

        expect(find.byType(PhaseLessonListScreen), findsOneWidget);
        expect(find.text('Story Listening'), findsOneWidget);
      });
    });

    group('Sequential Lesson Unlocking Tests', () {
      test('Lesson 12.2 unlocks when Lesson 12.1 is mastered', () async {
        await storageService.setBool('phase2FinalTestPassed', true);

        final progressProvider = await createProgressProvider();

        expect(progressProvider.isLessonUnlocked('phase3_lesson12_2'), false);

        final status = UserLessonStatus(
          lessonId: 'phase3_lesson12_1',
          isMastered: true,
          masteryBestScore: 0.85,
        );
        await progressRepository.saveLessonProgress(status);
        await progressProvider.refreshLessonProgress('phase3_lesson12_1');

        expect(progressProvider.isLessonUnlocked('phase3_lesson12_2'), true);
      });

      test('Cross-unit unlocking from Unit 12 to Unit 13', () async {
        await storageService.setBool('phase2FinalTestPassed', true);

        final progressProvider = await createProgressProvider();

        await _masterLesson(
            progressRepository, progressProvider, 'phase3_lesson12_1');
        await _masterLesson(
            progressRepository, progressProvider, 'phase3_lesson12_2');
        await _masterLesson(
            progressRepository, progressProvider, 'phase3_lesson12_3');
        await _masterLesson(
            progressRepository, progressProvider, 'phase3_lesson12_4');

        expect(progressProvider.isLessonUnlocked('phase3_lesson13_1'), true);
      });

      test('All 27 Phase 3 lessons unlock sequentially', () async {
        await storageService.setBool('phase2FinalTestPassed', true);

        final progressProvider = await createProgressProvider();

        final allPhase3Lessons = [
          'phase3_lesson12_1', 'phase3_lesson12_2', 'phase3_lesson12_3',
          'phase3_lesson12_4',
          'phase3_lesson13_1', 'phase3_lesson13_2', 'phase3_lesson13_3',
          'phase3_lesson13_4', 'phase3_lesson13_5',
          'phase3_lesson14_1', 'phase3_lesson14_2', 'phase3_lesson14_3',
          'phase3_lesson14_4',
          'phase3_lesson15_1', 'phase3_lesson15_2', 'phase3_lesson15_3',
          'phase3_lesson15_4',
          'phase3_lesson16_1', 'phase3_lesson16_2', 'phase3_lesson16_3',
          'phase3_lesson16_4', 'phase3_lesson16_5',
          'phase3_lesson17_1', 'phase3_lesson17_2', 'phase3_lesson17_3',
          'phase3_lesson17_4', 'phase3_lesson17_5',
        ];

        expect(progressProvider.isLessonUnlocked(allPhase3Lessons[0]), true);

        for (int i = 0; i < allPhase3Lessons.length - 1; i++) {
          final currentLesson = allPhase3Lessons[i];
          final nextLesson = allPhase3Lessons[i + 1];

          expect(progressProvider.isLessonUnlocked(nextLesson), false,
              reason:
                  '$nextLesson should be locked before mastering $currentLesson');

          await _masterLesson(
              progressRepository, progressProvider, currentLesson);

          expect(progressProvider.isLessonUnlocked(nextLesson), true,
              reason:
                  '$nextLesson should be unlocked after mastering $currentLesson');
        }
      });
    });

    group('Progress Persistence Tests', () {
      test('Phase 3 progress persists across app restarts', () async {
        await storageService.setBool('phase2FinalTestPassed', true);

        final status = UserLessonStatus(
          lessonId: 'phase3_lesson13_2',
          isMastered: true,
          masteryBestScore: 0.88,
        );
        await progressRepository.saveLessonProgress(status);

        final newStorageService = StorageService();
        await newStorageService.init();
        await newStorageService.setBool('phase2FinalTestPassed', true);
        final newProgressRepository = ProgressRepository(newStorageService);
        final newProvider = ProgressProvider(
          progressRepo: newProgressRepository,
          lessonRepo: lessonRepository,
          storageService: newStorageService,
        );
        await newProvider.refreshPhaseUnlockStatus();

        await newProvider.refreshLessonProgress('phase3_lesson13_2');

        final restoredStatus = newProvider.getLessonStatus('phase3_lesson13_2');
        expect(restoredStatus, isNotNull);
        expect(restoredStatus!.isMastered, true);
        expect(restoredStatus.masteryBestScore, 0.88);
      });

      test('Unlock status persists based on saved progress', () async {
        await storageService.setBool('phase2FinalTestPassed', true);

        await _masterLesson(progressRepository, null, 'phase3_lesson12_1');
        await _masterLesson(progressRepository, null, 'phase3_lesson12_2');

        final newStorageService = StorageService();
        await newStorageService.init();
        await newStorageService.setBool('phase2FinalTestPassed', true);
        final newProgressRepository = ProgressRepository(newStorageService);
        final newProvider = ProgressProvider(
          progressRepo: newProgressRepository,
          lessonRepo: lessonRepository,
          storageService: newStorageService,
        );
        await newProvider.refreshPhaseUnlockStatus();

        await newProvider.refreshLessonProgress('phase3_lesson12_1');
        await newProvider.refreshLessonProgress('phase3_lesson12_2');

        expect(newProvider.isLessonUnlocked('phase3_lesson12_3'), true);
      });
    });

    group('All 27 Lessons Load Tests', () {
      test('All Unit 12 lessons load without errors', () async {
        final lessons = [
          'phase3_lesson12_1',
          'phase3_lesson12_2',
          'phase3_lesson12_3',
          'phase3_lesson12_4',
        ];

        for (final lessonId in lessons) {
          final lesson = await lessonRepository.loadLesson(lessonId);
          expect(lesson, isNotNull, reason: '$lessonId should load');
          expect(lesson.id, lessonId);
        }
      });

      test('All Unit 13 lessons load without errors', () async {
        final lessons = [
          'phase3_lesson13_1',
          'phase3_lesson13_2',
          'phase3_lesson13_3',
          'phase3_lesson13_4',
          'phase3_lesson13_5',
        ];

        for (final lessonId in lessons) {
          final lesson = await lessonRepository.loadLesson(lessonId);
          expect(lesson, isNotNull, reason: '$lessonId should load');
          expect(lesson.id, lessonId);
        }
      });

      test('All Unit 14 lessons load without errors', () async {
        final lessons = [
          'phase3_lesson14_1',
          'phase3_lesson14_2',
          'phase3_lesson14_3',
          'phase3_lesson14_4',
        ];

        for (final lessonId in lessons) {
          final lesson = await lessonRepository.loadLesson(lessonId);
          expect(lesson, isNotNull, reason: '$lessonId should load');
          expect(lesson.id, lessonId);
        }
      });

      test('All Unit 15 lessons load without errors', () async {
        final lessons = [
          'phase3_lesson15_1',
          'phase3_lesson15_2',
          'phase3_lesson15_3',
          'phase3_lesson15_4',
        ];

        for (final lessonId in lessons) {
          final lesson = await lessonRepository.loadLesson(lessonId);
          expect(lesson, isNotNull, reason: '$lessonId should load');
          expect(lesson.id, lessonId);
        }
      });

      test('All Unit 16 lessons load without errors', () async {
        final lessons = [
          'phase3_lesson16_1',
          'phase3_lesson16_2',
          'phase3_lesson16_3',
          'phase3_lesson16_4',
          'phase3_lesson16_5',
        ];

        for (final lessonId in lessons) {
          final lesson = await lessonRepository.loadLesson(lessonId);
          expect(lesson, isNotNull, reason: '$lessonId should load');
          expect(lesson.id, lessonId);
        }
      });

      test('All Unit 17 lessons load without errors', () async {
        final lessons = [
          'phase3_lesson17_1',
          'phase3_lesson17_2',
          'phase3_lesson17_3',
          'phase3_lesson17_4',
          'phase3_lesson17_5',
        ];

        for (final lessonId in lessons) {
          final lesson = await lessonRepository.loadLesson(lessonId);
          expect(lesson, isNotNull, reason: '$lessonId should load');
          expect(lesson.id, lessonId);
        }
      });

      test('All 27 Phase 3 lessons load without errors', () async {
        final allPhase3Lessons = [
          'phase3_lesson12_1', 'phase3_lesson12_2', 'phase3_lesson12_3',
          'phase3_lesson12_4',
          'phase3_lesson13_1', 'phase3_lesson13_2', 'phase3_lesson13_3',
          'phase3_lesson13_4', 'phase3_lesson13_5',
          'phase3_lesson14_1', 'phase3_lesson14_2', 'phase3_lesson14_3',
          'phase3_lesson14_4',
          'phase3_lesson15_1', 'phase3_lesson15_2', 'phase3_lesson15_3',
          'phase3_lesson15_4',
          'phase3_lesson16_1', 'phase3_lesson16_2', 'phase3_lesson16_3',
          'phase3_lesson16_4', 'phase3_lesson16_5',
          'phase3_lesson17_1', 'phase3_lesson17_2', 'phase3_lesson17_3',
          'phase3_lesson17_4', 'phase3_lesson17_5',
        ];

        int loadedCount = 0;
        for (final lessonId in allPhase3Lessons) {
          try {
            final lesson = await lessonRepository.loadLesson(lessonId);
            expect(lesson, isNotNull);
            expect(lesson.id, lessonId);
            loadedCount++;
          } catch (e) {
            fail('Failed to load $lessonId: $e');
          }
        }

        expect(loadedCount, 27,
            reason: 'All 27 Phase 3 lessons should load successfully');
      });
    });

    group('Navigation Flow Tests', () {
      testWidgets(
          'Complete navigation: Home -> Phase3Unit -> LessonList -> Lesson',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: true,
        ));

        await pumpUi(tester);

        expect(find.byType(HomeScreen), findsOneWidget);

        await revealText(tester, 'Phase 3');
        await tester.tap(find.text('Phase 3'));
        await pumpUi(tester);

        expect(find.byType(PhaseUnitScreen), findsOneWidget);

        final unit12Card = find.ancestor(
          of: find.text('Story Listening & Retelling'),
          matching: find.byType(InkWell),
        );
        await revealText(tester, 'Story Listening & Retelling');
        await tester.tap(unit12Card);
        await pumpUi(tester);

        expect(find.byType(PhaseLessonListScreen), findsOneWidget);

        final lesson1Card = find.ancestor(
          of: find.text('Story Listening'),
          matching: find.byType(InkWell),
        ).first;
        await tester.tap(lesson1Card);
        await pumpUi(tester);

        expect(find.byType(LessonScreen), findsOneWidget);
      });

      testWidgets('Back navigation preserves state',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const PhaseUnitScreen(phaseType: PhaseType.phase3),
          phase3Unlocked: true,
        ));

        await pumpUi(tester);

        expect(find.byType(PhaseUnitScreen), findsOneWidget);

        final unit13Card = find.ancestor(
          of: find.text('Complex Sentences & Connectors'),
          matching: find.byType(InkWell),
        );
        await revealText(tester, 'Complex Sentences & Connectors');
        await tester.tap(unit13Card);
        await pumpUi(tester);

        expect(find.byType(PhaseLessonListScreen), findsOneWidget);

        await tester.pageBack();
        await pumpUi(tester);

        expect(find.byType(PhaseUnitScreen), findsOneWidget);
        await revealText(tester, 'Story Listening & Retelling');
        expect(find.text('Story Listening & Retelling'), findsOneWidget);
        await revealText(tester, 'Complex Sentences & Connectors');
        expect(find.text('Complex Sentences & Connectors'), findsOneWidget);
      });

      testWidgets('Navigation between different units',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const PhaseUnitScreen(phaseType: PhaseType.phase3),
          phase3Unlocked: true,
        ));

        await pumpUi(tester);

        final unit12Card = find.ancestor(
          of: find.text('Story Listening & Retelling'),
          matching: find.byType(InkWell),
        );
        await revealText(tester, 'Story Listening & Retelling');
        await tester.tap(unit12Card);
        await pumpUi(tester);

        expect(
            find.text('Unit 12: Story Listening & Retelling'), findsOneWidget);

        await tester.pageBack();
        await pumpUi(tester);

        final unit14Card = find.ancestor(
          of: find.text('Passive Voice'),
          matching: find.byType(InkWell),
        );
        await revealText(tester, 'Passive Voice');
        await tester.tap(unit14Card);
        await pumpUi(tester);

        expect(find.text('Unit 14: Passive Voice'), findsOneWidget);
      });
    });
  });
}

Future<void> _masterLesson(
  ProgressRepository repo,
  ProgressProvider? provider,
  String lessonId,
) async {
  final status = UserLessonStatus(
    lessonId: lessonId,
    isMastered: true,
    masteryBestScore: 0.85,
  );
  await repo.saveLessonProgress(status);
  if (provider != null) {
    await provider.refreshLessonProgress(lessonId);
  }
}
