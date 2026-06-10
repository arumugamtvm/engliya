import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/logging/app_logger.dart';

/// Service for handling speech recognition
class SpeechService {
  static const String _tag = 'SpeechService';

  /// Indian English - the right locale for Tamil Nadu learners
  static const String preferredLocaleId = 'en_IN';

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  String? _localeId;

  /// Initialize speech recognition
  /// Note: speech_to_text requests microphone permission during initialize,
  /// so no separate permission request is needed here.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Initialize speech recognition (requests mic permission if needed)
    _isInitialized = await _speech.initialize(
      onError: (error) =>
          AppLogger.error('Speech recognition error: $error', tag: _tag),
      onStatus: (status) =>
          AppLogger.debug('Speech recognition status: $status', tag: _tag),
    );

    if (_isInitialized) {
      _localeId = await _resolvePreferredLocale();
    }

    return _isInitialized;
  }

  /// Resolve the preferred recognition locale (en_IN), falling back to the
  /// device default (null) when Indian English is not supported.
  Future<String?> _resolvePreferredLocale() async {
    try {
      final locales = await _speech.locales();
      for (final locale in locales) {
        if (locale.localeId.replaceAll('-', '_').toLowerCase() ==
            preferredLocaleId.toLowerCase()) {
          return locale.localeId;
        }
      }
      AppLogger.info(
        '$preferredLocaleId locale not available; using device default',
        tag: _tag,
      );
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to query speech locales; using device default',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized && _speech.isAvailable;

  /// Check if currently listening
  bool get isListening => _speech.isListening;

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    required Function(double) onSoundLevel,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Failed to initialize speech recognition');
      }
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: (level) {
        onSoundLevel(level);
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
      localeId: _localeId,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  /// Calculate similarity between two strings (0.0 to 1.0)
  double calculateSimilarity(String text1, String text2) {
    final words1 = text1.toLowerCase().split(' ');
    final words2 = text2.toLowerCase().split(' ');

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    int matchCount = 0;
    for (final word in words1) {
      if (words2.contains(word)) {
        matchCount++;
      }
    }

    // Calculate percentage of matching words
    final similarity = matchCount / words1.length;
    return similarity;
  }

  /// Calculate pronunciation score based on recognized text
  double calculateScore(String expected, String recognized) {
    if (recognized.isEmpty) return 0.0;

    // Calculate word-level similarity
    final similarity = calculateSimilarity(expected, recognized);

    // Convert to percentage (0-100)
    return similarity * 100;
  }

  /// Dispose resources
  void dispose() {
    // Cancel any in-flight recognition session, then stop the recognizer
    _speech.cancel();
    _speech.stop();
  }
}
