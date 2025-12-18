/// Shared exception classes for test services
/// Used by both Phase 1 and Phase 2 final test services

/// Custom exception for test generation errors
class TestGenerationException implements Exception {
  final String message;

  TestGenerationException(this.message);

  @override
  String toString() => 'TestGenerationException: $message';
}

/// Custom exception for test storage errors
class TestStorageException implements Exception {
  final String message;

  TestStorageException(this.message);

  @override
  String toString() => 'TestStorageException: $message';
}

/// Custom exception for insufficient questions
class InsufficientQuestionsException implements Exception {
  final String message;

  InsufficientQuestionsException(this.message);

  @override
  String toString() => 'InsufficientQuestionsException: $message';
}
