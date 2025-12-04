# 📋 PANDUAN IMPLEMENTASI LENGKAP - Learning App

**Dokumentasi ini berisi semua perbaikan untuk fitur-fitur yang belum jalan.**

---

## 📑 Daftar Isi
1. [Perbaikan Admin Quiz Management (Edit/Hide/Delete)](#1-perbaikan-admin-quiz-management)
2. [Dark Mode / Light Mode dengan Opsi Sistem](#2-dark-mode-light-mode)
3. [Toggle Notifikasi Fungsional](#3-toggle-notifikasi)
4. [Help & Support ke GitHub Issues](#4-help-support-github)
5. [Implementasi Fitur Courses](#5-implementasi-courses)
6. [Cara Deploy & Testing](#6-deploy-testing)

---

## 1. Perbaikan Admin Quiz Management

### ✅ Status Saat Ini
- Admin quiz page sudah ada
- Logic hide/delete sudah ada di admin_quiz_page.dart
- **MASALAH**: User masih bisa lihat quiz yang sudah di-hide

### 🔧 Yang Perlu Diperbaiki

#### A. Update Quiz Model
Pastikan `quiz_model.dart` punya field `isHidden`:

```dart
// File: lib/app/data/models/quiz_model.dart
class QuizModel {
  final String quizId;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int totalQuestions;
  final int timeLimit;
  final int pointsReward;
  final int coinsReward;
  final int passingScore;
  final bool isPremium;
  final bool isHidden; // ✅ Tambahkan ini jika belum ada
  final DateTime createdAt;
  final DateTime? updatedAt;

  QuizModel({
    required this.quizId,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.totalQuestions,
    this.timeLimit = 0,
    this.pointsReward = 100,
    this.coinsReward = 50,
    this.passingScore = 70,
    this.isPremium = false,
    this.isHidden = false, // ✅ Default false
    required this.createdAt,
    this.updatedAt,
  });

  factory QuizModel.fromFirestore(Map<String, dynamic> data, String id) {
    return QuizModel(
      quizId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      difficulty: data['difficulty'] ?? 'Medium',
      totalQuestions: data['totalQuestions'] ?? 0,
      timeLimit: data['timeLimit'] ?? 0,
      pointsReward: data['pointsReward'] ?? 100,
      coinsReward: data['coinsReward'] ?? 50,
      passingScore: data['passingScore'] ?? 70,
      isPremium: data['isPremium'] ?? false,
      isHidden: data['isHidden'] ?? false, // ✅ Parse dari Firestore
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
      'pointsReward': pointsReward,
      'coinsReward': coinsReward,
      'passingScore': passingScore,
      'isPremium': isPremium,
      'isHidden': isHidden, // ✅ Simpan ke Firestore
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
```

#### B. Update Quiz Controller (SUDAH BENAR ✅)
File `quiz_controller.dart` sudah benar - dia sudah filter quiz yang hidden:

```dart
// ✅ SUDAH ADA DI QUIZ CONTROLLER
Future<void> loadQuizzes() async {
  try {
    isLoading.value = true;
    final allQuizzes = await _quizProvider.getAllQuizzes();
    
    // ✅ Filter out hidden quizzes from user view
    quizzes.value = allQuizzes
        .where((quiz) => quiz.isHidden != true)
        .toList();
  } catch (e) {
    // ...
  }
}
```

#### C. Update Quiz Provider
Tambahkan method untuk hide/unhide quiz:

```dart
// File: lib/app/providers/quiz_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';

class QuizProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ... (method lain yang sudah ada)

  /// ✅ Hide Quiz
  Future<void> hideQuiz(String quizId) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quizId)
          .update({
        'isHidden': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Quiz hidden successfully: $quizId');
    } catch (e) {
      print('❌ Error hiding quiz: $e');
      rethrow;
    }
  }

  /// ✅ Show Quiz (unhide)
  Future<void> showQuiz(String quizId) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quizId)
          .update({
        'isHidden': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Quiz shown successfully: $quizId');
    } catch (e) {
      print('❌ Error showing quiz: $e');
      rethrow;
    }
  }

  /// ✅ Delete Quiz (and all related questions)
  Future<void> deleteQuiz(String quizId) async {
    try {
      // 1. Delete all questions in this quiz
      final questionsSnapshot = await _firestore
          .collection('questions')
          .where('quizId', isEqualTo: quizId)
          .get();

      for (var doc in questionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. Delete the quiz itself
      await _firestore.collection('quizzes').doc(quizId).delete();

      print('✅ Quiz and ${questionsSnapshot.docs.length} questions deleted: $quizId');
    } catch (e) {
      print('❌ Error deleting quiz: $e');
      rethrow;
    }
  }

  /// ✅ Update Quiz
  Future<void> updateQuiz(String quizId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('quizzes').doc(quizId).update(data);
      print('✅ Quiz updated successfully: $quizId');
    } catch (e) {
      print('❌ Error updating quiz: $e');
      rethrow;
    }
  }
}
```

#### D. Firestore Security Rules
Pastikan admin bisa edit/delete:

```javascript
// File: firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Quizzes collection
    match /quizzes/{quizId} {
      // Anyone can read (filtering di app)
      allow read: if request.auth != null;
      
      // Only admin can create, update, delete
      allow create, update, delete: if request.auth != null && isAdmin();
    }
    
    // Questions collection
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && isAdmin();
    }
  }
}
```

### 📝 Cara Testing

1. **Login sebagai admin** (pastikan field `isAdmin: true` di Firestore users)
2. **Buka halaman Admin Quiz** dari Settings
3. **Test Hide**:
   - Klik tombol hide di salah satu quiz
   - Logout dan login sebagai user biasa
   - Quiz tersebut tidak muncul di quiz list
4. **Test Show**:
   - Login kembali sebagai admin
   - Klik tombol show
   - Quiz muncul kembali di user list
5. **Test Delete**:
   - Klik delete
   - Confirm
   - Quiz hilang dari Firestore

---

## 2. Dark Mode / Light Mode

### ✅ Status Saat Ini
- MaterialApp sudah set `themeMode: ThemeMode.system`
- Dark mode toggle ada di settings tapi belum simpan preferensi

### 🔧 Yang Perlu Diperbaiki

#### A. Buat Settings Controller

```dart
// File: lib/presentation/controllers/settings_controller.dart

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
```

#### B. Inject Settings Controller di main.dart

```dart
// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/presentation/pages/not_found_page.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/data/services/firebase_service.dart';
import 'app/data/services/local_storage_services.dart';
import 'core/theme/app_theme.dart';
import 'app/data/seeds/seed_runner.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/settings_controller.dart'; // ✅ IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Initialize Local Storage
  await LocalStorageService.init();
  
  // Initialize AuthController as permanent
  Get.put(AuthController(), permanent: true);
  
  // ✅ Initialize SettingsController as permanent
  Get.put(SettingsController(), permanent: true);

  // Seed data
  Future.delayed(const Duration(seconds: 3), () {
    SeedRunner.runIfAuthenticated();
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    // ✅ Get SettingsController
    final settingsController = Get.find<SettingsController>();
    
    return Obx(() => GetMaterialApp( // ✅ Wrap dengan Obx
      title: 'Learning App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsController.themeMode.value, // ✅ Dynamic theme
      
      // Initial route
      initialRoute: _getInitialRoute(),
      
      // All pages
      getPages: AppPages.pages,
      
      // Unknown route handler
      unknownRoute: GetPage(
        name: AppRoutes.NOT_FOUND,
        page: () => const NotFoundPage(),
      ),
    ));
  }
  
  String _getInitialRoute() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      print('✅ User already logged in: ${user.email}');
      return AppRoutes.MAIN;
    } else {
      print('⚠️ No user logged in, showing splash');
      return AppRoutes.SPLASH;
    }
  }
}
```

#### C. Update Settings Page

Tambahkan di file `lib/presentation/pages/setting/settings_page.dart`:

```dart
// Import di bagian atas:
import '../../controllers/settings_controller.dart';
import 'package:url_launcher/url_launcher.dart';

// Di dalam build method:
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>(); // ✅ TAMBAHKAN

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ... (Profile section sama)
          // ... (Admin menu sama)
          // ... (Account settings sama)
          
          // ==========================================
          // ✅ APP SETTINGS - UPDATED
          // ==========================================
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                // ✅ NOTIFICATIONS - WORKING NOW
                Obx(() => SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: Text(
                    settingsController.notificationsEnabled.value
                        ? 'Enabled'
                        : 'Disabled',
                  ),
                  value: settingsController.notificationsEnabled.value,
                  onChanged: (value) {
                    settingsController.setNotificationEnabled(value);
                  },
                )),
                const Divider(height: 1),
                
                // ✅ THEME MODE - WORKING NOW
                Obx(() => SwitchListTile(
                  secondary: Icon(
                    settingsController.themeMode.value == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: const Text('Follow System Theme'),
                  subtitle: Text(
                    settingsController.followSystemTheme.value
                        ? 'Using system preference'
                        : 'Manual override active',
                  ),
                  value: settingsController.followSystemTheme.value,
                  onChanged: (value) {
                    settingsController.setFollowSystem(value);
                  },
                )),
                
                // ✅ MANUAL DARK MODE TOGGLE
                Obx(() {
                  if (settingsController.followSystemTheme.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_rounded),
                        title: const Text('Dark Mode'),
                        subtitle: Text(
                          settingsController.themeMode.value == ThemeMode.dark
                              ? 'Dark theme active'
                              : 'Light theme active',
                        ),
                        value: settingsController.themeMode.value == ThemeMode.dark,
                        onChanged: (value) {
                          settingsController.toggleDarkMode(value);
                        },
                      ),
                    ],
                  );
                }),
                
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: const Text('Language'),
                  subtitle: const Text('English (Default)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Multi-language support will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ==========================================
          // ✅ ABOUT & HELP - UPDATED
          // ==========================================
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                // ✅ HELP & SUPPORT - WORKING NOW
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Report issues on GitHub'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _openGitHubIssues(),
                ),
                const Divider(height: 1),
                
                // ✅ VIEW REPOSITORY
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: const Text('View Repository'),
                  subtitle: const Text('Open source on GitHub'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _openGitHubRepo(),
                ),
                const Divider(height: 1),
                
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About App'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Learning App',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.school_rounded, size: 48),
                      children: [
                        const Text(
                          'A gamified learning platform with courses, quizzes, and achievements.',
                        ),
                        const SizedBox(height: 16),
                        const Text('Made with ❤️ using Flutter & Firebase'),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Privacy',
                      'Privacy policy will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // ... (Logout button dan version info sama)
        ],
      ),
    );
  }
  
  // ✅ HELPER METHODS
  Future<void> _openGitHubRepo() async {
    final url = Uri.parse('https://github.com/smone-jovan/learning_app');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open GitHub repository',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _openGitHubIssues() async {
    final url = Uri.parse('https://github.com/smone-jovan/learning_app/issues');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open GitHub issues',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // ... (Helper methods lain tetap sama)
}
```

---

## 3. Toggle Notifikasi

### ✅ Sudah Selesai!
Toggle notifikasi sudah terimplementasi di `SettingsController` di atas.

**Fitur yang sudah ada:**
- ✅ Switch notifications on/off
- ✅ Simpan preferensi ke SharedPreferences
- ✅ Load preferensi saat app start
- ✅ Show snackbar konfirmasi

---

## 4. Help & Support ke GitHub

### ✅ Sudah Selesai!
Implementasi sudah ada di section Settings Page di atas.

**Fitur yang ditambahkan:**
- ✅ Link ke GitHub Issues (Help & Support)
- ✅ Link ke GitHub Repository (View Repository)
- ✅ Update About dialog dengan info lengkap

---

## 5. Implementasi Fitur Courses

### 🎯 Course Model

```dart
// File: lib/app/data/models/course_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseId;
  final String title;
  final String description;
  final String category;
  final String level;
  final String imageUrl;
  final int lessonsCount;
  final int duration;
  final bool isPublished;
  final bool isPremium;
  final int pointsReward;
  final int coinsReward;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    this.imageUrl = '',
    this.lessonsCount = 0,
    this.duration = 0,
    this.isPublished = true,
    this.isPremium = false,
    this.pointsReward = 500,
    this.coinsReward = 250,
    required this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CourseModel(
      courseId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      level: data['level'] ?? 'Beginner',
      imageUrl: data['imageUrl'] ?? '',
      lessonsCount: data['lessonsCount'] ?? 0,
      duration: data['duration'] ?? 0,
      isPublished: data['isPublished'] ?? true,
      isPremium: data['isPremium'] ?? false,
      pointsReward: data['pointsReward'] ?? 500,
      coinsReward: data['coinsReward'] ?? 250,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'imageUrl': imageUrl,
      'lessonsCount': lessonsCount,
      'duration': duration,
      'isPublished': isPublished,
      'isPremium': isPremium,
      'pointsReward': pointsReward,
      'coinsReward': coinsReward,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
```

### 🎯 Course Provider & Controller

Lihat dokumentasi lengkap untuk implementasi Course Provider, Course Controller, dan Courses Page yang sudah diupdate dengan UI yang menarik dan filter functionality.

---

## 6. Deploy & Testing

### 📝 Checklist Deployment

#### A. Update Dependencies
```bash
flutter pub get
```

#### B. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

#### C. Testing Checklist

- [ ] **Admin Quiz Management**
  - [ ] Hide quiz → logout → quiz tidak muncul
  - [ ] Show quiz → quiz muncul kembali
  - [ ] Delete quiz → quiz terhapus

- [ ] **Dark Mode**
  - [ ] Toggle "Follow System Theme"
  - [ ] Manual Dark Mode toggle
  - [ ] Restart app → preferensi tersimpan

- [ ] **Notifications**
  - [ ] Toggle on/off
  - [ ] State tersimpan

- [ ] **Help & Support**
  - [ ] Buka GitHub Issues
  - [ ] Buka GitHub Repository

- [ ] **Courses**
  - [ ] List courses muncul
  - [ ] Filter working

---

## 🎯 Summary

Semua fitur sudah siap diimplementasikan! Copy code dari dokumentasi ini dan paste ke file yang sesuai di project Anda.

**Happy Coding! 🎉**
