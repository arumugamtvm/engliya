import 'package:flutter/material.dart';
import '../features/onboarding/services/onboarding_service.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import 'routes.dart';
import 'theme.dart';

class EngliyaApp extends StatefulWidget {
  final OnboardingService onboardingService;

  const EngliyaApp({
    super.key,
    required this.onboardingService,
  });

  @override
  State<EngliyaApp> createState() => _EngliyaAppState();
}

class _EngliyaAppState extends State<EngliyaApp> {
  bool _isLoading = true;
  String _initialRoute = AppRoutes.onboarding;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    try {
      final hasCompletedOnboarding =
          await widget.onboardingService.hasCompletedOnboarding();

      setState(() {
        _initialRoute =
            hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding;
        _isLoading = false;
      });
    } catch (e) {
      // Default to onboarding on error
      setState(() {
        _initialRoute = AppRoutes.onboarding;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Determine which screen to show based on initial route
    Widget homeWidget;
    if (_initialRoute == AppRoutes.home) {
      homeWidget = const HomeScreen();
    } else {
      homeWidget = const OnboardingScreen();
    }

    return MaterialApp(
      title: 'Engliya',
      theme: AppTheme.lightTheme,
      home: homeWidget,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      // Provide a fallback route builder
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }
}
