class AIResponseValidator {
  static const int _maxPromptLength = 600;

  String sanitizeStudentPrompt(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw AIResponseValidationException('Please enter a question first.');
    }
    if (trimmed.length > _maxPromptLength) {
      return trimmed.substring(0, _maxPromptLength);
    }
    return trimmed;
  }

  String validateTutorResponse(String output, {String? lessonContext}) {
    final cleaned = output.trim();
    if (cleaned.isEmpty) {
      throw AIResponseValidationException('Tutor response was empty.');
    }
    if (lessonContext != null &&
        lessonContext.trim().isNotEmpty &&
        !_looksEducational(cleaned)) {
      throw AIResponseValidationException(
        'Tutor response did not match the lesson-learning context.',
      );
    }
    return cleaned;
  }

  String safeFallbackResponse({String? lessonContext}) {
    final contextLine = (lessonContext == null || lessonContext.trim().isEmpty)
        ? ''
        : 'Topic: ${lessonContext.trim()}\n';
    return '$contextLine'
        'Let us practice useful English step by step.\n'
        '1. Write one simple sentence.\n'
        '2. I will correct it and explain why.\n'
        '3. Then we will convert it to fluent spoken English.';
  }

  bool _looksEducational(String output) {
    final lower = output.toLowerCase();
    return lower.contains('english') ||
        lower.contains('sentence') ||
        lower.contains('grammar') ||
        lower.contains('example') ||
        lower.contains('speak') ||
        lower.contains('vocabulary');
  }
}

class AIResponseValidationException implements Exception {
  final String message;
  AIResponseValidationException(this.message);

  @override
  String toString() => 'AIResponseValidationException: $message';
}
