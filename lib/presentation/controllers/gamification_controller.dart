// File: lib/presentation/controllers/gamification_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../app/data/models/achievement_model.dart';
import '../../app/data/models/user_model.dart';
import '../../core/constant/firebase_collections.dart';
import 'auth_controller.dart';

class GamificationController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Observable variables - HANYA YANG DIPAKAI
  final RxList<AchievementModel> achievements = <AchievementModel>[].obs;
  final RxList<String> userAchievements = <String>[].obs; // List of unlocked achievementIds
  
  // UI state
  final RxBool isLoading = false.obs;
  final RxString selectedAchievementCategory = 'All'.obs;
  
  // Computed property untuk filtered achievements
  List<AchievementModel> get filteredAchievements {
    if (selectedAchievementCategory.value == 'All') {
      return achievements;
    }
    return achievements
        .where((achievement) =>
            achievement.category.toLowerCase() ==
            selectedAchievementCategory.value.toLowerCase())
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
    loadUserAchievements();
  }

  /// Load all available achievements
  Future<void> loadAchievements() async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await firestore
          .collection(FirebaseCollections.achievements)
          .orderBy('rarity')
          .orderBy('pointsReward')
          .get();

      achievements.value = querySnapshot.docs
          .map((doc) => AchievementModel.fromFirestore(doc))
          .toList();

    } catch (e) {
      print('Error loading achievements: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user's unlocked achievement IDs
  Future<void> loadUserAchievements() async {
    try {
      final userId = authController.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await firestore
          .collection(FirebaseCollections.userAchievements)
          .where('userId', isEqualTo: userId)
          .get();

      // Ambil hanya achievementId saja (List<String>)
      userAchievements.value = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return data['achievementId'] as String;
          })
          .toList();

    } catch (e) {
      print('Error loading user achievements: $e');
    }
  }

  /// Filter achievements by category
  void filterAchievementsByCategory(String category) {
    selectedAchievementCategory.value = category;
  }

  /// Check and unlock achievements (bisa dipanggil dari luar)
  Future<void> checkAchievements() async {
    try {
      final userId = authController.currentUser?.uid;
      if (userId == null) return;

      // Get user data dari Firestore
      final userDoc = await firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .get();
      
      if (!userDoc.exists) return;
      
      final userData = UserModel.fromFirestore(userDoc);

      // Get quiz count
      final quizCount = userData.completedQuizzes?.length ?? 0;

      // Get course count
      final enrolledCount = userData.enrolledCourses?.length ?? 0;

      // Check each locked achievement
      final lockedAchievements = achievements
          .where((a) => !userAchievements.contains(a.achievementId))
          .toList();

      for (var achievement in lockedAchievements) {
        bool shouldUnlock = false;

        switch (achievement.category.toLowerCase()) {
          case 'quiz':
            shouldUnlock = quizCount >= achievement.requirement;
            break;
          case 'course':
            shouldUnlock = enrolledCount >= achievement.requirement;
            break;
          case 'streak':
            shouldUnlock = (userData.currentStreak ?? 0) >= achievement.requirement;
            break;
          case 'points':
            shouldUnlock = (userData.points ?? 0) >= achievement.requirement;
            break;
        }

        if (shouldUnlock) {
          await unlockAchievement(achievement);
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  /// Unlock achievement
  Future<void> unlockAchievement(AchievementModel achievement) async {
    try {
      final userId = authController.currentUser?.uid;
      if (userId == null) return;

      // Import user_achievement_model dulu
      final userAchievementDoc = firestore
          .collection(FirebaseCollections.userAchievements)
          .doc();

      // Simplified - tanpa UserAchievementModel
      await userAchievementDoc.set({
        'userAchievementId': userAchievementDoc.id,
        'userId': userId,
        'achievementId': achievement.achievementId,
        'unlockedAt': FieldValue.serverTimestamp(),
        'isClaimed': false,
        'claimedAt': null,
      });

      // Reload achievements
      await loadUserAchievements();

      // Show notification
      showAchievementNotification(achievement);
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  /// Show achievement notification
  void showAchievementNotification(AchievementModel achievement) {
    Get.snackbar(
      '🏆 Achievement Unlocked!',
      achievement.title,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onPrimary,
      icon: const Icon(Icons.emoji_events_rounded, color: Colors.white),
    );
  }
}
