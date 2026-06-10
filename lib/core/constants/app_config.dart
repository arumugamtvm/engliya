import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String version = '1.0.0';
  static const int buildNumber = 1;
  static const String appName = 'Engliya';

  /// Single source of truth for developer bypass mode.
  /// When true, all phase/lesson/tab/test gating is bypassed.
  /// Must remain false for production builds so learners progress
  /// through phases in the intended order. Runtime debug unlocking is
  /// available through the in-app debug screen in debug builds only.
  static const bool devMode = false;

  static bool get isDevelopmentMode => kDebugMode;
  static bool get isProductionMode => kReleaseMode;
  static bool get isProfileMode => kProfileMode;

  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 24);

  static const String defaultLanguageCode = 'en-US';
  static const String fallbackLanguageCode = 'en';

  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);
}
