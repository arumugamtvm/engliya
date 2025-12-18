import 'package:flutter/foundation.dart';
import '../../../onboarding/services/onboarding_service.dart';
import '../../data/models/user_level.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingService _onboardingService;

  OnboardingProvider({
    required OnboardingService onboardingService,
  }) : _onboardingService = onboardingService;

  UserLevel? _selectedLevel;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserLevel? get selectedLevel => _selectedLevel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSelectedLevel => _selectedLevel != null;

  // Select level
  void selectLevel(UserLevel level) {
    _selectedLevel = level;
    notifyListeners();
  }

  // Complete onboarding
  Future<bool> completeOnboarding() async {
    if (_selectedLevel == null) {
      _error = 'Please select a level';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _onboardingService.saveUserLevel(_selectedLevel!);
      await _onboardingService.markOnboardingComplete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to complete onboarding: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if onboarding is complete
  Future<bool> checkOnboardingStatus() async {
    try {
      return await _onboardingService.hasCompletedOnboarding();
    } catch (e) {
      _error = 'Failed to check onboarding status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Load saved level
  Future<void> loadSavedLevel() async {
    try {
      _selectedLevel = await _onboardingService.getUserLevel();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load saved level: ${e.toString()}';
      notifyListeners();
    }
  }
}
