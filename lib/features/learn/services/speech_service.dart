import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Service for handling speech recognition
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      return false;
    }

    // Initialize speech recognition
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );

    return _isInitialized;
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
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
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
    _speech.stop();
  }
}
