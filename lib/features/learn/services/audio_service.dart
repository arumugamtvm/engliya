import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/utils/error_handler.dart' as app_error;

/// Service for handling text-to-speech audio playback
/// Requirement 7.4: Audio playback for example sentences
class AudioService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _initializationFailed = false;

  /// Initialize the TTS engine with default settings
  Future<void> init() async {
    if (_isInitialized) return;
    if (_initializationFailed) {
      throw TtsException('TTS initialization previously failed');
    }

    try {
      // Set default language
      await _tts.setLanguage('en-US');
      
      // Set default speech rate (0.5 = slower, 1.0 = normal)
      await _tts.setSpeechRate(0.5);
      
      // Set default pitch (1.0 = normal)
      await _tts.setPitch(1.0);
      
      // Set default volume (1.0 = max)
      await _tts.setVolume(1.0);
      
      _isInitialized = true;
    } catch (e) {
      _initializationFailed = true;
      app_error.ErrorHandler.logError('AudioService.init', e);
      throw TtsException('Failed to initialize text-to-speech: $e');
    }
  }

  /// Play text using text-to-speech
  /// [text] - The text to speak
  /// [language] - Language code (default: 'en-US')
  /// Throws [TtsException] if TTS is unavailable
  Future<void> speak(String text, {String language = 'en-US'}) async {
    if (_initializationFailed) {
      throw TtsException('TTS is unavailable');
    }

    if (!_isInitialized) {
      await init();
    }

    try {
      // Set language if different from current
      await _tts.setLanguage(language);
      
      // Speak the text
      await _tts.speak(text);
    } catch (e) {
      app_error.ErrorHandler.logError('AudioService.speak', e);
      throw TtsException('Failed to play audio: $e');
    }
  }

  /// Stop current audio playback
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _tts.stop();
    } catch (e) {
      app_error.ErrorHandler.logError('AudioService.stop', e);
      // Don't throw for stop errors - not critical
    }
  }

  /// Configure speech rate
  /// [rate] - Speech rate (0.0 to 1.0, where 0.5 is slower, 1.0 is normal)
  Future<void> setRate(double rate) async {
    if (!_isInitialized) return;

    try {
      await _tts.setSpeechRate(rate);
    } catch (e) {
      app_error.ErrorHandler.logError('AudioService.setRate', e);
      throw TtsException('Failed to set speech rate: $e');
    }
  }

  /// Configure speech pitch
  /// [pitch] - Pitch level (1.0 is normal)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;

    try {
      await _tts.setPitch(pitch);
    } catch (e) {
      app_error.ErrorHandler.logError('AudioService.setPitch', e);
      throw TtsException('Failed to set pitch: $e');
    }
  }

  /// Configure speech volume
  /// [volume] - Volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      await _tts.setVolume(volume);
    } catch (e) {
      app_error.ErrorHandler.logError('AudioService.setVolume', e);
      throw TtsException('Failed to set volume: $e');
    }
  }

  /// Check if TTS is available
  bool get isAvailable => _isInitialized && !_initializationFailed;
}

/// Custom exception for TTS errors
class TtsException implements Exception {
  final String message;

  TtsException(this.message);

  @override
  String toString() => 'TtsException: $message';
}
