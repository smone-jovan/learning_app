import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Theme Mode
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxBool followSystemTheme = true.obs;
  
  // Notifications
  final RxBool notificationsEnabled = true.obs;
  
  // Language
  final RxString selectedLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load settings dari SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final savedThemeMode = prefs.getString('theme_mode') ?? 'system';
      followSystemTheme.value = savedThemeMode == 'system';
      
      switch (savedThemeMode) {
        case 'light':
          themeMode.value = ThemeMode.light;
          break;
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        default:
          themeMode.value = ThemeMode.system;
      }
      
      // Apply theme
      Get.changeThemeMode(themeMode.value);
      
      // Load notifications
      notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
      
      // Load language
      selectedLanguage.value = prefs.getString('language') ?? 'en';
      
      print('✅ Settings loaded: theme=$savedThemeMode, notifications=${notificationsEnabled.value}');
    } catch (e) {
      print('❌ Error loading settings: $e');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode, {bool isSystem = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      themeMode.value = mode;
      followSystemTheme.value = isSystem;
      
      // Save to SharedPreferences
      String themeModeStr = 'system';
      if (!isSystem) {
        themeModeStr = mode == ThemeMode.light ? 'light' : 'dark';
      }
      
      await prefs.setString('theme_mode', themeModeStr);
      
      // Apply theme
      Get.changeThemeMode(mode);
      
      print('✅ Theme mode set to: $themeModeStr');
      
      Get.snackbar(
        'Theme Updated',
        isSystem 
            ? 'Following system theme' 
            : 'Theme set to ${mode == ThemeMode.light ? 'Light' : 'Dark'}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error setting theme: $e');
    }
  }

  /// Toggle Dark Mode (manual override)
  Future<void> toggleDarkMode(bool isDark) async {
    await setThemeMode(
      isDark ? ThemeMode.dark : ThemeMode.light,
      isSystem: false,
    );
  }

  /// Set to follow system
  Future<void> setFollowSystem(bool follow) async {
    if (follow) {
      await setThemeMode(ThemeMode.system, isSystem: true);
    }
  }

  /// Toggle Notifications
  Future<void> setNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      notificationsEnabled.value = enabled;
      await prefs.setBool('notifications_enabled', enabled);
      
      // TODO: Future FCM integration
      // if (enabled) {
      //   await FirebaseMessaging.instance.subscribeToTopic('all_users');
      // } else {
      //   await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
      // }
      
      print('✅ Notifications ${enabled ? 'enabled' : 'disabled'}');
      
      Get.snackbar(
        'Notifications',
        enabled ? 'Notifications enabled' : 'Notifications disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error setting notifications: $e');
    }
  }

  /// Get current theme mode string
  String get currentThemeModeString {
    if (followSystemTheme.value) return 'System';
    return themeMode.value == ThemeMode.light ? 'Light' : 'Dark';
  }
}
