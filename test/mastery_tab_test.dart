import 'package:engliya/features/learn/data/models/lesson.dart';
import 'package:engliya/features/learn/data/models/lesson_explain.dart';
import 'package:engliya/features/learn/data/models/quiz_question.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/domain/entities/lesson_validation_result.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/features/learn/presentation/providers/lesson_provider.dart';
import 'package:engliya/features/learn/presentation/providers/progress_provider.dart';
import 'package:engliya/features/learn/presentation/widgets/tabs/mastery_tab.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLessonRepository extends LessonRepository {
  @override
  Future<ValidatedLesson> loadLessonWithFallback(String lessonId) async {
    return ValidatedLesson(
      lesson: await loadLesson(lessonId),
      validation: const LessonValidationResult(isValid: true),
    );
  }

  @override
  Future<Lesson> loadLesson(String lessonId) async {
    return Lesson(
      id: lessonId,
      order: 1,
      unitId: 'phase1',
      title: 'Mastery Test Lesson',
      description: 'Desc',
      level: 'Beginner',
      explain: const LessonExplain(ta: 'ta', en: 'en'),
      examples: const [],
      listeningQuestions: const [],
      speakSentences: const [],
      practiceQuestions: const [],
      masteryQuestions: const [
        QuizQuestion(
          type: 'mcq',
          promptEn: 'Choose correct pronoun',
          options: ['Wrong', 'Correct'],
          correctIndex: 1,
        ),
      ],
    );
  }
}

void main() {
  testWidgets('Failed mastery shows Try Again and resets test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    final lessonRepo = _FakeLessonRepository();
    final progressRepo = ProgressRepository(storageService);
    final lessonProvider = LessonProvider(
      lessonRepo: lessonRepo,
      progressRepo: progressRepo,
    );
    final progressProvider = ProgressProvider(
      progressRepo: progressRepo,
      lessonRepo: lessonRepo,
      storageService: storageService,
    );

    await lessonProvider.loadLesson('phase1_lesson1');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: lessonProvider),
          ChangeNotifierProvider.value(value: progressProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MasteryTab()),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Start Mastery Test'));
    await tester.tap(find.text('Start Mastery Test'));
    await tester.pumpAndSettle();

    expect(find.text('Answered: 0 / 1'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Wrong'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Keep Practicing'), findsOneWidget);
    expect(find.textContaining('Try Again'), findsOneWidget);

    await tester.tap(find.textContaining('Try Again'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1'), findsOneWidget);
    expect(find.textContaining('Keep Practicing'), findsNothing);
  });
}
