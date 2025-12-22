import 'package:flutter/foundation.dart';

@immutable
sealed class RouteArguments {
  const RouteArguments();
}

@immutable
final class LessonRouteArgs extends RouteArguments {
  final String lessonId;
  
  const LessonRouteArgs({required this.lessonId});
}

@immutable
final class UnitLessonListArgs extends RouteArguments {
  final String unitId;
  final String? unitTitle;
  
  const UnitLessonListArgs({
    required this.unitId,
    this.unitTitle,
  });
}

@immutable
final class TestResultArgs<T> extends RouteArguments {
  final T result;
  
  const TestResultArgs({required this.result});
}

@immutable
final class TestReviewArgs<T> extends RouteArguments {
  final List<T> incorrectAnswers;
  
  const TestReviewArgs({required this.incorrectAnswers});
}

@immutable
final class AIChatArgs extends RouteArguments {
  final String? lessonContext;
  final String? initialQuestion;
  
  const AIChatArgs({
    this.lessonContext,
    this.initialQuestion,
  });
}

class RouteArgumentsParser {
  static T? parse<T extends RouteArguments>(Object? arguments) {
    if (arguments == null) return null;
    if (arguments is T) return arguments;
    
    if (arguments is Map<String, dynamic>) {
      return _parseFromMap<T>(arguments);
    }
    
    return null;
  }

  static T? _parseFromMap<T extends RouteArguments>(Map<String, dynamic> map) {
    if (T == LessonRouteArgs && map.containsKey('lessonId')) {
      return LessonRouteArgs(lessonId: map['lessonId'] as String) as T;
    }
    
    if (T == UnitLessonListArgs && map.containsKey('unitId')) {
      return UnitLessonListArgs(
        unitId: map['unitId'] as String,
        unitTitle: map['unitTitle'] as String?,
      ) as T;
    }
    
    if (T == AIChatArgs) {
      return AIChatArgs(
        lessonContext: map['lessonContext'] as String?,
        initialQuestion: map['initialQuestion'] as String?,
      ) as T;
    }
    
    return null;
  }

  static String? parseLessonId(Object? arguments) {
    if (arguments == null) return null;
    if (arguments is String) return arguments;
    if (arguments is LessonRouteArgs) return arguments.lessonId;
    if (arguments is Map<String, dynamic>) {
      return arguments['lessonId'] as String?;
    }
    return null;
  }

  static (String?, String?) parseUnitArgs(Object? arguments) {
    if (arguments == null) return (null, null);
    if (arguments is UnitLessonListArgs) {
      return (arguments.unitId, arguments.unitTitle);
    }
    if (arguments is Map<String, dynamic>) {
      return (
        arguments['unitId'] as String?,
        arguments['unitTitle'] as String?,
      );
    }
    return (null, null);
  }
}
