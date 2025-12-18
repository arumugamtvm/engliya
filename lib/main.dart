import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'services/local_storage/storage_service.dart';
import 'features/onboarding/services/onboarding_service.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/learn/data/repositories/lesson_repository.dart';
import 'features/learn/data/repositories/progress_repository.dart';
import 'features/learn/services/audio_service.dart';
import 'features/learn/services/mastery_service.dart';
import 'features/learn/services/phase1_final_test_service.dart';
import 'features/learn/services/phase2_final_test_service.dart';
import 'features/learn/services/phase3_final_test_service.dart';
import 'features/learn/services/debug_service.dart';
import 'features/learn/services/gating_service.dart';
import 'features/learn/presentation/providers/lesson_provider.dart';
import 'features/learn/presentation/providers/progress_provider.dart';
import 'features/learn/presentation/providers/final_test_provider.dart';
import 'features/learn/presentation/providers/phase2_unit_provider.dart';
import 'features/learn/presentation/providers/phase2_final_test_provider.dart';
import 'features/learn/presentation/providers/phase3_unit_provider.dart';
import 'features/learn/presentation/providers/phase3_final_test_provider.dart';
import 'features/learn/presentation/providers/phase4_unit_provider.dart';
import 'features/learn/presentation/providers/debug_provider.dart';
import 'features/home/services/home_service.dart';
import 'features/home/presentation/providers/home_provider.dart';

/// Global key for accessing app lifecycle state
final GlobalKey<_AppLifecycleManagerState> appLifecycleKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();

  // Initialize services
  final onboardingService = OnboardingService(storageService: storageService);
  final lessonRepository = LessonRepository();
  final progressRepository = ProgressRepository(storageService);
  final audioService = AudioService();
  await audioService.init();
  final masteryService = MasteryService();
  
  // Initialize debug and gating services
  // Requirements: 9.1, 12.1, 12.6, 12.7
  final debugService = DebugService(
    storageService: storageService,
    progressRepository: progressRepository,
  );
  final gatingService = GatingService(
    storageService: storageService,
    progressRepository: progressRepository,
    debugService: debugService,
  );
  
  final homeService = HomeService(
    lessonRepo: lessonRepository,
    progressRepo: progressRepository,
    storageService: storageService,
    gatingService: gatingService,
  );
  final phase1FinalTestService = Phase1FinalTestService(
    lessonRepository: lessonRepository,
    storageService: storageService,
  );
  final phase2FinalTestService = Phase2FinalTestService(
    lessonRepository: lessonRepository,
    storageService: storageService,
    progressRepository: progressRepository,
  );
  final phase3FinalTestService = Phase3FinalTestService(
    lessonRepository: lessonRepository,
    storageService: storageService,
    progressRepository: progressRepository,
  );

  // Create providers
  final progressProvider = ProgressProvider(
    progressRepo: progressRepository,
    lessonRepo: lessonRepository,
    storageService: storageService,
    gatingService: gatingService,
  );

  // Pre-load progress data on app startup
  await progressProvider.loadAllData();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<StorageService>.value(value: storageService),
        Provider<OnboardingService>.value(value: onboardingService),
        Provider<LessonRepository>.value(value: lessonRepository),
        Provider<ProgressRepository>.value(value: progressRepository),
        Provider<AudioService>.value(value: audioService),
        Provider<MasteryService>.value(value: masteryService),
        Provider<HomeService>.value(value: homeService),
        Provider<Phase1FinalTestService>.value(value: phase1FinalTestService),
        Provider<Phase2FinalTestService>.value(value: phase2FinalTestService),
        Provider<Phase3FinalTestService>.value(value: phase3FinalTestService),
        Provider<DebugService>.value(value: debugService),
        Provider<GatingService>.value(value: gatingService),

        // Providers
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(
            onboardingService: onboardingService,
          ),
        ),
        ChangeNotifierProvider.value(
          value: progressProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => LessonProvider(
            lessonRepo: lessonRepository,
            progressRepo: progressRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            homeService: homeService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FinalTestProvider(
            testService: phase1FinalTestService,
            gatingService: gatingService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Phase2UnitProvider(
            context.read<ProgressProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => Phase2FinalTestProvider(
            testService: phase2FinalTestService,
            gatingService: gatingService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Phase3UnitProvider(
            context.read<ProgressProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => Phase3FinalTestProvider(
            testService: phase3FinalTestService,
            gatingService: gatingService,
          ),
        ),
        // Phase 4 unit provider for fluency & pronunciation
        // Requirements: 10.1, 10.2
        ChangeNotifierProvider(
          create: (context) => Phase4UnitProvider(
            context.read<ProgressProvider>(),
          ),
        ),
        // Debug provider for debug mode management
        // Requirements: 9.1, 9.4, 9.5, 9.6
        ChangeNotifierProvider(
          create: (_) => DebugProvider(
            debugService: debugService,
          ),
        ),
      ],
      child: AppLifecycleManager(
        key: appLifecycleKey,
        child: EngliyaApp(onboardingService: onboardingService),
      ),
    ),
  );
}

/// Widget that manages app lifecycle events
/// Ensures progress is saved when app goes to background
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Save progress when app goes to background or is paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveProgressOnPause();
    }

    // Reload progress when app resumes
    if (state == AppLifecycleState.resumed) {
      _reloadProgressOnResume();
    }
  }

  /// Save current lesson progress when app is paused
  Future<void> _saveProgressOnPause() async {
    try {
      final lessonProvider = context.read<LessonProvider>();
      await lessonProvider.saveProgress();
      debugPrint('Progress saved on app pause');
    } catch (e) {
      debugPrint('Error saving progress on pause: $e');
    }
  }

  /// Reload progress data when app resumes
  Future<void> _reloadProgressOnResume() async {
    try {
      final progressProvider = context.read<ProgressProvider>();
      await progressProvider.reload();
      debugPrint('Progress reloaded on app resume');
    } catch (e) {
      debugPrint('Error reloading progress on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
