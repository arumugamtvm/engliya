import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/app/routes.dart';
import 'package:engliya/features/home/presentation/screens/home_screen.dart';
import 'package:engliya/features/home/presentation/providers/home_provider.dart';
import 'package:engliya/features/home/services/home_service.dart';
import 'package:engliya/features/learn/presentation/screens/phase2_unit_screen.dart';
import 'package:engliya/features/learn/presentation/screens/phase2_lesson_list_screen.dart';
import 'package:engliya/features/learn/presentation/screens/lesson_screen.dart';
import 'package:engliya/features/learn/presentation/providers/progress_provider.dart';
import 'package:engliya/features/learn/presentation/providers/lesson_provider.dart';
import 'package:engliya/features/learn/presentation/providers/phase2_unit_provider.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/services/local_storage/storage_service.dart';

void main() {
  group('Phase 2 Navigation Flow Tests', () {
    late StorageService storageService;
    late ProgressRepository progressRepository;
    late LessonRepository lessonRepository;
    late HomeService homeService;

    setUp(() async {
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
      
      // Clear any existing data
      await progressRepository.clearAllProgress();
      await storageService.remove('phase1FinalTestPassed');
    });

    /// Helper to create test app with providers
    Widget createTestApp({
      required Widget home,
      bool phase2Unlocked = false,
    }) {
      // Set Phase 2 unlock status
      if (phase2Unlocked) {
        storageService.setBool('phase1FinalTestPassed', true);
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
            create: (context) => Phase2UnitProvider(
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

    testWidgets('HomeScreen displays Phase 2 tile with lock status when locked',
        (WidgetTester tester) async {
      // Build the app with Phase 2 locked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: false,
      ));
      
      // Wait for initial render
      await tester.pump();
      
      // Wait for async operations
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Phase 2 tile is displayed
      expect(find.text('Phase 2: Intermediate English'), findsOneWidget);
      expect(find.text('25 lessons across 5 units'), findsOneWidget);
      
      // Verify lock icon is displayed
      expect(find.byIcon(Icons.lock), findsWidgets);
      
      // Verify lock message is displayed
      expect(find.text('Complete Phase 1 Final Test to unlock'), findsOneWidget);
    });

    testWidgets('HomeScreen displays Phase 2 tile as unlocked when Phase 1 Final Test passed',
        (WidgetTester tester) async {
      // Build the app with Phase 2 unlocked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: true,
      ));
      
      // Wait for initial render
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Phase 2 tile is displayed
      expect(find.text('Phase 2: Intermediate English'), findsOneWidget);
      
      // Verify progress text is displayed (not lock message)
      expect(find.textContaining('lessons mastered'), findsOneWidget);
      
      // Verify lock message is NOT displayed
      expect(find.text('Complete Phase 1 Final Test to unlock'), findsNothing);
    });

    testWidgets('Phase 2 lock dialog appears when tapped while locked',
        (WidgetTester tester) async {
      // Build the app with Phase 2 locked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: false,
      ));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Find and tap the Phase 2 tile
      final phase2Tile = find.ancestor(
        of: find.text('Phase 2: Intermediate English'),
        matching: find.byType(InkWell),
      );
      await tester.tap(phase2Tile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify lock dialog is displayed
      expect(find.text('Phase 2 Locked'), findsOneWidget);
      expect(
        find.text('Please complete Phase 1 Final Test before starting Phase 2.'),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      // Tap OK to dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify dialog is dismissed and we're still on HomeScreen
      expect(find.text('Phase 2 Locked'), findsNothing);
      expect(find.text('Welcome to Engliya!'), findsOneWidget);
    });

    testWidgets('Navigation to Phase2UnitScreen when Phase 2 is unlocked',
        (WidgetTester tester) async {
      // Build the app with Phase 2 unlocked
      await tester.pumpWidget(createTestApp(
        home: const HomeScreen(),
        phase2Unlocked: true,
      ));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Find and tap the Phase 2 tile
      final phase2Tile = find.ancestor(
        of: find.text('Phase 2: Intermediate English'),
        matching: find.byType(InkWell),
      );
      await tester.tap(phase2Tile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we navigated to Phase2UnitScreen
      expect(find.byType(Phase2UnitScreen), findsOneWidget);
      
      // Verify units are displayed
      expect(find.text('Time & Place Language'), findsOneWidget);
      expect(find.text('Continuous Tenses'), findsOneWidget);
      expect(find.text('Perfect & Perfect Continuous'), findsOneWidget);
      expect(find.text('Questions & Negatives'), findsOneWidget);
      expect(find.text('Advanced Pronouns, Adjectives & Adverbs'), findsOneWidget);
    });

    testWidgets('Navigation from Phase2UnitScreen to Phase2LessonListScreen',
        (WidgetTester tester) async {
      // Start directly on Phase2UnitScreen
      await tester.pumpWidget(createTestApp(
        home: const Phase2UnitScreen(),
        phase2Unlocked: true,
      ));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Unit 7
      final unit7Card = find.ancestor(
        of: find.text('Time & Place Language'),
        matching: find.byType(InkWell),
      );
      await tester.tap(unit7Card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we navigated to Phase2LessonListScreen
      expect(find.byType(Phase2LessonListScreen), findsOneWidget);
      
      // Verify unit title is displayed in AppBar
      expect(find.text('Unit 7: Time & Place Language'), findsOneWidget);
      
      // Verify lessons are displayed
      expect(find.text('Time Prepositions'), findsOneWidget);
      expect(find.text('Place & Movement Prepositions'), findsOneWidget);
      expect(find.text('Daily Time Expressions'), findsOneWidget);
    });

    testWidgets('Navigation from Phase2LessonListScreen to LessonScreen',
        (WidgetTester tester) async {
      // Start directly on Phase2LessonListScreen for Unit 7
      await tester.pumpWidget(createTestApp(
        home: const Phase2LessonListScreen(unitId: 'phase2_unit7'),
        phase2Unlocked: true,
      ));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on first lesson (should be unlocked)
      final lesson1Card = find.ancestor(
        of: find.text('Time Prepositions'),
        matching: find.byType(InkWell),
      ).first;
      await tester.tap(lesson1Card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we navigated to LessonScreen
      expect(find.byType(LessonScreen), findsOneWidget);
      
      // Verify lesson content is displayed
      expect(find.text('Time Prepositions'), findsOneWidget);
    });

    testWidgets('Back navigation preserves state',
        (WidgetTester tester) async {
      // Start on Phase2UnitScreen
      await tester.pumpWidget(createTestApp(
        home: const Phase2UnitScreen(),
        phase2Unlocked: true,
      ));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to Unit 7 lesson list
      final unit7Card = find.ancestor(
        of: find.text('Time & Place Language'),
        matching: find.byType(InkWell),
      );
      await tester.tap(unit7Card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we're on Phase2LessonListScreen
      expect(find.byType(Phase2LessonListScreen), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify we're back on Phase2UnitScreen with state preserved
      expect(find.byType(Phase2UnitScreen), findsOneWidget);
      expect(find.text('Time & Place Language'), findsOneWidget);
      expect(find.text('Continuous Tenses'), findsOneWidget);
    });

    testWidgets('Complete navigation flow through Phase 2 screens',
        (WidgetTester tester) async {
      // Start on Phase2UnitScreen
      await tester.pumpWidget(createTestApp(
        home: const Phase2UnitScreen(),
        phase2Unlocked: true,
      ));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Step 1: Verify Phase2UnitScreen
      expect(find.byType(Phase2UnitScreen), findsOneWidget);

      // Step 2: Navigate to Phase2LessonListScreen (Unit 8)
      final unit8Card = find.ancestor(
        of: find.text('Continuous Tenses'),
        matching: find.byType(InkWell),
      );
      await tester.tap(unit8Card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Phase2LessonListScreen), findsOneWidget);
      expect(find.text('Unit 8: Continuous Tenses'), findsOneWidget);

      // Step 3: Navigate back to Phase2UnitScreen
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Phase2UnitScreen), findsOneWidget);

      // Step 4: Navigate to different unit (Unit 7)
      final unit7Card = find.ancestor(
        of: find.text('Time & Place Language'),
        matching: find.byType(InkWell),
      );
      await tester.tap(unit7Card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Phase2LessonListScreen), findsOneWidget);
      expect(find.text('Unit 7: Time & Place Language'), findsOneWidget);

      // Step 5: Navigate to LessonScreen
      final lesson1Card = find.ancestor(
        of: find.text('Time Prepositions'),
        matching: find.byType(InkWell),
      ).first;
      await tester.tap(lesson1Card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LessonScreen), findsOneWidget);

      // Step 6: Navigate back through screens
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Phase2LessonListScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Phase2UnitScreen), findsOneWidget);
    });
  });
}
