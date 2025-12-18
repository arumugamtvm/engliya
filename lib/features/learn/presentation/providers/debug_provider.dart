import 'package:flutter/foundation.dart';
import '../../services/debug_service.dart';
import '../../../../core/utils/error_handler.dart';

/// Provider for managing Debug Mode state
/// Handles debug mode toggle, unlock all, and reset all operations
/// 
/// Debug mode allows developers to:
/// - Bypass all gating logic
/// - Unlock all phases and lessons with one tap
/// - Reset all progress to fresh state
class DebugProvider extends ChangeNotifier {
  final DebugService _debugService;

  DebugProvider({
    required DebugService debugService,
  }) : _debugService = debugService;

  // State properties
  bool _isDebugModeEnabled = false;
  bool _isProcessing = false;
  String? _statusMessage;

  // Getters
  bool get isDebugModeEnabled => _isDebugModeEnabled;
  bool get isProcessing => _isProcessing;
  String? get statusMessage => _statusMessage;

  /// Initialize and load debug mode state from storage
  /// Should be called when the provider is first created or when the app starts
  Future<void> initialize() async {
    try {
      _isDebugModeEnabled = await _debugService.isDebugModeEnabled();
      notifyListeners();
      print('Debug mode initialized: $_isDebugModeEnabled');
    } catch (e, stackTrace) {
      ErrorHandler.logError('DebugProvider.initialize', e, stackTrace);
      // Default to false if we can't read the state
      _isDebugModeEnabled = false;
      notifyListeners();
    }
  }

  /// Toggle debug mode on or off
  /// Persists the setting across app sessions
  /// 
  /// [enabled] - true to enable debug mode, false to disable
  Future<void> toggleDebugMode(bool enabled) async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      await _debugService.setDebugMode(enabled);
      _isDebugModeEnabled = enabled;
      _statusMessage = enabled 
          ? '✓ Debug mode enabled' 
          : '✓ Debug mode disabled';
      print('Debug mode toggled: $enabled');
    } catch (e, stackTrace) {
      ErrorHandler.logError('DebugProvider.toggleDebugMode', e, stackTrace);
      _statusMessage = 'Failed to ${enabled ? 'enable' : 'disable'} debug mode';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }


  /// Unlock all phases and mark all lessons as mastered
  /// 
  /// This operation:
  /// - Sets all phase final test passed flags to true
  /// - Sets all phase unlock flags to true
  /// - Creates/updates UserLessonStatus for every lesson with mastered status
  Future<void> unlockAll() async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      await _debugService.unlockAll();
      _statusMessage = '✓ All content unlocked successfully';
      print('All content unlocked via debug mode');
    } catch (e, stackTrace) {
      ErrorHandler.logError('DebugProvider.unlockAll', e, stackTrace);
      _statusMessage = 'Failed to unlock content: ${ErrorHandler.getUserMessage(e)}';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Reset all progress to a fresh state
  /// 
  /// This operation:
  /// - Clears all UserLessonStatus data
  /// - Sets all phase test passed flags to false
  /// - Clears all test scores
  /// - Sets all phase unlock flags to false
  /// - Disables debug mode
  Future<void> resetAll() async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      await _debugService.resetAll();
      // Debug mode is disabled as part of reset
      _isDebugModeEnabled = false;
      _statusMessage = '✓ All progress reset successfully';
      print('All progress reset via debug mode');
    } catch (e, stackTrace) {
      ErrorHandler.logError('DebugProvider.resetAll', e, stackTrace);
      _statusMessage = 'Failed to reset progress: ${ErrorHandler.getUserMessage(e)}';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Clear the status message
  /// Useful for dismissing success/error messages after user acknowledgment
  void clearStatus() {
    _statusMessage = null;
    notifyListeners();
  }
}
