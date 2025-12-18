import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/features/learn/presentation/providers/progress_provider.dart';
import 'package:engliya/features/learn/data/repositories/lesson_repository.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:engliya/features/learn/data/models/user_lesson_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Unlock Logic Tests', () {
    late StorageService storageService;
    late ProgressRepository progressRepository;
    late LessonRepository lessonRepository;
    late ProgressProvider progressProvider;

    setUp(() async {
      // Initialize mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      storageService = StorageService();
      await storageService.init();
      progressRepository = ProgressRepository(storageService);
      lessonRepository = LessonRepository();
      
      // Clear all data
      await progressRepository.clearAllProgress();
      await storageService.remove('phase1FinalTestPassed');
      
      progressProvider = ProgressProvider(
        progressRepo: progressRepository,
        lessonRepo: lessonRepository,
        storageService: storageService,
      );
    });

    tearDown(() {
      lessonRepository.clearCache();
    });

    group('Phase 2 Access Control', () {
      test('Phase 2 is locked when phase1FinalTestPassed is false', () async {
        // Set phase1FinalTestPassed to false
        await storageService.setBool('phase1FinalTestPassed', false);
        
        // Create new provider to pick up the value
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        expect(provider.isPhase2Unlocked, false);
      });

      test('Phase 2 is locked when phase1FinalTestPassed is not set', () async {
        // Ensure phase1FinalTestPassed is not set
        await storageService.remove('phase1FinalTestPassed');
        
        // Create new provider
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        expect(provider.isPhase2Unlocked, false);
      });

      test('Phase 2 is unlocked when phase1FinalTestPassed is true', () async {
        // Set phase1FinalTestPassed to true
        await storageService.setBool('phase1FinalTestPassed', true);
        
        // Create new provider to pick up the value
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        expect(provider.isPhase2Unlocked, true);
      });
    });

    group('Lesson 7.1 Unlock Logic', () {
      test('Lesson 7.1 is locked when Phase 2 is locked', () async {
        // Phase 2 is locked by default
        await storageService.setBool('phase1FinalTestPassed', false);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        expect(provider.isLessonUnlocked('phase2_lesson7_1'), false);
      });

      test('Lesson 7.1 is unlocked by default when Phase 2 is unlocked', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        expect(provider.isLessonUnlocked('phase2_lesson7_1'), true);
      });
    });

    group('Sequential Lesson Unlocking Within Unit 7', () {
      test('Lesson 7.2 is locked when Lesson 7.1 is not mastered', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Lesson 7.1 is not mastered
        final status7_1 = UserLessonStatus(
          lessonId: 'phase2_lesson7_1',
          isMastered: false,
        );
        await progressRepository.saveLessonProgress(status7_1);
        await provider.refreshLessonProgress('phase2_lesson7_1');

        expect(provider.isLessonUnlocked('phase2_lesson7_2'), false);
      });

      test('Lesson 7.2 is unlocked when Lesson 7.1 is mastered', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master Lesson 7.1
        final status7_1 = UserLessonStatus(
          lessonId: 'phase2_lesson7_1',
          isMastered: true,
          masteryBestScore: 0.85,
        );
        await progressRepository.saveLessonProgress(status7_1);
        await provider.refreshLessonProgress('phase2_lesson7_1');

        expect(provider.isLessonUnlocked('phase2_lesson7_2'), true);
      });

      test('Lesson 7.3 is locked when Lesson 7.2 is not mastered', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master Lesson 7.1 but not 7.2
        final status7_1 = UserLessonStatus(
          lessonId: 'phase2_lesson7_1',
          isMastered: true,
          masteryBestScore: 0.85,
        );
        final status7_2 = UserLessonStatus(
          lessonId: 'phase2_lesson7_2',
          isMastered: false,
        );
        await progressRepository.saveLessonProgress(status7_1);
        await progressRepository.saveLessonProgress(status7_2);
        await provider.refreshLessonProgress('phase2_lesson7_1');
        await provider.refreshLessonProgress('phase2_lesson7_2');

        expect(provider.isLessonUnlocked('phase2_lesson7_3'), false);
      });

      test('Lesson 7.3 is unlocked when Lesson 7.2 is mastered', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master Lessons 7.1 and 7.2
        final status7_1 = UserLessonStatus(
          lessonId: 'phase2_lesson7_1',
          isMastered: true,
          masteryBestScore: 0.85,
        );
        final status7_2 = UserLessonStatus(
          lessonId: 'phase2_lesson7_2',
          isMastered: true,
          masteryBestScore: 0.90,
        );
        await progressRepository.saveLessonProgress(status7_1);
        await progressRepository.saveLessonProgress(status7_2);
        await provider.refreshLessonProgress('phase2_lesson7_1');
        await provider.refreshLessonProgress('phase2_lesson7_2');

        expect(provider.isLessonUnlocked('phase2_lesson7_3'), true);
      });
    });

    group('Cross-Unit Unlocking from Unit 7 to Unit 8', () {
      test('Lesson 8.1 is locked when Lesson 7.3 is not mastered', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master Lessons 7.1 and 7.2 but not 7.3
        final status7_1 = UserLessonStatus(
          lessonId: 'phase2_lesson7_1',
          isMastered: true,
          masteryBestScore: 0.85,
        );
        final status7_2 = UserLessonStatus(
          lessonId: 'phase2_lesson7_2',
          isMastered: true,
          masteryBestScore: 0.90,
        );
        final status7_3 = UserLessonStatus(
          lessonId: 'phase2_lesson7_3',
          isMastered: false,
        );
        await progressRepository.saveLessonProgress(status7_1);
        await progressRepository.saveLessonProgress(status7_2);
        await progressRepository.saveLessonProgress(status7_3);
        await provider.refreshLessonProgress('phase2_lesson7_1');
        await provider.refreshLessonProgress('phase2_lesson7_2');
        await provider.refreshLessonProgress('phase2_lesson7_3');

        expect(provider.isLessonUnlocked('phase2_lesson8_1'), false);
      });

      test('Lesson 8.1 is unlocked when Lesson 7.3 is mastered', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all Unit 7 lessons
        final status7_1 = UserLessonStatus(
          lessonId: 'phase2_lesson7_1',
          isMastered: true,
          masteryBestScore: 0.85,
        );
        final status7_2 = UserLessonStatus(
          lessonId: 'phase2_lesson7_2',
          isMastered: true,
          masteryBestScore: 0.90,
        );
        final status7_3 = UserLessonStatus(
          lessonId: 'phase2_lesson7_3',
          isMastered: true,
          masteryBestScore: 0.88,
        );
        await progressRepository.saveLessonProgress(status7_1);
        await progressRepository.saveLessonProgress(status7_2);
        await progressRepository.saveLessonProgress(status7_3);
        await provider.refreshLessonProgress('phase2_lesson7_1');
        await provider.refreshLessonProgress('phase2_lesson7_2');
        await provider.refreshLessonProgress('phase2_lesson7_3');

        expect(provider.isLessonUnlocked('phase2_lesson8_1'), true);
      });
    });

    group('Unlock Logic for All 25 Phase 2 Lessons', () {
      test('All Phase 2 lessons are locked when Phase 2 is locked', () async {
        // Phase 2 is locked by default
        await storageService.setBool('phase1FinalTestPassed', false);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // All 25 Phase 2 lessons
        final allPhase2Lessons = [
          'phase2_lesson7_1', 'phase2_lesson7_2', 'phase2_lesson7_3',
          'phase2_lesson8_1', 'phase2_lesson8_2', 'phase2_lesson8_3', 'phase2_lesson8_4',
          'phase2_lesson9_1', 'phase2_lesson9_2', 'phase2_lesson9_3', 'phase2_lesson9_4', 'phase2_lesson9_5',
          'phase2_lesson10_1', 'phase2_lesson10_2', 'phase2_lesson10_3', 'phase2_lesson10_4', 'phase2_lesson10_5',
          'phase2_lesson11_1', 'phase2_lesson11_2', 'phase2_lesson11_3', 'phase2_lesson11_4', 'phase2_lesson11_5',
        ];

        for (final lessonId in allPhase2Lessons) {
          expect(provider.isLessonUnlocked(lessonId), false,
              reason: '$lessonId should be locked when Phase 2 is locked');
        }
      });

      test('Sequential unlocking works for all Unit 8 lessons', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all Unit 7 lessons to unlock Unit 8
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_1');
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_2');
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_3');

        // Lesson 8.1 should be unlocked
        expect(provider.isLessonUnlocked('phase2_lesson8_1'), true);
        expect(provider.isLessonUnlocked('phase2_lesson8_2'), false);

        // Master 8.1, then 8.2 should unlock
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_1');
        expect(provider.isLessonUnlocked('phase2_lesson8_2'), true);
        expect(provider.isLessonUnlocked('phase2_lesson8_3'), false);

        // Master 8.2, then 8.3 should unlock
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_2');
        expect(provider.isLessonUnlocked('phase2_lesson8_3'), true);
        expect(provider.isLessonUnlocked('phase2_lesson8_4'), false);

        // Master 8.3, then 8.4 should unlock
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_3');
        expect(provider.isLessonUnlocked('phase2_lesson8_4'), true);
      });

      test('Cross-unit unlocking works from Unit 8 to Unit 9', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all Unit 7 and Unit 8 lessons
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_1');
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_2');
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_3');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_1');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_2');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_3');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_4');

        // Lesson 9.1 should be unlocked
        expect(provider.isLessonUnlocked('phase2_lesson9_1'), true);
        expect(provider.isLessonUnlocked('phase2_lesson9_2'), false);
      });

      test('Sequential unlocking works for all Unit 9 lessons', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all Unit 7 and Unit 8 lessons
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_1');
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_2');
        await _masterLesson(progressRepository, provider, 'phase2_lesson7_3');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_1');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_2');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_3');
        await _masterLesson(progressRepository, provider, 'phase2_lesson8_4');

        // Test Unit 9 sequential unlocking
        expect(provider.isLessonUnlocked('phase2_lesson9_1'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson9_1');
        expect(provider.isLessonUnlocked('phase2_lesson9_2'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson9_2');
        expect(provider.isLessonUnlocked('phase2_lesson9_3'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson9_3');
        expect(provider.isLessonUnlocked('phase2_lesson9_4'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson9_4');
        expect(provider.isLessonUnlocked('phase2_lesson9_5'), true);
      });

      test('Cross-unit unlocking works from Unit 9 to Unit 10', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all Unit 7, 8, and 9 lessons
        await _masterAllLessonsUpTo(progressRepository, provider, 'phase2_lesson9_5');

        // Lesson 10.1 should be unlocked
        expect(provider.isLessonUnlocked('phase2_lesson10_1'), true);
        expect(provider.isLessonUnlocked('phase2_lesson10_2'), false);
      });

      test('Sequential unlocking works for all Unit 10 lessons', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all lessons up to Unit 9
        await _masterAllLessonsUpTo(progressRepository, provider, 'phase2_lesson9_5');

        // Test Unit 10 sequential unlocking
        expect(provider.isLessonUnlocked('phase2_lesson10_1'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson10_1');
        expect(provider.isLessonUnlocked('phase2_lesson10_2'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson10_2');
        expect(provider.isLessonUnlocked('phase2_lesson10_3'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson10_3');
        expect(provider.isLessonUnlocked('phase2_lesson10_4'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson10_4');
        expect(provider.isLessonUnlocked('phase2_lesson10_5'), true);
      });

      test('Cross-unit unlocking works from Unit 10 to Unit 11', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all Unit 7, 8, 9, and 10 lessons
        await _masterAllLessonsUpTo(progressRepository, provider, 'phase2_lesson10_5');

        // Lesson 11.1 should be unlocked
        expect(provider.isLessonUnlocked('phase2_lesson11_1'), true);
        expect(provider.isLessonUnlocked('phase2_lesson11_2'), false);
      });

      test('Sequential unlocking works for all Unit 11 lessons', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // Master all lessons up to Unit 10
        await _masterAllLessonsUpTo(progressRepository, provider, 'phase2_lesson10_5');

        // Test Unit 11 sequential unlocking
        expect(provider.isLessonUnlocked('phase2_lesson11_1'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson11_1');
        expect(provider.isLessonUnlocked('phase2_lesson11_2'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson11_2');
        expect(provider.isLessonUnlocked('phase2_lesson11_3'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson11_3');
        expect(provider.isLessonUnlocked('phase2_lesson11_4'), true);
        
        await _masterLesson(progressRepository, provider, 'phase2_lesson11_4');
        expect(provider.isLessonUnlocked('phase2_lesson11_5'), true);
      });

      test('Complete Phase 2 progression from start to finish', () async {
        // Unlock Phase 2
        await storageService.setBool('phase1FinalTestPassed', true);
        
        final provider = ProgressProvider(
          progressRepo: progressRepository,
          lessonRepo: lessonRepository,
          storageService: storageService,
        );

        // All 25 Phase 2 lessons in order
        final allPhase2Lessons = [
          'phase2_lesson7_1', 'phase2_lesson7_2', 'phase2_lesson7_3',
          'phase2_lesson8_1', 'phase2_lesson8_2', 'phase2_lesson8_3', 'phase2_lesson8_4',
          'phase2_lesson9_1', 'phase2_lesson9_2', 'phase2_lesson9_3', 'phase2_lesson9_4', 'phase2_lesson9_5',
          'phase2_lesson10_1', 'phase2_lesson10_2', 'phase2_lesson10_3', 'phase2_lesson10_4', 'phase2_lesson10_5',
          'phase2_lesson11_1', 'phase2_lesson11_2', 'phase2_lesson11_3', 'phase2_lesson11_4', 'phase2_lesson11_5',
        ];

        // First lesson should be unlocked
        expect(provider.isLessonUnlocked(allPhase2Lessons[0]), true);

        // Master each lesson and verify the next one unlocks
        for (int i = 0; i < allPhase2Lessons.length - 1; i++) {
          final currentLesson = allPhase2Lessons[i];
          final nextLesson = allPhase2Lessons[i + 1];

          // Next lesson should be locked before mastering current
          expect(provider.isLessonUnlocked(nextLesson), false,
              reason: '$nextLesson should be locked before mastering $currentLesson');

          // Master current lesson
          await _masterLesson(progressRepository, provider, currentLesson);

          // Next lesson should now be unlocked
          expect(provider.isLessonUnlocked(nextLesson), true,
              reason: '$nextLesson should be unlocked after mastering $currentLesson');
        }
      });
    });
  });
}

/// Helper function to master a lesson
Future<void> _masterLesson(
  ProgressRepository repo,
  ProgressProvider provider,
  String lessonId,
) async {
  final status = UserLessonStatus(
    lessonId: lessonId,
    isMastered: true,
    masteryBestScore: 0.85,
  );
  await repo.saveLessonProgress(status);
  await provider.refreshLessonProgress(lessonId);
}

/// Helper function to master all lessons up to and including a specific lesson
Future<void> _masterAllLessonsUpTo(
  ProgressRepository repo,
  ProgressProvider provider,
  String upToLessonId,
) async {
  final allPhase2Lessons = [
    'phase2_lesson7_1', 'phase2_lesson7_2', 'phase2_lesson7_3',
    'phase2_lesson8_1', 'phase2_lesson8_2', 'phase2_lesson8_3', 'phase2_lesson8_4',
    'phase2_lesson9_1', 'phase2_lesson9_2', 'phase2_lesson9_3', 'phase2_lesson9_4', 'phase2_lesson9_5',
    'phase2_lesson10_1', 'phase2_lesson10_2', 'phase2_lesson10_3', 'phase2_lesson10_4', 'phase2_lesson10_5',
    'phase2_lesson11_1', 'phase2_lesson11_2', 'phase2_lesson11_3', 'phase2_lesson11_4', 'phase2_lesson11_5',
  ];

  for (final lessonId in allPhase2Lessons) {
    await _masterLesson(repo, provider, lessonId);
    if (lessonId == upToLessonId) break;
  }
}
