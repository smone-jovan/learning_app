import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/app/data/models/user_model.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:learning_app/app/data/models/course_model.dart';
import 'package:learning_app/app/data/services/firebase_service.dart';

/// Home Controller - Manage dashboard data dan logic
class HomeController extends GetxController {
  // Providers / services
  late final FirebaseService _firebaseService;

  // Observables
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final Rx<QuizModel?> dailyChallenge = Rx<QuizModel?>(null);
  final RxList<CourseModel> recommendedCourses = RxList<CourseModel>([]);
  final RxBool isLoading = RxBool(false);
  final RxBool isRefreshing = RxBool(false);

  // Store data untuk continue learning
  final Rx<Map<String, dynamic>> continueLearning =
      Rx<Map<String, dynamic>>({});

  StreamSubscription<DocumentSnapshot>? _profileSub;

  @override
  void onInit() {
    super.onInit();
    _firebaseService = FirebaseService();
    _loadDashboardData();
    _subscribeToUserProfile();
  }

  void _subscribeToUserProfile() {
    final uid = _firebaseService.getCurrentUserUID();
    if (uid == null) return;

    // Cancel previous subscription if any
    _profileSub?.cancel();

    _profileSub = _firebaseService.getUserProfileStream(uid).listen((doc) {
      if (!doc.exists) return;
      final data = (doc.data() as Map<String, dynamic>?) ?? {};

      // Map Firestore fields to your UserModel (adjust keys if your Firestore schema differs)
      final mapped = UserModel(
        userId: uid,
        displayName: data['displayName'] ?? data['fullName'] ?? '',
        email: data['email'] ?? '',
        points: (data['points'] ?? 0) as int,
        coins: (data['coins'] ?? 0) as int,
        level: data['level'] ?? 1,
        currentStreak: (data['streak'] ?? data['currentStreak'] ?? 0) as int,
        longestStreak: (data['longestStreak'] ?? 0) as int,
        lastActiveDate: _parseTimestamp(data['lastActiveDate']),
        // keep other fields as needed
      );

      userModel.value = mapped;
    }, onError: (e) {
      print('Error listening to profile: $e');
    });
  }

  DateTime? _parseTimestamp(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Load dashboard data on init
  void _loadDashboardData() async {
    isLoading.value = true;
    try {
      // load non-profile content (daily challenge, recommended courses)
      await Future.wait([
        _loadDailyChallenge(),
        _loadRecommendedCourses(),
        _loadContinueLearning(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load daily challenge
  Future<void> _loadDailyChallenge() async {
    try {
      final doc = await _firebaseService.getDailyChallenge();
      if (doc != null && doc.exists) {
        final d = doc.data() as Map<String, dynamic>;
        dailyChallenge.value = QuizModel(
          quizId: doc.id,
          title: d['title'] ?? '',
          description: d['description'] ?? '',
          category: d['category'] ?? '',       // ADD THIS
          difficulty: d['difficulty'] ?? '',   // ADD THIS
          totalQuestions: d['totalQuestions'] ?? 0, // ADD THIS
          // map other fields if needed
        );
      }
    } catch (e) {
      print('Error loading daily challenge: $e');
      // Don't show error snackbar jika daily challenge kosong
    }
  }

  /// Load recommended courses
  Future<void> _loadRecommendedCourses() async {
    try {
      final docs = await _firebaseService.getCourses();
      recommendedCourses.value = docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CourseModel(
              courseId: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              category: data['category'] ?? '',
              level: data['level']?.toString() ?? 'Beginner',
              // ✅ Add createdAt parameter
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          })
          .toList()
          .cast<CourseModel>();
    } catch (e) {
      print('Error loading recommended courses: $e');
    }
  }

  /// Load continue learning data
  Future<void> _loadContinueLearning() async {
    try {
      // You can fetch user-specific continue learning if needed
      final uid = _firebaseService.getCurrentUserUID();
      if (uid != null) {
        // example: fetch enrolled courses or progress
      }
    } catch (e) {
      print('Error loading continue learning: $e');
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    try {
      await Future.wait([
        _loadDailyChallenge(),
        _loadRecommendedCourses(),
        _loadContinueLearning(),
      ]);
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
      final uid = _firebaseService.getCurrentUserUID();
      if (uid != null) {
        // you can implement a firebase_service method to log activity
        await _firebaseService.updateUserProfile(uid, {
          'lastActivity': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  /// ========== UPDATE USER STATS ==========
  Future<void> updateUserStats({
    required int pointsEarned,
    required int coinsEarned,
    required bool isStreak,
  }) async {
    try {
      final uid = _firebaseService.getCurrentUserUID();
      if (uid == null) {
        print('No user to update');
        return;
      }

      final current = userModel.value;
      final newPoints = (current?.points ?? 0) + pointsEarned;
      final newCoins = (current?.coins ?? 0) + coinsEarned;
      final newStreak = isStreak ? (current?.currentStreak ?? 0) + 1 : 0;

      // Update local state
      userModel.value = current?.copyWith(
            points: newPoints,
            coins: newCoins,
            currentStreak: newStreak,
            lastActiveDate: DateTime.now(),
          ) ??
          UserModel(
            userId: uid,
            displayName: current?.displayName ?? '',
            email: current?.email ?? '',
            points: newPoints,
            coins: newCoins,
            level: current?.level ?? 1,
            currentStreak: newStreak,
            longestStreak: current?.longestStreak ?? newStreak,
            lastActiveDate: DateTime.now(),
          );

      // Persist to Firestore
      await _firebaseService.updateUserProfile(uid, {
        'points': newPoints,
        'coins': newCoins,
        'streak': newStreak,
        'lastActiveDate': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  /// Update level (and persist)
  Future<void> updateLevel(int newLevel) async {
    try {
      final uid = _firebaseService.getCurrentUserUID();
      if (uid == null) return;

      userModel.value = userModel.value?.copyWith(level: newLevel);
      await _firebaseService.updateUserProfile(uid, {
        'level': newLevel,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating level: $e');
    }
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    super.onClose();
  }
}
