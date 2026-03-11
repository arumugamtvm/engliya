import 'package:engliya/services/ai/ai_response_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIResponseValidator', () {
    final validator = AIResponseValidator();

    test('rejects empty prompt', () {
      expect(
        () => validator.sanitizeStudentPrompt('   '),
        throwsA(isA<AIResponseValidationException>()),
      );
    });

    test(
      'returns fallback-friendly error for non-educational context response',
      () {
        expect(
          () => validator.validateTutorResponse(
            'ok',
            lessonContext: 'Present perfect tense',
          ),
          throwsA(isA<AIResponseValidationException>()),
        );
      },
    );
  });
}
