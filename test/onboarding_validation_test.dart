import 'package:engliya/features/onboarding/data/models/user_level.dart';
import 'package:engliya/features/onboarding/services/onboarding_service.dart';
import 'package:engliya/core/constants/app_constants.dart';
import 'package:engliya/services/local_storage/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStorageService extends StorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> setBool(String key, bool value) async => _storage[key] = value;

  @override
  bool? getBool(String key) => _storage[key] as bool?;

  @override
  Future<void> setInt(String key, int value) async => _storage[key] = value;

  @override
  int? getInt(String key) => _storage[key] as int?;

  @override
  Future<void> setString(String key, String value) async =>
      _storage[key] = value;

  @override
  String? getString(String key) => _storage[key] as String?;

  @override
  Future<void> setJson(String key, Map<String, dynamic> json) async =>
      _storage[key] = json;

  @override
  Map<String, dynamic>? getJson(String key) =>
      _storage[key] as Map<String, dynamic>?;

  @override
  Future<void> remove(String key) async => _storage.remove(key);

  @override
  Future<void> clear() async => _storage.clear();
}

void main() {
  group('OnboardingService validation', () {
    test('rejects unknown level id', () async {
      final service = OnboardingService(storageService: FakeStorageService());
      final invalid = UserLevel(
        id: 'invalid',
        name: 'Invalid',
        description: 'Invalid',
      );

      expect(
        () => service.saveUserLevel(invalid),
        throwsA(isA<OnboardingException>()),
      );
    });

    test('drops invalid persisted level', () async {
      final storage = FakeStorageService();
      await storage.setJson(AppConstants.selectedLevelKey, {
        'id': 'custom',
        'name': 'Custom',
        'description': 'Custom',
      });
      final service = OnboardingService(storageService: storage);

      final level = await service.getUserLevel();
      expect(level, isNull);
    });
  });
}
