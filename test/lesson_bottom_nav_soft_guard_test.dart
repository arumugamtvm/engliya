import 'package:engliya/features/learn/data/models/lesson.dart';
import 'package:engliya/features/learn/data/models/lesson_explain.dart';
import 'package:engliya/features/learn/data/models/quiz_question.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/features/learn/presentation/providers/lesson_provider.dart';
import 'package:engliya/features/learn/presentation/widgets/lesson_bottom_nav.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLessonRepository extends LessonRepository {
  @override
  Future<Lesson> loadLesson(String lessonId) async {
    return Lesson(
      id: lessonId,
      order: 1,
      unitId: 'phase1',
      title: 'Test Lesson',
      description: 'Desc',
      level: 'Beginner',
      explain: const LessonExplain(ta: 'ta', en: 'en'),
      examples: const [],
      listeningQuestions: const [],
      speakSentences: const [],
      practiceQuestions: const [
        QuizQuestion(
          type: 'mcq',
          promptEn: 'Q1',
          options: ['A', 'B'],
          correctIndex: 0,
        ),
      ],
      masteryQuestions: const [
        QuizQuestion(
          type: 'mcq',
          promptEn: 'M1',
          options: ['A', 'B'],
          correctIndex: 1,
        ),
      ],
    );
  }
}

void main() {
  testWidgets('Next shows soft-guard warning when tab is incomplete', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final lessonRepo = _FakeLessonRepository();
    final progressRepo = ProgressRepository(storageService);
    final lessonProvider = LessonProvider(
      lessonRepo: lessonRepo,
      progressRepo: progressRepo,
    );
    await lessonProvider.loadLesson('phase1_lesson1');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: lessonProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
            bottomNavigationBar: LessonBottomNav(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Scroll to the bottom of Explain tab to continue.'), findsOneWidget);
    expect(lessonProvider.currentTabIndex, 0);
  });
}
