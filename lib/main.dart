import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/di/service_container.dart';
import 'core/logging/app_logger.dart';
import 'features/learn/presentation/providers/lesson_provider.dart';
import 'features/learn/presentation/providers/progress_provider.dart';

final GlobalKey<_AppLifecycleManagerState> _appLifecycleKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ServiceContainer.instance;
  await container.initialize();

  runApp(
    MultiProvider(
      providers: container.providers,
      child: AppLifecycleManager(
        key: _appLifecycleKey,
        child: EngliyaApp(onboardingService: container.onboardingService),
      ),
    ),
  );
}

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
  static const _tag = 'AppLifecycle';

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

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _saveProgressOnPause();
        break;
      case AppLifecycleState.resumed:
        _reloadProgressOnResume();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _saveProgressOnPause() async {
    try {
      final lessonProvider = context.read<LessonProvider>();
      await lessonProvider.saveProgress();
      AppLogger.debug('Progress saved on app pause', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error saving progress on pause',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _reloadProgressOnResume() async {
    try {
      final progressProvider = context.read<ProgressProvider>();
      await progressProvider.reload();
      AppLogger.debug('Progress reloaded on app resume', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error reloading progress on resume',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
