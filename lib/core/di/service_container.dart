import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../services/local_storage/storage_service.dart';
import '../../features/onboarding/services/onboarding_service.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/learn/data/repositories/lesson_repository.dart';
import '../../features/learn/data/repositories/progress_repository.dart';
import '../../features/learn/data/repositories/test_repository_impl.dart';
import '../../features/learn/data/models/phase4_final_test_question.dart';
import '../../features/learn/data/models/phase4_test_result.dart';
import '../../features/learn/data/models/phase5_final_test_question.dart';
import '../../features/learn/data/models/phase5_test_result.dart';
import '../../features/learn/domain/repositories/test_repository.dart';
import '../../features/learn/services/audio_service.dart';
import '../../features/learn/services/mastery_service.dart';
import '../../features/learn/services/final_test_service.dart';
import '../../features/learn/services/debug_service.dart';
import '../../features/learn/services/gating_service.dart';
import '../../features/learn/presentation/providers/lesson_provider.dart';
import '../../features/learn/presentation/providers/progress_provider.dart';
import '../../features/learn/presentation/providers/final_test_provider.dart';
import '../../features/learn/presentation/providers/debug_provider.dart';
import '../../features/home/services/home_service.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../logging/app_logger.dart';

class ServiceContainer {
  static final ServiceContainer _instance = ServiceContainer._internal();
  factory ServiceContainer() => _instance;
  ServiceContainer._internal();

  static ServiceContainer get instance => _instance;

  late final StorageService _storageService;
  late final OnboardingService _onboardingService;
  late final LessonRepository _lessonRepository;
  late final ProgressRepository _progressRepository;
  late final TestRepository _testRepository;
  late final AudioService _audioService;
  late final MasteryService _masteryService;
  late final DebugService _debugService;
  late final GatingService _gatingService;
  late final HomeService _homeService;
  late final FinalTestService<
    Phase4FinalTestQuestion,
    SpeakingResult,
    Phase4TestResult
  >
  _phase4FinalTestService;
  late final FinalTestService<
    Phase5FinalTestQuestion,
    Phase5SpeakingResult,
    Phase5TestResult
  >
  _phase5FinalTestService;
  late final ProgressProvider _progressProvider;

  bool _isInitialized = false;

  StorageService get storageService => _storageService;
  OnboardingService get onboardingService => _onboardingService;
  LessonRepository get lessonRepository => _lessonRepository;
  ProgressRepository get progressRepository => _progressRepository;
  TestRepository get testRepository => _testRepository;
  AudioService get audioService => _audioService;
  MasteryService get masteryService => _masteryService;
  DebugService get debugService => _debugService;
  GatingService get gatingService => _gatingService;
  HomeService get homeService => _homeService;
  ProgressProvider get progressProvider => _progressProvider;

  Future<void> initialize() async {
    if (_isInitialized) return;

    AppLogger.info('Initializing service container...', tag: 'DI');

    _storageService = StorageService();
    await _storageService.init();
    AppLogger.debug('Storage service initialized', tag: 'DI');

    _onboardingService = OnboardingService(storageService: _storageService);
    _lessonRepository = LessonRepository();
    _progressRepository = ProgressRepository(_storageService);
    _testRepository = TestRepositoryImpl(
      lessonRepository: _lessonRepository,
      storageService: _storageService,
    );

    _audioService = AudioService();
    await _audioService.init();
    AppLogger.debug('Audio service initialized', tag: 'DI');

    _masteryService = MasteryService();

    _debugService = DebugService(
      storageService: _storageService,
      progressRepository: _progressRepository,
    );

    _gatingService = GatingService(
      storageService: _storageService,
      progressRepository: _progressRepository,
    );

    _homeService = HomeService(
      lessonRepo: _lessonRepository,
      progressRepo: _progressRepository,
      storageService: _storageService,
      gatingService: _gatingService,
    );

    _phase4FinalTestService = FinalTestService.phase4(
      storageService: _storageService,
      progressRepository: _progressRepository,
      debugService: _debugService,
      lessonRepository: _lessonRepository,
    );
    _phase5FinalTestService = FinalTestService.phase5(
      storageService: _storageService,
      progressRepository: _progressRepository,
      debugService: _debugService,
      lessonRepository: _lessonRepository,
    );

    _progressProvider = ProgressProvider(
      progressRepo: _progressRepository,
      lessonRepo: _lessonRepository,
      storageService: _storageService,
      gatingService: _gatingService,
    );

    await _progressProvider.loadAllData();
    AppLogger.debug('Progress data loaded', tag: 'DI');

    _isInitialized = true;
    AppLogger.info('Service container initialized successfully', tag: 'DI');
  }

  List<SingleChildWidget> get providers => [
    Provider<StorageService>.value(value: _storageService),
    Provider<OnboardingService>.value(value: _onboardingService),
    Provider<LessonRepository>.value(value: _lessonRepository),
    Provider<ProgressRepository>.value(value: _progressRepository),
    Provider<TestRepository>.value(value: _testRepository),
    Provider<AudioService>.value(value: _audioService),
    Provider<MasteryService>.value(value: _masteryService),
    Provider<HomeService>.value(value: _homeService),
    Provider<
      FinalTestService<
        Phase4FinalTestQuestion,
        SpeakingResult,
        Phase4TestResult
      >
    >.value(value: _phase4FinalTestService),
    Provider<
      FinalTestService<
        Phase5FinalTestQuestion,
        Phase5SpeakingResult,
        Phase5TestResult
      >
    >.value(value: _phase5FinalTestService),
    Provider<DebugService>.value(value: _debugService),
    Provider<GatingService>.value(value: _gatingService),
    ChangeNotifierProvider(
      create: (_) => OnboardingProvider(onboardingService: _onboardingService),
    ),
    ChangeNotifierProvider.value(value: _progressProvider),
    ChangeNotifierProvider(
      create: (_) => LessonProvider(
        lessonRepo: _lessonRepository,
        progressRepo: _progressRepository,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => HomeProvider(homeService: _homeService),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          FinalTestProvider<
            Phase4FinalTestQuestion,
            SpeakingResult,
            Phase4TestResult
          >(
            testService: _phase4FinalTestService,
            gatingService: _gatingService,
          ),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          FinalTestProvider<
            Phase5FinalTestQuestion,
            Phase5SpeakingResult,
            Phase5TestResult
          >(
            testService: _phase5FinalTestService,
            gatingService: _gatingService,
          ),
    ),
    ChangeNotifierProvider(
      create: (_) => DebugProvider(debugService: _debugService),
    ),
  ];

  void dispose() {
    _isInitialized = false;
    AppLogger.info('Service container disposed', tag: 'DI');
  }
}
