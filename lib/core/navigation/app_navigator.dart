import 'package:flutter/material.dart';
import 'route_arguments.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get _navigator => navigatorKey.currentState;

  static Future<T?>? push<T>(String routeName, {Object? arguments}) {
    return _navigator?.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? pushReplacement<T, TO>(String routeName, {Object? arguments}) {
    return _navigator?.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  static void pop<T>([T? result]) {
    _navigator?.pop<T>(result);
  }

  static void popUntil(String routeName) {
    _navigator?.popUntil(ModalRoute.withName(routeName));
  }

  static Future<T?>? pushAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    required String untilRoute,
  }) {
    return _navigator?.pushNamedAndRemoveUntil<T>(
      routeName,
      ModalRoute.withName(untilRoute),
      arguments: arguments,
    );
  }

  static Future<void>? toHome() {
    return _navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  static Future<void>? toLesson(String lessonId) {
    return push('/lesson', arguments: LessonRouteArgs(lessonId: lessonId));
  }

  static Future<void>? toPhase1Unit() => push('/phase1-unit');
  
  static Future<void>? toPhase2Unit() => push('/phase2-unit');
  
  static Future<void>? toPhase2LessonList(String unitId) {
    return push('/phase2-lesson-list', arguments: UnitLessonListArgs(unitId: unitId));
  }

  static Future<void>? toPhase3() => push('/phase3');

  static Future<void>? toPhase3LessonList(String unitId, {String? unitTitle}) {
    return push(
      '/phase3/unit/$unitId',
      arguments: UnitLessonListArgs(unitId: unitId, unitTitle: unitTitle),
    );
  }

  static Future<void>? toPhase4() => push('/phase4');

  static Future<void>? toPhase4LessonList(String unitId, {String? unitTitle}) {
    return push(
      '/phase4/unit/$unitId',
      arguments: UnitLessonListArgs(unitId: unitId, unitTitle: unitTitle),
    );
  }

  static Future<void>? toPhase1FinalTest() => push('/phase1/finalTest');
  
  static Future<void>? toPhase2FinalTest() => push('/phase2/finalTest');
  
  static Future<void>? toPhase3FinalTest() => push('/phase3/finalTest');
  
  static Future<void>? toPhase4FinalTest() => push('/phase4/finalTest');
  
  static Future<void>? toPhase5FinalTest() => push('/phase5/finalTest');

  static Future<void>? toTestResult<T>(String route, T result) {
    return pushReplacement(route, arguments: result);
  }

  static Future<void>? toTestReview<T>(String route, List<T> incorrectAnswers) {
    return push(route, arguments: incorrectAnswers);
  }

  static Future<void>? toProgress() => push('/progress');

  static Future<void>? toAIChat({String? lessonContext, String? initialQuestion}) {
    return push(
      '/ai-chat',
      arguments: AIChatArgs(
        lessonContext: lessonContext,
        initialQuestion: initialQuestion,
      ),
    );
  }

  static Future<void>? toDebug() => push('/debug');

  static bool canPop() => _navigator?.canPop() ?? false;
}
