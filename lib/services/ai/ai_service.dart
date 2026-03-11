import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'ai_response_validator.dart';

/// AI Service for Bedrock integration
/// Provides chat, image generation, and learning assistance
/// Uses https://bedrock-proxy.aimodel.workers.dev/apis for AI-powered English learning
class AIService {
  static const String _baseUrl = 'https://bedrock-proxy.aimodel.workers.dev';

  // Available models - optimized for English learning
  static const String modelClaudeSonnet =
      'us.anthropic.claude-sonnet-4-20250514-v1:0';
  static const String modelClaudeHaiku =
      'anthropic.claude-3-haiku-20240307-v1:0';
  static const String modelGemma = 'google.gemma-3-27b-it';

  String _currentModel = modelClaudeHaiku;
  int _maxRetries = 2;
  Duration _timeout = const Duration(seconds: 60);
  final AIResponseValidator _responseValidator = AIResponseValidator();

  /// Set the AI model to use
  void setModel(String model) {
    _currentModel = model;
  }

  /// Configure timeout and retry settings
  void configure({int? maxRetries, Duration? timeout}) {
    if (maxRetries != null) _maxRetries = maxRetries;
    if (timeout != null) _timeout = timeout;
  }

  /// Chat with AI - for grammar explanations, Q&A
  Future<String> chat({
    required String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  }) async {
    final sanitizedMessage = _responseValidator.sanitizeStudentPrompt(message);
    return _executeWithRetry(() async {
      final messages = <Map<String, String>>[];

      // Add system prompt for English teaching context
      if (systemPrompt != null) {
        messages.add({'role': 'system', 'content': systemPrompt});
      } else {
        messages.add({
          'role': 'system',
          'content':
              '''You are a friendly, patient English teacher helping Tamil speakers learn English.

Your teaching style:
• Keep explanations simple and clear
• Use Tamil translations (தமிழ்) when helpful for understanding
• Focus on practical, everyday English usage
• Be encouraging and supportive
• Give examples that relate to daily life
• Correct mistakes gently with explanations

Format your responses clearly with:
• Bullet points for lists
• Bold for important words (use *word*)
• Examples in context
• Tamil translations in parentheses when useful''',
        });
      }

      // Add conversation history (filter to ensure alternating roles)
      if (history != null && history.isNotEmpty) {
        String? lastRole;
        for (final msg in history) {
          final role = msg['role'];
          final content = msg['content'];
          if (content != null && content.isNotEmpty && role != lastRole) {
            messages.add(msg);
            lastRole = role;
          }
        }
        if (lastRole == 'user') {
          messages.last['content'] = sanitizedMessage;
        } else {
          messages.add({'role': 'user', 'content': sanitizedMessage});
        }
      } else {
        messages.add({'role': 'user', 'content': sanitizedMessage});
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/chat/completions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _currentModel,
              'messages': messages,
              'max_tokens': 1500,
              'temperature': 0.7,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['choices'][0]['message']['content'] ?? 'No response';
        return _responseValidator.validateTutorResponse(content);
      } else {
        final error = jsonDecode(response.body);
        throw AIServiceException(
          error['error']?.toString() ?? 'Failed to get response',
          statusCode: response.statusCode,
        );
      }
    });
  }

  /// Explain a grammar concept with structured output
  Future<String> explainGrammar({
    required String topic,
    required String userLevel,
  }) async {
    return chat(
      message:
          '''Explain "$topic" for a $userLevel level Tamil speaker learning English.

Please structure your response as:

📚 **What is it?**
[Simple explanation in 2-3 sentences]

✏️ **Examples:**
1. [Example sentence] - [Tamil translation]
2. [Example sentence] - [Tamil translation]
3. [Example sentence] - [Tamil translation]

⚠️ **Common Mistakes:**
• [Mistake to avoid]
• [Mistake to avoid]

💡 **Quick Tip:**
[One helpful tip to remember this concept]''',
    );
  }

  /// Check and correct a sentence with detailed feedback
  Future<Map<String, dynamic>> checkSentence(String sentence) async {
    final response = await chat(
      message:
          '''Check this English sentence and respond in JSON format only:
Sentence: "$sentence"

{
  "isCorrect": true/false,
  "correctedSentence": "corrected version if needed, or original if correct",
  "errors": ["list of specific errors found"],
  "explanation": "brief explanation of corrections",
  "tamilExplanation": "explanation in Tamil",
  "score": 0-100,
  "suggestions": ["improvement suggestions"]
}''',
      systemPrompt:
          'You are an English grammar checker. Always respond with valid JSON only, no other text.',
    );

    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (e) {
      debugPrint('JSON parse error: $e');
    }

    return {
      'isCorrect': false,
      'correctedSentence': sentence,
      'errors': [],
      'explanation': response,
      'tamilExplanation': '',
      'score': 0,
      'suggestions': [],
    };
  }

