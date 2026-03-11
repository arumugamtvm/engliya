enum ValidationSeverity {
  info,
  warning,
  error,
}

class TabValidationResult {
  final bool isValid;
  final String message;
  final ValidationSeverity severity;
  final String actionLabel;

  const TabValidationResult({
    required this.isValid,
    required this.message,
    this.severity = ValidationSeverity.info,
    this.actionLabel = 'Continue',
  });

  const TabValidationResult.valid({
    this.message = 'Looks good.',
    this.actionLabel = 'Continue',
  })  : isValid = true,
        severity = ValidationSeverity.info;

  const TabValidationResult.invalid({
    required this.message,
    this.severity = ValidationSeverity.warning,
    this.actionLabel = 'Complete required steps',
  }) : isValid = false;
}
