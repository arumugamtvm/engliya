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

void main() {
  group('Phase 2 Navigation Flow Tests', () {
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

      // Mock SharedPreferences for widget tests
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
      await storageService.remove('phase1FinalTestPassed');
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

    /// Helper to create test app with providers
    Widget createTestApp({
      required Widget home,
      bool phase2Unlocked = false,
    }) {
      // Set Phase 2 unlock status (legacy key is still honored by gating)
      if (phase2Unlocked) {
        storageService.setBool('phase1FinalTestPassed', true);
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

    testWidgets('HomeScreen displays Phase 2 tile with lock status when locked',
        (WidgetTester tester) async {
      // Build the app with Phase 2 locked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: false,
      ));

      await pumpUi(tester);

      // Verify Phase 2 tile is displayed
      expect(find.text('Phase 2'), findsOneWidget);

      // Verify lock icon is displayed
      expect(find.byIcon(Icons.lock), findsWidgets);

      // Verify lock message is displayed on the Phase 2 tile
      expect(
        find.descendant(
          of: phaseTile('Phase 2'),
          matching: find.textContaining('Complete previous phase to unlock'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'HomeScreen displays Phase 2 tile as unlocked when Phase 1 Final Test passed',
        (WidgetTester tester) async {
      // Build the app with Phase 2 unlocked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: true,
      ));

      await pumpUi(tester);

      // Verify Phase 2 tile is displayed
      expect(find.text('Phase 2'), findsOneWidget);

      // Verify lock message is NOT displayed on the Phase 2 tile
      expect(
        find.descendant(
          of: phaseTile('Phase 2'),
          matching: find.textContaining('Complete previous phase to unlock'),
        ),
        findsNothing,
      );
    });

    testWidgets('Phase 2 lock dialog appears when tapped while locked',
        (WidgetTester tester) async {
      // Build the app with Phase 2 locked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: false,
      ));

      await pumpUi(tester);

      // Find and tap the Phase 2 tile
      await revealText(tester, 'Phase 2');
      await tester.tap(find.text('Phase 2'));
      await pumpUi(tester, frames: 3);

      // Verify lock dialog is displayed (bilingual strings)
      expect(find.textContaining('Phase 2 Locked'), findsOneWidget);
      expect(
        find.textContaining('Complete Phase 1 Final Test to unlock Phase 2.'),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      // Tap OK to dismiss dialog
      await tester.tap(find.text('OK'));
      await pumpUi(tester, frames: 3);

      // Verify dialog is dismissed and we're still on HomeScreen
      expect(find.textContaining('Phase 2 Locked'), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Navigation to PhaseUnitScreen when Phase 2 is unlocked',
        (WidgetTester tester) async {
      // Build the app with Phase 2 unlocked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: true,
      ));

      await pumpUi(tester);

      // Find and tap the Phase 2 tile
      await revealText(tester, 'Phase 2');
      await tester.tap(find.text('Phase 2'));
      await pumpUi(tester);

      // Verify we navigated to the Phase 2 unit screen
      expect(find.byType(PhaseUnitScreen), findsOneWidget);

      // Verify units are displayed
      expect(find.text('Time & Place Language'), findsOneWidget);
      expect(find.text('Continuous Tenses'), findsOneWidget);
      expect(find.text('Perfect & Perfect Continuous'), findsOneWidget);
      expect(find.text('Questions & Negatives'), findsOneWidget);
      expect(
          find.text('Advanced Pronouns, Adjectives & Adverbs'), findsOneWidget);
    });

    testWidgets('Navigation from PhaseUnitScreen to PhaseLessonListScreen',
        (WidgetTester tester) async {
      // Start directly on the Phase 2 unit screen
      await tester.pumpWidget(createTestApp(
        home: const PhaseUnitScreen(phaseType: PhaseType.phase2),
        phase2Unlocked: true,
      ));

      await pumpUi(tester);

      // Tap on Unit 7
      final unit7Card = find.ancestor(
        of: find.text('Time & Place Language'),
        matching: find.byType(InkWell),
      );
      await revealText(tester, 'Time & Place Language');
      await tester.tap(unit7Card);
      await pumpUi(tester);

      // Verify we navigated to PhaseLessonListScreen
      expect(find.byType(PhaseLessonListScreen), findsOneWidget);

      // Verify unit title is displayed in AppBar
      expect(find.text('Unit 7: Time & Place Language'), findsOneWidget);

      // Verify lessons are displayed
      expect(find.text('Time Prepositions'), findsOneWidget);
      expect(find.text('Place & Movement Prepositions'), findsOneWidget);
      expect(find.text('Daily Time Expressions'), findsOneWidget);
    });

    testWidgets('Navigation from PhaseLessonListScreen to LessonScreen',
        (WidgetTester tester) async {
      // Start directly on the lesson list for Unit 7
      await tester.pumpWidget(createTestApp(
        home: const PhaseLessonListScreen(unitId: 'phase2_unit7'),
        phase2Unlocked: true,
      ));

      await pumpUi(tester);

      // Tap on first lesson (should be unlocked)
      final lesson1Card = find.ancestor(
        of: find.text('Time Prepositions'),
        matching: find.byType(InkWell),
      ).first;
      await tester.tap(lesson1Card);
      await pumpUi(tester);

      // Verify we navigated to LessonScreen
      expect(find.byType(LessonScreen), findsOneWidget);

      // Verify lesson content is displayed
      expect(find.text('Time Prepositions'), findsOneWidget);
    });

    testWidgets('Back navigation preserves state',
        (WidgetTester tester) async {
      // Start on the Phase 2 unit screen
      await tester.pumpWidget(createTestApp(
        home: const PhaseUnitScreen(phaseType: PhaseType.phase2),
        phase2Unlocked: true,
      ));

      await pumpUi(tester);

      // Navigate to Unit 7 lesson list
      final unit7Card = find.ancestor(
        of: find.text('Time & Place Language'),
        matching: find.byType(InkWell),
      );
      await revealText(tester, 'Time & Place Language');
      await tester.tap(unit7Card);
      await pumpUi(tester);

      // Verify we're on PhaseLessonListScreen
      expect(find.byType(PhaseLessonListScreen), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await pumpUi(tester);

      // Verify we're back on the Phase 2 unit screen with state preserved
      expect(find.byType(PhaseUnitScreen), findsOneWidget);
      await revealText(tester, 'Time & Place Language');
      expect(find.text('Time & Place Language'), findsOneWidget);
      await revealText(tester, 'Continuous Tenses');
      expect(find.text('Continuous Tenses'), findsOneWidget);
    });

    testWidgets('Complete navigation flow through Phase 2 screens',
        (WidgetTester tester) async {
      // Start on the Phase 2 unit screen
      await tester.pumpWidget(createTestApp(
        home: const PhaseUnitScreen(phaseType: PhaseType.phase2),
        phase2Unlocked: true,
      ));

      await pumpUi(tester);

      // Step 1: Verify the Phase 2 unit screen
      expect(find.byType(PhaseUnitScreen), findsOneWidget);

      // Step 2: Navigate to PhaseLessonListScreen (Unit 8)
      final unit8Card = find.ancestor(
        of: find.text('Continuous Tenses'),
        matching: find.byType(InkWell),
      );
      await revealText(tester, 'Continuous Tenses');
      await tester.tap(unit8Card);
      await pumpUi(tester);
      expect(find.byType(PhaseLessonListScreen), findsOneWidget);
      expect(find.text('Unit 8: Continuous Tenses'), findsOneWidget);

      // Step 3: Navigate back to the unit screen
      await tester.pageBack();
      await pumpUi(tester);
      expect(find.byType(PhaseUnitScreen), findsOneWidget);

      // Step 4: Navigate to different unit (Unit 7)
      final unit7Card = find.ancestor(
        of: find.text('Time & Place Language'),
        matching: find.byType(InkWell),
      );
      await revealText(tester, 'Time & Place Language');
      await tester.tap(unit7Card);
      await pumpUi(tester);
      expect(find.byType(PhaseLessonListScreen), findsOneWidget);
      expect(find.text('Unit 7: Time & Place Language'), findsOneWidget);

      // Step 5: Navigate to LessonScreen
      final lesson1Card = find.ancestor(
        of: find.text('Time Prepositions'),
        matching: find.byType(InkWell),
      ).first;
      await tester.tap(lesson1Card);
      await pumpUi(tester);
      expect(find.byType(LessonScreen), findsOneWidget);

      // Step 6: Navigate back through screens
      await tester.pageBack();
      await pumpUi(tester);
      expect(find.byType(PhaseLessonListScreen), findsOneWidget);

      await tester.pageBack();
      await pumpUi(tester);
      expect(find.byType(PhaseUnitScreen), findsOneWidget);
    });
  });
}
