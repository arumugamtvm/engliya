import '../../../services/local_storage/storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../data/models/user_level.dart';

/// Service for managing onboarding-related operations
class OnboardingService {
  final StorageService _storageService;

  OnboardingService({required StorageService storageService})
    : _storageService = storageService;

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      final completed = _storageService.getBool(
        AppConstants.hasCompletedOnboardingKey,
      );
      return completed ?? false;
    } catch (e) {
      throw OnboardingException('Failed to check onboarding status: $e');
    }
  }

  /// Mark onboarding as complete
  Future<void> markOnboardingComplete() async {
    try {
      await _storageService.setBool(
        AppConstants.hasCompletedOnboardingKey,
        true,
      );
    } catch (e) {
      throw OnboardingException('Failed to mark onboarding complete: $e');
    }
  }

  /// Save user's selected level
  Future<void> saveUserLevel(UserLevel level) async {
    try {
      if (UserLevel.fromId(level.id) == null) {
        throw OnboardingException('Unknown learning level: ${level.id}');
      }
      await _storageService.setJson(
        AppConstants.selectedLevelKey,
        level.toJson(),
      );
    } catch (e) {
      throw OnboardingException('Failed to save user level: $e');
    }
  }

  /// Get user's saved level
  Future<UserLevel?> getUserLevel() async {
    try {
      final json = _storageService.getJson(AppConstants.selectedLevelKey);
      if (json == null) {
        return null;
      }
      final saved = UserLevel.fromJson(json);
      final validated = UserLevel.fromId(saved.id);
      if (validated == null) {
        await _storageService.remove(AppConstants.selectedLevelKey);
        return null;
      }
      return validated;
    } catch (e) {
      throw OnboardingException('Failed to get user level: $e');
    }
  }

  /// Clear onboarding data (for testing/reset)
  Future<void> clearOnboardingData() async {
    try {
      await _storageService.remove(AppConstants.hasCompletedOnboardingKey);
      await _storageService.remove(AppConstants.selectedLevelKey);
    } catch (e) {
      throw OnboardingException('Failed to clear onboarding data: $e');
    }
  }
}

/// Custom exception for onboarding-related errors
class OnboardingException implements Exception {
  final String message;

  OnboardingException(this.message);

  @override
  String toString() => 'OnboardingException: $message';
}