  /// Generate practice conversation with roles
  Future<List<Map<String, String>>> generateConversation({
    required String topic,
    required String level,
    int turns = 4,
  }) async {
    final response = await chat(
      message:
          '''Create a realistic $turns-turn English conversation about "$topic" for $level level learners.

Format as JSON array only:
[
  {"speaker": "A", "name": "Priya", "english": "...", "tamil": "...", "note": "pronunciation tip or cultural note"},
  {"speaker": "B", "name": "Raj", "english": "...", "tamil": "...", "note": "..."}
]

Make it natural, practical, and include common phrases used in real situations.''',
      systemPrompt:
          'You are creating English learning content. Respond with valid JSON array only.',
    );

    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch != null) {
        final list = jsonDecode(jsonMatch.group(0)!) as List;
        return list
            .map(
              (e) => Map<String, String>.from(
                e.map((k, v) => MapEntry(k.toString(), v.toString())),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Conversation parse error: $e');
    }

    return [];
  }

  /// Generate vocabulary with rich context
  Future<List<Map<String, dynamic>>> generateVocabulary({
    required String topic,
    int count = 5,
  }) async {
    final response = await chat(
      message:
          '''Generate $count English vocabulary words about "$topic" with Tamil translations.

Format as JSON array only:
[
  {
    "word": "...",
    "tamil": "...",
    "pronunciation": "phonetic guide",
    "partOfSpeech": "noun/verb/adjective/etc",
    "example": "example sentence using the word",
    "exampleTamil": "Tamil translation of example",
    "synonyms": ["word1", "word2"],
    "difficulty": "easy/medium/hard"
  }
]''',
      systemPrompt:
          'You are creating vocabulary content. Respond with valid JSON array only.',
    );

    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch != null) {
        final list = jsonDecode(jsonMatch.group(0)!) as List;
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('Vocabulary parse error: $e');
    }

    return [];
  }

  /// Answer a question about the current lesson
  Future<String> answerQuestion({
    required String question,
    required String lessonContext,
  }) async {
    try {
      final response = await chat(
        message: question,
        systemPrompt:
            '''You are helping a Tamil speaker learn English.

Current lesson context: $lessonContext

Guidelines:
• Answer questions simply and clearly
• Use Tamil translations when helpful
• Give practical examples
• If the question is not about English learning, politely redirect to the lesson
• Be encouraging and patient''',
      );
      return _responseValidator.validateTutorResponse(
        response,
        lessonContext: lessonContext,
      );
    } on AIResponseValidationException {
      return _responseValidator.safeFallbackResponse(
        lessonContext: lessonContext,
      );
    }
  }

  /// Generate a quiz question with multiple formats
  Future<Map<String, dynamic>> generateQuizQuestion({
    required String topic,
    required String level,
    String type = 'mcq',
  }) async {
    final response = await chat(
      message:
          '''Create one $type question about "$topic" for $level level.

Format as JSON only:
{
  "type": "$type",
  "question": "...",
  "questionTamil": "...",
  "options": ["A", "B", "C", "D"],
  "correctIndex": 0,
  "explanation": "why this is correct",
  "explanationTamil": "Tamil explanation",
  "hint": "optional hint for learners"
}''',
      systemPrompt:
          'You are creating quiz content. Respond with valid JSON only.',
    );

    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (e) {
      debugPrint('Quiz parse error: $e');
    }

    return {};
  }

  /// Get pronunciation guide for a word or phrase
  Future<Map<String, dynamic>> getPronunciationGuide(String text) async {
    final response = await chat(
      message:
          '''Provide a pronunciation guide for: "$text"

Format as JSON only:
{
  "text": "$text",
  "ipa": "IPA transcription",
  "phonetic": "simple phonetic spelling for Tamil speakers",
  "syllables": ["syl", "la", "bles"],
  "stress": "which syllable to stress",
  "tips": ["pronunciation tips for Tamil speakers"],
  "commonMistakes": ["mistakes to avoid"],
  "similarWords": ["words that sound similar"]
}''',
      systemPrompt:
          'You are a pronunciation expert. Respond with valid JSON only.',
    );

    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (e) {
      debugPrint('Pronunciation parse error: $e');
    }

    return {'text': text, 'phonetic': text};
  }

  /// Execute with retry logic
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          rethrow;
        }
        // Wait before retry with exponential backoff
        await Future.delayed(Duration(milliseconds: 500 * attempts));
        debugPrint('AI Service retry attempt $attempts');
      }
    }
  }
}

/// Custom exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  final int? statusCode;

  AIServiceException(this.message, {this.statusCode});

  @override
  String toString() =>
      'AIServiceException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
