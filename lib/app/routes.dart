import 'package:flutter/material.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/ai_tutor/ai_tutor.dart';
import '../features/learn/presentation/screens/phase1_unit_screen.dart';
import '../features/learn/presentation/screens/phase2_unit_screen.dart';
import '../features/learn/presentation/screens/phase2_lesson_list_screen.dart';
import '../features/learn/presentation/screens/phase3_unit_screen.dart';
import '../features/learn/presentation/screens/phase3_lesson_list_screen.dart';
import '../features/learn/presentation/screens/lesson_screen.dart';
import '../features/learn/presentation/screens/phase1_final_test_screen.dart';
import '../features/learn/presentation/screens/phase1_final_test_result_screen.dart';
import '../features/learn/presentation/screens/phase1_final_test_review_screen.dart';
import '../features/learn/presentation/screens/phase2_final_test_screen.dart';
import '../features/learn/presentation/screens/phase2_final_test_result_screen.dart';
import '../features/learn/presentation/screens/phase2_final_test_review_screen.dart';
import '../features/learn/presentation/screens/phase3_final_test_screen.dart';
import '../features/learn/presentation/screens/phase3_final_test_result_screen.dart';
import '../features/learn/presentation/screens/phase3_final_test_review_screen.dart';
import '../features/learn/presentation/screens/debug_screen.dart';
import '../features/learn/presentation/screens/phase4_unit_screen.dart';
import '../features/learn/presentation/screens/phase4_lesson_list_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/learn/data/models/phase3_test_result.dart';
import '../features/learn/data/models/test_result.dart';
import '../features/learn/data/models/phase2_test_result.dart';
import '../features/learn/data/models/incorrect_answer.dart';
import '../core/utils/animations.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String phase1Unit = '/phase1-unit';
  static const String phase2Unit = '/phase2-unit';
  static const String phase2LessonList = '/phase2-lesson-list';
  static const String phase3Unit = '/phase3';
  static const String phase3LessonList = '/phase3/unit/:unitId';
  static const String phase3FinalTest = '/phase3/finalTest';
  static const String lesson = '/lesson';
  static const String phase1FinalTest = '/phase1/finalTest';
  static const String phase1FinalTestResult = '/phase1/finalTest/result';
  static const String phase1FinalTestReview = '/phase1/finalTest/review';
  static const String phase2FinalTest = '/phase2/finalTest';
  static const String phase2FinalTestResult = '/phase2/finalTest/result';
  static const String phase2FinalTestReview = '/phase2/finalTest/review';
  static const String phase3FinalTestResult = '/phase3/finalTest/result';
  static const String phase3FinalTestReview = '/phase3/finalTest/review';
  static const String progress = '/progress';
  static const String aiChat = '/ai-chat';
  static const String debug = '/debug';
  static const String phase4Unit = '/phase4';
  static const String phase4LessonList = '/phase4/unit/:unitId';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle dynamic Phase 3 unit routes first
    if (settings.name?.startsWith('/phase3/unit/') == true && settings.name != phase3LessonList) {
      final args = settings.arguments as Map<String, dynamic>?;
      if (args != null && args['unitId'] != null) {
        return _buildRoute(Phase3LessonListScreen(unitId: args['unitId'] as String), settings);
      }
    }

    // Handle dynamic Phase 4 unit routes
    if (settings.name?.startsWith('/phase4/unit/') == true && settings.name != phase4LessonList) {
      final args = settings.arguments as Map<String, dynamic>?;
      if (args != null && args['unitId'] != null) {
        return _buildRoute(
          Phase4LessonListScreen(
            unitId: args['unitId'] as String,
            unitTitle: args['unitTitle'] as String?,
          ),
          settings,
        );
      }
    }

    switch (settings.name) {
      case '/':
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case home:
        return _buildRoute(const HomeScreen(), settings);
      case phase1Unit:
        return _buildRoute(const Phase1UnitScreen(), settings);
      case phase2Unit:
        return _buildRoute(const Phase2UnitScreen(), settings);
      case phase2LessonList:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['unitId'] == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Unit ID not provided'))), settings);
        }
        return _buildRoute(Phase2LessonListScreen(unitId: args['unitId'] as String), settings);
      case phase3Unit:
        return _buildRoute(const Phase3UnitScreen(), settings);
      case phase3LessonList:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['unitId'] == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Unit ID not provided'))), settings);
        }
        return _buildRoute(Phase3LessonListScreen(unitId: args['unitId'] as String), settings);
      case phase3FinalTest:
        return _buildSlideRoute(const Phase3FinalTestScreen(), settings);
      case phase3FinalTestResult:
        final result = settings.arguments as Phase3TestResult?;
        if (result == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Test result not provided'))), settings);
        }
        return _buildFadeRoute(Phase3FinalTestResultScreen(testResult: result), settings);
      case phase3FinalTestReview:
        final answers = settings.arguments as List<IncorrectAnswer>?;
        if (answers == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Incorrect answers not provided'))), settings);
        }
        return _buildSlideRoute(Phase3FinalTestReviewScreen(incorrectAnswers: answers), settings);
      case lesson:
        final lessonId = settings.arguments as String?;
        if (lessonId == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Lesson ID not provided'))), settings);
        }
        return _buildRoute(LessonScreen(lessonId: lessonId), settings);
      case phase1FinalTest:
        return _buildRoute(const Phase1FinalTestScreen(), settings);
      case phase1FinalTestResult:
        final result = settings.arguments as TestResult?;
        if (result == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Test result not provided'))), settings);
        }
        return _buildRoute(Phase1FinalTestResultScreen(testResult: result), settings);
      case phase1FinalTestReview:
        final answers = settings.arguments as List<IncorrectAnswer>?;
        if (answers == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Incorrect answers not provided'))), settings);
        }
        return _buildRoute(Phase1FinalTestReviewScreen(incorrectAnswers: answers), settings);
      case phase2FinalTest:
        return _buildSlideRoute(const Phase2FinalTestScreen(), settings);
      case phase2FinalTestResult:
        final result = settings.arguments as Phase2TestResult?;
        if (result == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Test result not provided'))), settings);
        }
        return _buildFadeRoute(Phase2FinalTestResultScreen(testResult: result), settings);
      case phase2FinalTestReview:
        final answers = settings.arguments as List<IncorrectAnswer>?;
        if (answers == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Incorrect answers not provided'))), settings);
        }
        return _buildSlideRoute(Phase2FinalTestReviewScreen(incorrectAnswers: answers), settings);
      case progress:
        return _buildRoute(const ProgressScreen(), settings);
      case aiChat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildSlideRoute(AIChatScreen(lessonContext: args?['lessonContext'] as String?, initialQuestion: args?['initialQuestion'] as String?), settings);
      case debug:
        return _buildSlideRoute(const DebugScreen(), settings);
      case phase4Unit:
        return _buildRoute(const Phase4UnitScreen(), settings);
      case phase4LessonList:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['unitId'] == null) {
          return _buildRoute(const Scaffold(body: Center(child: Text('Error: Unit ID not provided'))), settings);
        }
        return _buildRoute(
          Phase4LessonListScreen(
            unitId: args['unitId'] as String,
            unitTitle: args['unitTitle'] as String?,
          ),
          settings,
        );
      default:
        return _buildRoute(const OnboardingScreen(), settings);
    }
  }

  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> _buildSlideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut)).animate(animation),
          child: child,
        );
      },
      transitionDuration: AppAnimations.medium,
    );
  }

  static Route<dynamic> _buildFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      transitionDuration: AppAnimations.normal,
    );
  }
}
