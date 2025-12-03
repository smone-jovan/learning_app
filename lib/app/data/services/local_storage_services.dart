import 'package:get_storage/get_storage.dart';

/// Service untuk local storage menggunakan GetStorage
class LocalStorageService {
  static final GetStorage _box = GetStorage();

  // Keys
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserName = 'userName';
  static const String keyThemeMode = 'themeMode';
  static const String keyLanguage = 'language';

  /// Initialize GetStorage
  static Future<void> init() async {
    await GetStorage.init();
  }

  /// Save data
  static Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  /// Read data
  static T? read<T>(String key) {
    return _box.read<T>(key);
  }

  /// Remove data
  static Future<void> remove(String key) async {
    await _box.remove(key);
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await _box.erase();
  }

  /// Check if key exists
  static bool hasData(String key) {
    return _box.hasData(key);
  }
}
