import 'package:engliya/features/learn/data/models/lesson.dart';
import 'package:engliya/features/learn/services/lesson_content_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonContentValidator', () {
    final validator = LessonContentValidator();

    test('rejects invalid schema', () {
      final result = validator.validateSchema({'id': 'phase1_lesson1'});

      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);
    });

    test('accepts valid schema and pedagogy', () {
      final json = _validLessonJson();
      final schema = validator.validateSchema(json);
      expect(schema.isValid, isTrue);

      final lesson = Lesson.fromJson(json);
      final quality = validator.validatePedagogy(lesson);
      expect(quality.isValid, isTrue);
      expect((quality.qualityScores['overall'] ?? 0) > 0.35, isTrue);
    });
  });
}

Map<String, dynamic> _validLessonJson() {
  return {
    'id': 'phase1_lesson1',
    'order': 1,
    'unitId': 'phase1',
    'title': 'Greetings',
    'description': 'Learn basic greetings.',
    'level': 'beginner',
    'explain': {
      'en':
          'Greetings are polite words we use when meeting people in daily life and conversations.',
      'ta': 'வணக்கம் மற்றும் நலமா போன்ற சொற்களை பயன்படுத்தலாம்.',
    },
    'examples': [
      {
        'en': 'Hello, how are you?',
        'ta': 'வணக்கம், எப்படி இருக்கிறீர்கள்?',
        'audioId': 'a1',
      },
      {
        'en': 'Good morning, friends.',
        'ta': 'காலை வணக்கம் நண்பர்களே.',
        'audioId': 'a2',
      },
      {
        'en': 'Nice to meet you.',
        'ta': 'உங்களை சந்தித்ததில் மகிழ்ச்சி.',
        'audioId': 'a3',
      },
    ],
    'listeningQuestions': [
      {
        'audioText': 'Good morning, everyone.',
        'options': ['Morning greeting', 'Goodbye', 'Question', 'Order'],
        'correctIndex': 0,
      },
      {
        'audioText': 'How are you today?',
        'options': ['Asking health', 'Giving order', 'Saying bye', 'Thanks'],
        'correctIndex': 0,
      },
      {
        'audioText': 'Nice to meet you.',
        'options': ['Introduction', 'Apology', 'Farewell', 'Request'],
        'correctIndex': 0,
      },
    ],
    'speakSentences': [
      {'en': 'Good morning, teacher.', 'ta': 'காலை வணக்கம் ஆசிரியரே.'},
      {'en': 'Hello, I am Arun.', 'ta': 'வணக்கம், நான் அருண்.'},
      {'en': 'Nice to meet you.', 'ta': 'உங்களை சந்தித்ததில் மகிழ்ச்சி.'},
    ],
    'practiceQuestions': [
      {
        'type': 'mcq',
        'promptEn': 'Choose a greeting:',
        'options': ['Hello', 'Table', 'Book', 'Pen'],
        'correctIndex': 0,
      },
      {
        'type': 'ordering',
        'promptEn': 'Pick the best sequence:',
        'options': [
          'Greeting -> Name -> Question',
          'Question -> Greeting -> Exit',
          'Exit -> Name -> Greeting',
          'Name -> Exit -> Question',
        ],
        'correctIndex': 0,
      },
      {
        'type': 'rewrite',
        'promptEn': 'Choose the most polite rewrite:',
        'options': [
          'Hi.',
          'Good morning, how are you?',
          'Come fast.',
          'No talk.',
        ],
        'correctIndex': 1,
        'expectedAnswerEn': 'Good morning, how are you?',
      },
      {
        'type': 'mcq',
        'promptEn': 'Choose a polite greeting:',
        'options': ['Hi', 'Run', 'Jump', 'Eat'],
        'correctIndex': 0,
      },
      {
        'type': 'mcq',
        'promptEn': 'Best morning greeting?',
        'options': ['Good morning', 'Good night', 'Bye', 'Later'],
        'correctIndex': 0,
      },
      {
        'type': 'mcq',
        'promptEn': 'Greeting when meeting someone?',
        'options': ['Nice to meet you', 'Run', 'Stop', 'No'],
        'correctIndex': 0,
      },
      {
        'type': 'mcq',
        'promptEn': 'Which is polite?',
        'options': ['Hello sir', 'Give', 'Wait', 'Now'],
        'correctIndex': 0,
      },
    ],
    'masteryQuestions': [
      {
        'type': 'mcq',
        'promptEn': 'Formal greeting?',
        'options': ['Good evening', 'Yo', 'Hey', 'No'],
        'correctIndex': 0,
      },
      {
        'type': 'short_answer',
        'promptEn': 'Polite opening line?',
        'options': ['How are you?', 'Give me', 'No', 'Stop'],
        'correctIndex': 0,
        'expectedAnswerEn': 'How are you?',
      },
      {
        'type': 'ordering',
        'promptEn': 'Greeting in class?',
        'options': ['Good morning, maam', 'Run now', 'Sit', 'Later'],
        'correctIndex': 0,
      },
      {
        'type': 'mcq',
        'promptEn': 'Appropriate greeting in office?',
        'options': ['Good afternoon', 'Yo', 'What', 'None'],
        'correctIndex': 0,
      },
      {
        'type': 'mcq',
        'promptEn': 'Greeting before starting a call?',
        'options': ['Hello, this is Arun', 'Finish now', 'No', 'Skip'],
        'correctIndex': 0,
      },
    ],
  };
}
