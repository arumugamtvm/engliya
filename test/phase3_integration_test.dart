import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/app/routes.dart';
import 'package:engliya/features/home/presentation/screens/home_screen.dart';
import 'package:engliya/features/home/presentation/providers/home_provider.dart';
import 'package:engliya/features/home/services/home_service.dart';
import 'package:engliya/features/learn/presentation/screens/phase3_unit_screen.dart';
import 'package:engliya/features/learn/presentation/screens/phase3_lesson_list_screen.dart';
import 'package:engliya/features/learn/presentation/screens/lesson_screen.dart';
import 'package:engliya/features/learn/presentation/providers/progress_provider.dart';
import 'package:engliya/features/learn/presentation/providers/lesson_provider.dart';
import 'package:engliya/features/learn/presentation/providers/phase3_unit_provider.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:engliya/features/learn/data/models/user_lesson_status.dart';

void main() {
  group('Phase 3 Integration and Unlock Flow Tests', () {
    late StorageService storageService;
    late ProgressRepository progressRepository;
    late LessonRepository lessonRepository;
    late HomeService homeService;

    setUp(() async {
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
      
      await progressRepository.clearAllProgress();
      await storageService.remove('phase1FinalTestPassed');
      await storageService.remove('phase2FinalTestPassed');
    });

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
          ChangeNotifierProvider(
            create: (_) => ProgressProvider(
              progressRepo: progressRepository,
              lessonRepo: lessonRepository,
              storageService: storageService,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => HomeProvider(
              homeService: homeService,
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => Phase3UnitProvider(
              context.read<ProgressProvider>(),
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

    group('Phase 3 Locked State Tests', () {
      testWidgets('Phase 3 displays as locked when Phase 2 not completed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: false,
        ));
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Phase 3: Real-Life Communication'), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsWidgets);
      });

      testWidgets('Phase 3 lock dialog appears when tapped while locked',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: false,
        ));
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final phase3Tile = find.ancestor(
          of: find.text('Phase 3: Real-Life Communication'),
          matching: find.byType(InkWell),
        );
        await tester.tap(phase3Tile);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Phase 3 Locked'), findsOneWidget);
        expect(
          find.text('Please complete Phase 2 Final Test before starting Phase 3.'),
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
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Phase 3: Real-Life Communication'), findsOneWidget);
        expect(find.textContaining('lessons mastered'), findsWidgets);
      });

      testWidgets('Navigation to Phase3UnitScreen when Phase 3 is unlocked',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: true,
        ));
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final phase3Tile = find.ancestor(
          of: find.text('Phase 3: Real-Life Communication'),
          matching: find.byType(InkWell),
        );
        await tester.tap(phase3Tile);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(Phase3UnitScreen), findsOneWidget);
        expect(find.text('Story Listening & Retelling'), findsOneWidget);
        expect(find.text('Complex Sentences & Connectors'), findsOneWidget);
      });
    });

    group('First Lesson Accessibility Tests', () {
      testWidgets('First lesson of Unit 12 is accessible after Phase 3 unlock',
          (WidgetTester tester) async {
        await storageService.setBool('phase2FinalTestPassed', true);
        
        final progressProvider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        expect(progressProvider.isLessonUnlocked('phase3_lesson12_1'), true);
      });

      testWidgets('First lesson loads without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const Phase3LessonListScreen(unitId: 'phase3_unit12'),
          phase3Unlocked: true,
        ));
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(Phase3LessonListScreen), findsOneWidget);
        expect(find.text('Short Story Listening'), findsOneWidget);
      });
    });

    group('Sequential Lesson Unlocking Tests', () {
      test('Lesson 12.2 unlocks when Lesson 12.1 is mastered', () async {
        await storageService.setBool('phase2FinalTestPassed', true);
        
        final progressProvider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

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
        
        final progressProvider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        await _masterLesson(progressRepository, progressProvider, 'phase3_lesson12_1');
        await _masterLesson(progressRepository, progressProvider, 'phase3_lesson12_2');
        await _masterLesson(progressRepository, progressProvider, 'phase3_lesson12_3');
        await _masterLesson(progressRepository, progressProvider, 'phase3_lesson12_4');

        expect(progressProvider.isLessonUnlocked('phase3_lesson13_1'), true);
      });

      test('All 27 Phase 3 lessons unlock sequentially', () async {
        await storageService.setBool('phase2FinalTestPassed', true);
        
        final progressProvider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        final allPhase3Lessons = [
          'phase3_lesson12_1', 'phase3_lesson12_2', 'phase3_lesson12_3', 'phase3_lesson12_4',
          'phase3_lesson13_1', 'phase3_lesson13_2', 'phase3_lesson13_3', 'phase3_lesson13_4', 'phase3_lesson13_5',
          'phase3_lesson14_1', 'phase3_lesson14_2', 'phase3_lesson14_3', 'phase3_lesson14_4',
          'phase3_lesson15_1', 'phase3_lesson15_2', 'phase3_lesson15_3', 'phase3_lesson15_4',
          'phase3_lesson16_1', 'phase3_lesson16_2', 'phase3_lesson16_3', 'phase3_lesson16_4', 'phase3_lesson16_5',
          'phase3_lesson17_1', 'phase3_lesson17_2', 'phase3_lesson17_3', 'phase3_lesson17_4', 'phase3_lesson17_5',
        ];

        expect(progressProvider.isLessonUnlocked(allPhase3Lessons[0]), true);

        for (int i = 0; i < allPhase3Lessons.length - 1; i++) {
          final currentLesson = allPhase3Lessons[i];
          final nextLesson = allPhase3Lessons[i + 1];

          expect(progressProvider.isLessonUnlocked(nextLesson), false,
              reason: '$nextLesson should be locked before mastering $currentLesson');

          await _masterLesson(progressRepository, progressProvider, currentLesson);

          expect(progressProvider.isLessonUnlocked(nextLesson), true,
              reason: '$nextLesson should be unlocked after mastering $currentLesson');
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
          'phase3_lesson12_1', 'phase3_lesson12_2', 'phase3_lesson12_3', 'phase3_lesson12_4',
          'phase3_lesson13_1', 'phase3_lesson13_2', 'phase3_lesson13_3', 'phase3_lesson13_4', 'phase3_lesson13_5',
          'phase3_lesson14_1', 'phase3_lesson14_2', 'phase3_lesson14_3', 'phase3_lesson14_4',
          'phase3_lesson15_1', 'phase3_lesson15_2', 'phase3_lesson15_3', 'phase3_lesson15_4',
          'phase3_lesson16_1', 'phase3_lesson16_2', 'phase3_lesson16_3', 'phase3_lesson16_4', 'phase3_lesson16_5',
          'phase3_lesson17_1', 'phase3_lesson17_2', 'phase3_lesson17_3', 'phase3_lesson17_4', 'phase3_lesson17_5',
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

        expect(loadedCount, 27, reason: 'All 27 Phase 3 lessons should load successfully');
      });
    });

    group('Navigation Flow Tests', () {
      testWidgets('Complete navigation: Home → Phase3Unit → LessonList → Lesson',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const HomeScreen(),
          phase3Unlocked: true,
        ));
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(HomeScreen), findsOneWidget);

        final phase3Tile = find.ancestor(
          of: find.text('Phase 3: Real-Life Communication'),
          matching: find.byType(InkWell),
        );
        await tester.tap(phase3Tile);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(Phase3UnitScreen), findsOneWidget);

        final unit12Card = find.ancestor(
          of: find.text('Story Listening & Retelling'),
          matching: find.byType(InkWell),
        );
        await tester.tap(unit12Card);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(Phase3LessonListScreen), findsOneWidget);

        final lesson1Card = find.ancestor(
          of: find.text('Short Story Listening'),
          matching: find.byType(InkWell),
        ).first;
        await tester.tap(lesson1Card);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(LessonScreen), findsOneWidget);
      });

      testWidgets('Back navigation preserves state',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const Phase3UnitScreen(),
          phase3Unlocked: true,
        ));
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(Phase3UnitScreen), findsOneWidget);

        final unit13Card = find.ancestor(
          of: find.text('Complex Sentences & Connectors'),
          matching: find.byType(InkWell),
        );
        await tester.tap(unit13Card);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(Phase3LessonListScreen), findsOneWidget);

        await tester.pageBack();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(Phase3UnitScreen), findsOneWidget);
        expect(find.text('Story Listening & Retelling'), findsOneWidget);
        expect(find.text('Complex Sentences & Connectors'), findsOneWidget);
      });

      testWidgets('Navigation between different units',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          home: const Phase3UnitScreen(),
          phase3Unlocked: true,
        ));
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final unit12Card = find.ancestor(
          of: find.text('Story Listening & Retelling'),
          matching: find.byType(InkWell),
        );
        await tester.tap(unit12Card);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Unit 12: Story Listening & Retelling'), findsOneWidget);

        await tester.pageBack();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final unit14Card = find.ancestor(
          of: find.text('Passive Voice'),
          matching: find.byType(InkWell),
        );
        await tester.tap(unit14Card);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

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
