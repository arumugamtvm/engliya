import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../services/local_storage/storage_service.dart';
import '../../features/onboarding/services/onboarding_service.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/learn/data/repositories/lesson_repository.dart';
import '../../features/learn/data/repositories/progress_repository.dart';
import '../../features/learn/services/audio_service.dart';
import '../../features/learn/services/mastery_service.dart';
import '../../features/learn/services/phase1_final_test_service.dart';
import '../../features/learn/services/phase2_final_test_service.dart';
import '../../features/learn/services/phase3_final_test_service.dart';
import '../../features/learn/services/phase4_final_test_service.dart';
import '../../features/learn/services/debug_service.dart';
import '../../features/learn/services/gating_service.dart';
import '../../features/learn/presentation/providers/lesson_provider.dart';
import '../../features/learn/presentation/providers/progress_provider.dart';
import '../../features/learn/presentation/providers/final_test_provider.dart';
import '../../features/learn/presentation/providers/phase2_unit_provider.dart';
import '../../features/learn/presentation/providers/phase2_final_test_provider.dart';
import '../../features/learn/presentation/providers/phase3_unit_provider.dart';
import '../../features/learn/presentation/providers/phase3_final_test_provider.dart';
import '../../features/learn/presentation/providers/phase4_unit_provider.dart';
import '../../features/learn/presentation/providers/phase4_final_test_provider.dart';
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
  late final AudioService _audioService;
  late final MasteryService _masteryService;
  late final DebugService _debugService;
  late final GatingService _gatingService;
  late final HomeService _homeService;
  late final Phase1FinalTestService _phase1FinalTestService;
  late final Phase2FinalTestService _phase2FinalTestService;
  late final Phase3FinalTestService _phase3FinalTestService;
  late final Phase4FinalTestService _phase4FinalTestService;
  late final ProgressProvider _progressProvider;

  bool _isInitialized = false;

  StorageService get storageService => _storageService;
  OnboardingService get onboardingService => _onboardingService;
  LessonRepository get lessonRepository => _lessonRepository;
  ProgressRepository get progressRepository => _progressRepository;
  AudioService get audioService => _audioService;
  MasteryService get masteryService => _masteryService;
  DebugService get debugService => _debugService;
  GatingService get gatingService => _gatingService;
  HomeService get homeService => _homeService;
  Phase1FinalTestService get phase1FinalTestService => _phase1FinalTestService;
  Phase2FinalTestService get phase2FinalTestService => _phase2FinalTestService;
  Phase3FinalTestService get phase3FinalTestService => _phase3FinalTestService;
  Phase4FinalTestService get phase4FinalTestService => _phase4FinalTestService;
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
      debugService: _debugService,
    );

    _homeService = HomeService(
      lessonRepo: _lessonRepository,
      progressRepo: _progressRepository,
      storageService: _storageService,
      gatingService: _gatingService,
    );

    _phase1FinalTestService = Phase1FinalTestService(
      lessonRepository: _lessonRepository,
      storageService: _storageService,
    );

    _phase2FinalTestService = Phase2FinalTestService(
      lessonRepository: _lessonRepository,
      storageService: _storageService,
      progressRepository: _progressRepository,
    );

    _phase3FinalTestService = Phase3FinalTestService(
      lessonRepository: _lessonRepository,
      storageService: _storageService,
      progressRepository: _progressRepository,
    );

    _phase4FinalTestService = Phase4FinalTestService(
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
    Provider<AudioService>.value(value: _audioService),
    Provider<MasteryService>.value(value: _masteryService),
    Provider<HomeService>.value(value: _homeService),
    Provider<Phase1FinalTestService>.value(value: _phase1FinalTestService),
    Provider<Phase2FinalTestService>.value(value: _phase2FinalTestService),
    Provider<Phase3FinalTestService>.value(value: _phase3FinalTestService),
    Provider<Phase4FinalTestService>.value(value: _phase4FinalTestService),
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
      create: (_) => FinalTestProvider(
        testService: _phase1FinalTestService,
        gatingService: _gatingService,
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => Phase2UnitProvider(context.read<ProgressProvider>()),
    ),
    ChangeNotifierProvider(
      create: (_) => Phase2FinalTestProvider(
        testService: _phase2FinalTestService,
        gatingService: _gatingService,
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => Phase3UnitProvider(context.read<ProgressProvider>()),
    ),
    ChangeNotifierProvider(
      create: (_) => Phase3FinalTestProvider(
        testService: _phase3FinalTestService,
        gatingService: _gatingService,
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => Phase4UnitProvider(context.read<ProgressProvider>()),
    ),
    ChangeNotifierProvider(
      create: (_) => Phase4FinalTestProvider(
        testService: _phase4FinalTestService,
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
