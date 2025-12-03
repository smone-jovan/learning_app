import 'package:get/get.dart';
import '/../presentation/splash/splash_page.dart';
import '/../presentation/auth/login_page.dart';
import '/../presentation/auth/register_page.dart';
import '/../presentation/auth/forgot_password_page.dart';
import '/../presentation/auth/email_verification_page.dart';
import '/../presentation/pages/main/main_page.dart';
import '/../presentation/home/home_page.dart';
import '/../presentation/pages/courses/courses_page.dart';
import '/../presentation/pages/courses/course_detail_page.dart';
import '/../presentation/pages/lesson/lesson_viewer_page.dart';
import '/../presentation/pages/quiz/quiz_list_page.dart';
import '/../presentation/pages/quiz/quiz_detail_page.dart';
import '/../presentation/pages/quiz/quiz_play_page.dart';
import '/../presentation/pages/quiz/quiz_result_page.dart';
import '/../presentation/pages/leaderboard/leaderboard_page.dart';
import '/../presentation/pages/achievement/achievement_page.dart';
import '/../presentation/pages/profile/profile_page.dart';
import '/../presentation/pages/setting/settings_page.dart';
import '/../presentation/pages/main/main_binding.dart';
import '/../presentation/home/home_binding.dart';

/// Route names untuk navigasi
class AppRoutes {
  static const String SPLASH = '/splash';
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String FORGOT_PASSWORD = '/forgot-password';
  static const String EMAIL_VERIFICATION = '/email-verification';
  static const String MAIN = '/main';
  static const String HOME = '/home';
  static const String COURSE_LIST = '/courses';
  static const String COURSE_DETAIL = '/course-detail';
  static const String LESSON_VIEWER = '/lesson-viewer';
  static const String QUIZ_LIST = '/quizzes';
  static const String QUIZ_DETAIL = '/quiz-detail';
  static const String QUIZ_PLAY = '/quiz-play';
  static const String QUIZ_RESULT = '/quiz-result';
  static const String LEADERBOARD = '/leaderboard';
  static const String ACHIEVEMENTS = '/achievements';
  static const String PROFILE = '/profile';
  static const String SETTINGS = '/settings';

  /// GetPages list untuk routing
  static final routes = [
    // ==================== AUTH ROUTES ====================
    GetPage(
      name: SPLASH,
      page: () => SplashPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: LOGIN,
      page: () => LoginPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: REGISTER,
      page: () => RegisterPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: FORGOT_PASSWORD,
      page: () => ForgotPasswordPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: EMAIL_VERIFICATION,
      page: () => EmailVerificationPage(),
      binding: MainBinding(),
    ),

    // ==================== MAIN ROUTES ====================
    GetPage(
      name: MAIN,
      page: () => MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),

    // ==================== COURSE ROUTES ====================
    GetPage(
      name: COURSE_LIST,
      page: () => CoursesPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: COURSE_DETAIL,
      page: () => CourseDetailPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: LESSON_VIEWER,
      page: () => LessonViewerPage(),
      binding: HomeBinding(),
    ),

    // ==================== QUIZ ROUTES ====================
    GetPage(
      name: QUIZ_LIST,
      page: () => QuizListPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: QUIZ_DETAIL,
      page: () => QuizDetailPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: QUIZ_PLAY,
      page: () => QuizPlayPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: QUIZ_RESULT,
      page: () => QuizResultPage(),
      binding: HomeBinding(),
    ),

    // ==================== GAMIFICATION ROUTES ====================
    GetPage(
      name: LEADERBOARD,
      page: () => LeaderboardPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: ACHIEVEMENTS,
      page: () => AchievementsPage(),
      binding: HomeBinding(),
    ),

    // ==================== USER ROUTES ====================
    GetPage(
      name: PROFILE,
      page: () => ProfilePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: SETTINGS,
      page: () => SettingsPage(),
      binding: HomeBinding(),
    ),
  ];
}
