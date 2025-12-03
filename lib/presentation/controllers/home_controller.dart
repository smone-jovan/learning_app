import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/app/data/models/user_model.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:learning_app/app/data/models/course_model.dart';

/// Home Controller - Manage dashboard data dan logic
class HomeController extends GetxController {
  // ========== OBSERVABLES ==========
  final Rx<UserModel?> userModel = Rx(null);
  final Rx<QuizModel?> dailyChallenge = Rx(null);
  final RxList<CourseModel> recommendedCourses = RxList([]);
  final RxBool isLoading = RxBool(false);
  final RxBool isRefreshing = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    _loadDashboardData();
  }

  /// ========== LOAD DASHBOARD DATA ==========
  void _loadDashboardData() async {
    isLoading.value = true;
    try {
      // TODO: Load from Firebase using userModel.fromFirestore()
      _loadDummyData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ========== DUMMY DATA (Replace with Firebase) ==========
  void _loadDummyData() {
    userModel.value = UserModel(
      userId: '1',
      displayName: 'Learner',
      email: 'learner@example.com',
      points: 250,
      coins: 50,
      level: 2,
      currentStreak: 5,
      longestStreak: 12,
      lastActiveDate: DateTime.now(),
    );

    // ✅ SESUAI DENGAN QuizModel LU
    dailyChallenge.value = QuizModel(
      quizId: '1',
      title: 'Daily Quiz Challenge',
      description: 'Answer 5 questions to earn 100 XP',
      category: 'General Knowledge',
      difficulty: 'Medium',
      totalQuestions: 5,
      timeLimit: 600, // 10 menit
      passingScore: 70,
      pointsReward: 100,
      coinsReward: 10,
      isPremium: false,
      totalAttempts: 0,
    );

    recommendedCourses.value = [
      CourseModel(
        courseId: '1',
        title: 'Flutter Basics',
        description: 'Learn Flutter from scratch',
        category: 'Mobile Development',
        level: 'Beginner',
      ),
      CourseModel(
        courseId: '2',
        title: 'Dart Programming',
        description: 'Master Dart language',
        category: 'Programming',
        level: 'Beginner',
      ),
    ];
  }

  /// ========== GREETING EMOJI ==========
  String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    if (hour < 21) return '🌆';
    return '🌙';
  }

  /// ========== STREAK MESSAGE ==========
  String getStreakMessage() {
    final streak = userModel.value?.currentStreak ?? 0;
    if (streak == 0) {
      return 'Start your streak today! 🔥';
    } else if (streak < 7) {
      return 'Keep it up! 🔥';
    } else if (streak < 30) {
      return 'Amazing consistency! 🚀';
    } else {
      return 'Incredible dedication! ⭐';
    }
  }

  /// ========== REFRESH DASHBOARD ==========
  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
      _loadDummyData();
      Get.snackbar(
        'Success',
        'Dashboard updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh dashboard',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  /// ========== HAS ACTIVE STREAK ==========
  bool hasActiveStreak() {
    if (userModel.value?.lastActiveDate == null) return false;
    final lastActive = userModel.value!.lastActiveDate!;
    final now = DateTime.now();
    final difference = now.difference(lastActive).inDays;
    return difference <= 1;
  }

  /// ========== GET LEVEL COLOR ==========
  Color getLevelColor() {
    final level = userModel.value?.level ?? 1;
    if (level <= 1) return const Color(0xFF3B82F6); // Blue - Beginner
    if (level <= 5) return const Color(0xFFF59E0B); // Orange - Intermediate
    if (level <= 10) return const Color(0xFFEF4444); // Red - Advanced
    return const Color(0xFFA855F7); // Purple - Expert
  }

  /// ========== GET RANK COLOR ==========
  Color getRankColor() {
    const rankColors = {
      'Bronze': Color(0xFFCD7F32),
      'Silver': Color(0xFFC0C0C0),
      'Gold': Color(0xFFFFD700),
      'Platinum': Color(0xFFE5E4E2),
    };
    return const Color(0xFFCD7F32); // Default Bronze
  }

  /// ========== NAVIGATE TO QUIZZES ==========
  void navigateToQuizList() {
    Get.toNamed('/quizzes');
  }

  /// ========== NAVIGATE TO ACHIEVEMENTS ==========
  void navigateToAchievements() {
    Get.toNamed('/achievements');
  }

  /// ========== NAVIGATE TO LEADERBOARD ==========
  void navigateToLeaderboard() {
    Get.toNamed('/leaderboard');
  }

  /// ========== NAVIGATE TO NOTIFICATIONS ==========
  void navigateToNotifications() {
    Get.snackbar(
      'Coming Soon',
      'Notifications page coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ========== NAVIGATE TO SETTINGS ==========
  void navigateToSettings() {
    Get.toNamed('/settings');
  }

  /// ========== START QUIZ ==========
  Future<void> startQuiz(String quizId) async {
    try {
      isLoading.value = true;
      await logActivity('Started quiz: $quizId');
      Get.toNamed('/quiz-play', arguments: {'quizId': quizId});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start quiz: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ========== GET NEXT ACHIEVEMENT HINT ==========
  String getNextAchievementHint() {
    final points = userModel.value?.points ?? 0;
    if (points < 500) {
      return 'Get 500 points to unlock Bronze Achievement';
    } else if (points < 1000) {
      return 'Get 1000 points to unlock Silver Achievement';
    } else if (points < 2500) {
      return 'Get 2500 points to unlock Gold Achievement';
    } else {
      return 'You have unlocked all achievements!';
    }
  }

  /// ========== LOG ACTIVITY ==========
  Future<void> logActivity(String activity) async {
    try {
      // TODO: Log to Firebase
      print('✅ Activity logged: $activity');
    } catch (e) {
      print('❌ Error logging activity: $e');
    }
  }

  /// ========== UPDATE USER STATS ==========
  Future<void> updateUserStats({
    required int pointsEarned,
    required int coinsEarned,
    required bool isStreak,
  }) async {
    try {
      if (userModel.value != null) {
        final updatedUser = userModel.value!.copyWith(
          points: (userModel.value?.points ?? 0) + pointsEarned,
          coins: (userModel.value?.coins ?? 0) + coinsEarned,
          currentStreak:
              isStreak ? (userModel.value?.currentStreak ?? 0) + 1 : 0,
          lastActiveDate: DateTime.now(),
        );
        userModel.value = updatedUser;
        // TODO: Save to Firebase
      }
    } catch (e) {
      print('❌ Error updating user stats: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
