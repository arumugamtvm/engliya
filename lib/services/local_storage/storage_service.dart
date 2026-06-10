import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage operations using SharedPreferences
/// Provides generic storage methods and JSON serialization support
class StorageService {
  SharedPreferences? _prefs;

  /// Initialize the storage service
  /// Must be called before using any storage methods
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw StorageException('Failed to initialize storage: $e');
    }
  }

  /// Ensure preferences are initialized
  void _ensureInitialized() {
    if (_prefs == null) {
      throw StorageException(
          'StorageService not initialized. Call init() first.');
    }
  }

  // ==================== String Operations ====================

  /// Store a string value
  Future<void> setString(String key, String value) async {
    _ensureInitialized();
    try {
      final success = await _prefs!.setString(key, value);
      if (!success) {
        throw StorageException('Failed to save string for key: $key');
      }
    } catch (e) {
      throw StorageException('Error saving string for key $key: $e');
    }
  }

  /// Retrieve a string value
  /// Returns null if key doesn't exist
  String? getString(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getString(key);
    } catch (e) {
      throw StorageException('Error reading string for key $key: $e');
    }
  }

  // ==================== Boolean Operations ====================

  /// Store a boolean value
  Future<void> setBool(String key, bool value) async {
    _ensureInitialized();
    try {
      final success = await _prefs!.setBool(key, value);
      if (!success) {
        throw StorageException('Failed to save boolean for key: $key');
      }
    } catch (e) {
      throw StorageException('Error saving boolean for key $key: $e');
    }
  }

  /// Retrieve a boolean value
  /// Returns null if key doesn't exist
  bool? getBool(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getBool(key);
    } catch (e) {
      throw StorageException('Error reading boolean for key $key: $e');
    }
  }

  // ==================== Integer Operations ====================

  /// Store an integer value
  Future<void> setInt(String key, int value) async {
    _ensureInitialized();
    try {
      final success = await _prefs!.setInt(key, value);
      if (!success) {
        throw StorageException('Failed to save integer for key: $key');
      }
    } catch (e) {
      throw StorageException('Error saving integer for key $key: $e');
    }
  }

  /// Retrieve an integer value
  /// Returns null if key doesn't exist
  int? getInt(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getInt(key);
    } catch (e) {
      throw StorageException('Error reading integer for key $key: $e');
    }
  }

  // ==================== Double Operations ====================

  /// Store a double value
  Future<void> setDouble(String key, double value) async {
    _ensureInitialized();
    try {
      final success = await _prefs!.setDouble(key, value);
      if (!success) {
        throw StorageException('Failed to save double for key: $key');
      }
    } catch (e) {
      throw StorageException('Error saving double for key $key: $e');
    }
  }

  /// Retrieve a double value
  /// Returns null if key doesn't exist
  double? getDouble(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getDouble(key);
    } catch (e) {
      throw StorageException('Error reading double for key $key: $e');
    }
  }

  // ==================== String List Operations ====================

  /// Store a list of strings
  Future<void> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    try {
      final success = await _prefs!.setStringList(key, value);
      if (!success) {
        throw StorageException('Failed to save string list for key: $key');
      }
    } catch (e) {
      throw StorageException('Error saving string list for key $key: $e');
    }
  }

  /// Retrieve a list of strings
  /// Returns null if key doesn't exist
  List<String>? getStringList(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getStringList(key);
    } catch (e) {
      throw StorageException('Error reading string list for key $key: $e');
    }
  }

  // ==================== JSON Operations ====================

  /// Store a JSON object as a string
  /// Converts Map to JSON string before storing
  Future<void> setJson(String key, Map<String, dynamic> json) async {
    _ensureInitialized();
    final String jsonString;
    try {
      jsonString = jsonEncode(json);
    } catch (e) {
      throw StorageException('Failed to encode JSON for key "$key": $e');
    }
    try {
      await setString(key, jsonString);
    } catch (e) {
      throw StorageException('Error saving JSON for key $key: $e');
    }
  }

  /// Retrieve a JSON object
  /// Parses stored JSON string back to Map
  /// Returns null if key doesn't exist
  Map<String, dynamic>? getJson(String key) {
    _ensureInitialized();
    try {
      final jsonString = getString(key);
      if (jsonString == null) {
        return null;
      }
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Error reading JSON for key $key: $e');
    }
  }

  // ==================== Utility Operations ====================

  /// Check if a key exists in storage
  bool containsKey(String key) {
    _ensureInitialized();
    try {
      return _prefs!.containsKey(key);
    } catch (e) {
      throw StorageException('Error checking key existence for $key: $e');
    }
  }

  /// Remove a specific key from storage
  Future<void> remove(String key) async {
    _ensureInitialized();
    try {
      final success = await _prefs!.remove(key);
      if (!success) {
        throw StorageException('Failed to remove key: $key');
      }
    } catch (e) {
      throw StorageException('Error removing key $key: $e');
    }
  }

  /// Clear all data from storage
  Future<void> clear() async {
    _ensureInitialized();
    try {
      final success = await _prefs!.clear();
      if (!success) {
        throw StorageException('Failed to clear storage');
      }
    } catch (e) {
      throw StorageException('Error clearing storage: $e');
    }
  }

  /// Get all keys in storage
  Set<String> getKeys() {
    _ensureInitialized();
    try {
      return _prefs!.getKeys();
    } catch (e) {
      throw StorageException('Error getting keys: $e');
    }
  }
}

/// Custom exception for storage-related errors
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
