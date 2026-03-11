import 'tab_validation_result.dart';

class LessonValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, double> qualityScores;
  final bool fallbackEligible;

  const LessonValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.qualityScores = const {},
    this.fallbackEligible = false,
  });

  const LessonValidationResult.valid({
    this.warnings = const [],
    this.qualityScores = const {},
  }) : isValid = true,
       errors = const [],
       fallbackEligible = false;

  const LessonValidationResult.invalid({
    required this.errors,
    this.warnings = const [],
    this.qualityScores = const {},
    this.fallbackEligible = true,
  }) : isValid = false;

  ValidationSeverity get severity {
    if (isValid) return ValidationSeverity.info;
    return fallbackEligible
        ? ValidationSeverity.warning
        : ValidationSeverity.error;
  }
}
