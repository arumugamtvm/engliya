import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engliya/features/onboarding/data/models/user_level.dart';
import 'package:engliya/features/onboarding/services/onboarding_service.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:engliya/features/learn/data/repositories/progress_repository.dart';
import 'package:engliya/features/learn/data/models/user_lesson_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Tests', () {
    late StorageService storageService;
    late OnboardingService onboardingService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      await storageService.init();
      onboardingService = OnboardingService(storageService: storageService);
      
      // Clear any existing data
      await onboardingService.clearOnboardingData();
    });

    test('UserLevel model serialization works correctly', () {
      final level = UserLevel.beginner;
      final json = level.toJson();
      final deserializedLevel = UserLevel.fromJson(json);

      expect(deserializedLevel.id, level.id);
      expect(deserializedLevel.name, level.name);
      expect(deserializedLevel.description, level.description);
    });

    test('OnboardingService saves and retrieves user level', () async {
      // Initially no level should be saved
      final initialLevel = await onboardingService.getUserLevel();
      expect(initialLevel, isNull);

      // Save a level
      await onboardingService.saveUserLevel(UserLevel.beginner);

      // Retrieve the level
      final savedLevel = await onboardingService.getUserLevel();
      expect(savedLevel, isNotNull);
      expect(savedLevel!.id, UserLevel.beginner.id);
    });

    test('OnboardingService tracks onboarding completion', () async {
      // Initially onboarding should not be complete
      final initialStatus = await onboardingService.hasCompletedOnboarding();
      expect(initialStatus, isFalse);

      // Mark onboarding as complete
      await onboardingService.markOnboardingComplete();

      // Check status again
      final completedStatus = await onboardingService.hasCompletedOnboarding();
      expect(completedStatus, isTrue);
    });
  });

  group('Progress Persistence Tests', () {
    late StorageService storageService;
    late ProgressRepository progressRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      await storageService.init();
      progressRepository = ProgressRepository(storageService);
      
      // Clear any existing progress data
      await progressRepository.clearAllProgress();
    });

    test('Progress saves and loads correctly', () async {
      // Create a lesson status
      final status = UserLessonStatus(
        lessonId: 'phase1_lesson1',
        explainDone: true,
        examplesDone: true,
        listeningScore: 0.8,
        speakingScore: 0.75,
        quizBestScore: 0.9,
        masteryBestScore: 0.85,
        isMastered: true,
        lastAccessed: DateTime.now(),
      );

      // Save the progress
      await progressRepository.saveLessonProgress(status);

      // Load the progress
      final loadedStatus = await progressRepository.loadLessonProgress('phase1_lesson1');

      // Verify all fields match
      expect(loadedStatus, isNotNull);
      expect(loadedStatus!.lessonId, status.lessonId);
      expect(loadedStatus.explainDone, status.explainDone);
      expect(loadedStatus.examplesDone, status.examplesDone);
      expect(loadedStatus.listeningScore, status.listeningScore);
      expect(loadedStatus.speakingScore, status.speakingScore);
      expect(loadedStatus.quizBestScore, status.quizBestScore);
      expect(loadedStatus.masteryBestScore, status.masteryBestScore);
      expect(loadedStatus.isMastered, status.isMastered);
      expect(loadedStatus.lastAccessed, isNotNull);
    });

    test('Progress persists across repository instances', () async {
      // Create and save progress with first repository instance
      final status = UserLessonStatus(
        lessonId: 'phase1_lesson2',
        explainDone: true,
        examplesDone: false,
        listeningScore: 0.7,
        lastAccessed: DateTime.now(),
      );
      await progressRepository.saveLessonProgress(status);

      // Create a new repository instance (simulating app restart)
      final newRepository = ProgressRepository(storageService);

      // Load progress with new instance
      final loadedStatus = await newRepository.loadLessonProgress('phase1_lesson2');

      // Verify data persisted
      expect(loadedStatus, isNotNull);
      expect(loadedStatus!.lessonId, 'phase1_lesson2');
      expect(loadedStatus.explainDone, true);
      expect(loadedStatus.examplesDone, false);
      expect(loadedStatus.listeningScore, 0.7);
    });

    test('Last accessed lesson tracking works correctly', () async {
      final now = DateTime.now();
      
      // Create multiple lesson statuses with different access times
      final status1 = UserLessonStatus(
        lessonId: 'phase1_lesson1',
        lastAccessed: now.subtract(const Duration(hours: 2)),
      );
      final status2 = UserLessonStatus(
        lessonId: 'phase1_lesson2',
        lastAccessed: now.subtract(const Duration(hours: 1)),
      );
      final status3 = UserLessonStatus(
        lessonId: 'phase1_lesson3',
        lastAccessed: now, // Most recent
      );

      // Save all statuses
      await progressRepository.saveLessonProgress(status1);
      await progressRepository.saveLessonProgress(status2);
      await progressRepository.saveLessonProgress(status3);

      // Load all progress
      final allProgress = await progressRepository.loadAllProgress();

      // Find the most recently accessed lesson
      UserLessonStatus? lastAccessed;
      DateTime? latestTime;

      for (var status in allProgress.values) {
        if (status.lastAccessed != null) {
          if (latestTime == null || status.lastAccessed!.isAfter(latestTime)) {
            latestTime = status.lastAccessed;
            lastAccessed = status;
          }
        }
      }

      // Verify the most recent lesson is lesson3
      expect(lastAccessed, isNotNull);
      expect(lastAccessed!.lessonId, 'phase1_lesson3');
    });

    test('Progress updates correctly when lesson is mastered', () async {
      // Create initial progress
      final status = UserLessonStatus(
        lessonId: 'phase1_lesson1',
        explainDone: true,
        examplesDone: true,
        isMastered: false,
      );
      await progressRepository.saveLessonProgress(status);

      // Update to mastered
      status.masteryBestScore = 0.85;
      status.isMastered = true;
      await progressRepository.saveLessonProgress(status);

      // Load and verify
      final loadedStatus = await progressRepository.loadLessonProgress('phase1_lesson1');
      expect(loadedStatus!.isMastered, true);
      expect(loadedStatus.masteryBestScore, 0.85);
    });

    test('Multiple lessons progress is maintained independently', () async {
      // Create progress for multiple lessons
      final status1 = UserLessonStatus(
        lessonId: 'phase1_lesson1',
        explainDone: true,
        isMastered: true,
      );
      final status2 = UserLessonStatus(
        lessonId: 'phase1_lesson2',
        explainDone: true,
        examplesDone: true,
        isMastered: false,
      );
      final status3 = UserLessonStatus(
        lessonId: 'phase1_lesson3',
        explainDone: false,
        isMastered: false,
      );

      // Save all
      await progressRepository.saveLessonProgress(status1);
      await progressRepository.saveLessonProgress(status2);
      await progressRepository.saveLessonProgress(status3);

      // Load all and verify
      final allProgress = await progressRepository.loadAllProgress();
      expect(allProgress.length, 3);
      expect(allProgress['phase1_lesson1']!.isMastered, true);
      expect(allProgress['phase1_lesson2']!.isMastered, false);
      expect(allProgress['phase1_lesson2']!.examplesDone, true);
      expect(allProgress['phase1_lesson3']!.explainDone, false);
    });
  });
}
