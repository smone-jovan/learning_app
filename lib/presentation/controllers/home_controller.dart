import 'package:get/get.dart';
import 'package:learning_app/app/data/models/user_model.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:learning_app/app/data/models/course_model.dart';
import 'package:learning_app/app/data/repositories/user_repository.dart';
import 'package:learning_app/app/providers/quiz_provider.dart';
import 'package:learning_app/app/providers/course_provider.dart';
import 'package:learning_app/app/routes/app_routes.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final QuizProvider _quizProvider = QuizProvider();
  final CourseProvider _courseProvider = CourseProvider();

  // Observable user data
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxString userName = 'User'.obs;
  final RxInt userPoints = 0.obs;
  final RxInt userCoins = 0.obs;
  final RxInt userLevel = 1.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;

  // Observable lists
  final RxList<CourseModel> ongoingCourses = <CourseModel>[].obs;
  final RxList<QuizModel> recommendedQuizzes = <QuizModel>[].obs;
  final Rx<QuizModel?> dailyChallengeQuiz = Rx<QuizModel?>(null);
  final RxBool isDailyChallengeCompleted = false.obs;

  // Course progress map
  final RxMap<String, double> courseProgressMap = <String, double>{}.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Get greeting based on time
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Load user data
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser != null) {
        final userData = await _userRepository.getUserById(currentUser.uid);
        if (userData != null) {
          userModel.value = userData;
          userName.value = userData.displayName ?? 'User';
          userPoints.value = userData.points ?? 0;
          userCoins.value = userData.coins ?? 0;
          userLevel.value = userData.level ?? 1;
          currentStreak.value = userData.currentStreak ?? 0;
          longestStreak.value = userData.longestStreak ?? 0;
        }

        await loadOngoingCourses(currentUser.uid);
        await loadDailyChallenge();
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load ongoing courses
  Future<void> loadOngoingCourses(String userId) async {
    try {
      final courses = await _courseProvider.getAllCourses();
      ongoingCourses.value = courses.take(3).toList();

      for (var course in ongoingCourses) {
        courseProgressMap[course.courseId] = 0.3;
      }
    } catch (e) {
      print('Error loading ongoing courses: $e');
    }
  }

  /// Load daily challenge quiz
  Future<void> loadDailyChallenge() async {
    try {
      final quizzes = await _quizProvider.getAllQuizzes();
      if (quizzes.isNotEmpty) {
        dailyChallengeQuiz.value = quizzes.first;
        isDailyChallengeCompleted.value = false;
      }
    } catch (e) {
      print('Error loading daily challenge: $e');
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadUserData();
  }

  /// Navigate to notifications
  void navigateToNotifications() {
    Get.snackbar(
      'Coming Soon',
      'Notifications feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Navigate to settings
  void navigateToSettings() {
    Get.snackbar(
      'Coming Soon',
      'Settings page will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Navigate to quizzes
  void navigateToQuizzes() {
    Get.toNamed(AppRoutes.QUIZ_LIST);
  }

  /// Navigate to courses
  void navigateToCourses() {
    Get.toNamed(AppRoutes.COURSE_LIST);
  }

  /// Navigate to achievements
  void navigateToAchievements() {
    Get.toNamed(AppRoutes.ACHIEVEMENTS);
  }

  /// Navigate to leaderboard
  void navigateToLeaderboard() {
    Get.toNamed(AppRoutes.LEADERBOARD);
  }

  /// Handle course tap
  void onCourseTap(String courseId) {
    Get.toNamed(
      AppRoutes.COURSE_DETAIL,
      arguments: {'courseId': courseId},
    );
  }

  /// Handle quiz tap
  void onQuizTap(String quizId) {
    Get.toNamed(
      AppRoutes.QUIZ_DETAIL,
      arguments: {'quizId': quizId},
    );
  }
}
