import 'package:get/get.dart';
import 'package:learning_app/app/data/models/achievement_model.dart';
import 'package:learning_app/app/providers/achievement_provider.dart';
import 'auth_controller.dart';

/// Gamification Controller - Manages achievements and rewards
class GamificationController extends GetxController {
  final AchievementProvider _achievementProvider = AchievementProvider();

  // Observable lists
  final RxList<AchievementModel> achievements = <AchievementModel>[].obs;
  final RxList<String> userAchievements = <String>[].obs;
  final RxString selectedAchievementCategory = 'All'.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
  }

  /// Get filtered achievements based on category
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

  /// Load all achievements
  Future<void> loadAchievements() async {
    try {
      isLoading.value = true;

      // Get all achievements
      final allAchievements = await _achievementProvider.getAllAchievements();
      achievements.value = allAchievements;

      // Get user achievements
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser != null) {
        final userAchievementsList =
            await _achievementProvider.getUserAchievements(currentUser.uid);
        userAchievements.value =
            userAchievementsList.map((a) => a.achievementId).toList();
      }
    } catch (e) {
      print('Error loading achievements: $e');
      Get.snackbar(
        'Error',
        'Failed to load achievements',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter achievements by category
  void filterAchievementsByCategory(String category) {
    selectedAchievementCategory.value = category;
  }

  /// Check and unlock achievement
  Future<void> checkAndUnlockAchievement({
    required String category,
    required int currentProgress,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) return;

      final userId = currentUser.uid;

      // Find achievements that match criteria
      final eligibleAchievements = achievements.where((achievement) {
        return achievement.category.toLowerCase() == category.toLowerCase() &&
            currentProgress >= achievement.requirement &&
            !userAchievements.contains(achievement.achievementId);
      }).toList();

      // Unlock eligible achievements
      for (var achievement in eligibleAchievements) {
        final unlocked = await _achievementProvider.unlockAchievement(
          userId: userId,
          achievementId: achievement.achievementId,
        );

        if (unlocked) {
          userAchievements.add(achievement.achievementId);

          // Show notification
          _showAchievementUnlockedNotification(achievement);

          // Award rewards
          await _awardAchievementRewards(achievement);
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  /// Show achievement unlocked notification
  void _showAchievementUnlockedNotification(AchievementModel achievement) {
    Get.snackbar(
      '🏆 Achievement Unlocked!',
      achievement.title,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Award achievement rewards (points and coins)
  Future<void> _awardAchievementRewards(AchievementModel achievement) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) return;

      // Award points
      if (achievement.pointsReward > 0) {
        // Update user points in Firestore
        // This should be handled by UserRepository
        print('Awarded ${achievement.pointsReward} points');
      }

      // Award coins
      if (achievement.coinsReward > 0) {
        // Update user coins in Firestore
        // This should be handled by UserRepository
        print('Awarded ${achievement.coinsReward} coins');
      }
    } catch (e) {
      print('Error awarding achievement rewards: $e');
    }
  }

  /// Get achievement by ID
  AchievementModel? getAchievementById(String achievementId) {
    try {
      return achievements.firstWhere((a) => a.achievementId == achievementId);
    } catch (e) {
      return null;
    }
  }

  /// Check if achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    return userAchievements.contains(achievementId);
  }
}
