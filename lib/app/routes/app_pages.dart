import 'package:get/get.dart';
import 'app_routes.dart';

// Auth pages
import '../../presentation/splash/splash_page.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/auth/register_page.dart';
import '../../presentation/auth/forgot_password_page.dart';

// Main page
import '../../presentation/pages/main/main_page.dart';

// Feature pages
import '../../presentation/pages/courses/courses_page.dart';
import '../../presentation/pages/leaderboard/leaderboard_page.dart';
import '../../presentation/pages/achievement/achievement_page.dart';
import '../../presentation/pages/setting/settings_page.dart';

// ✅ Quiz pages
import '../../presentation/pages/quiz/quiz_list_page.dart';
import '../../presentation/pages/quiz/quiz_detail_page.dart';
import '../../presentation/pages/quiz/quiz_play_page.dart';
import '../../presentation/pages/quiz/quiz_result_page.dart';

// ✅ Admin pages
import '../../presentation/pages/admin/admin_quiz_page.dart';
import '../../presentation/pages/admin/admin_question_page.dart';

// Controllers
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/gamification_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/quiz_controller.dart';

/// Konfigurasi semua pages dan bindings
class AppPages {
  static final pages = [
    // ==========================================
    // AUTH ROUTES
    // ==========================================
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),

    // ==========================================
    // MAIN ROUTE - ✅ INJECT SEMUA CONTROLLER
    // ==========================================
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainPage(),
      binding: BindingsBuilder(() {
        // Auth Controller (sudah permanent, cek dulu)
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }

        // ✅ Home Controller (untuk HomePage)
        Get.lazyPut<HomeController>(() => HomeController());

        // ✅ Quiz Controller (untuk QuizzesPage)
        Get.lazyPut<QuizController>(() => QuizController());

        // ✅ Gamification Controller (untuk AchievementsPage)
        Get.lazyPut<GamificationController>(() => GamificationController());
      }),
    ),

    // ==========================================
    // FEATURE ROUTES
    // ==========================================
    GetPage(
      name: AppRoutes.COURSES,
      page: () => const CoursesPage(),
    ),
    GetPage(
      name: AppRoutes.LEADERBOARD,
      page: () => const LeaderboardPage(),
    ),
    GetPage(
      name: AppRoutes.ACHIEVEMENTS,
      page: () => const AchievementsPage(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),

    // ==========================================
    // QUIZ ROUTES - ✅ UPDATED
    // ==========================================
    GetPage(
      name: AppRoutes.QUIZZES,
      page: () => const QuizListPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<QuizController>()) {
          Get.lazyPut<QuizController>(() => QuizController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.QUIZ_DETAIL,
      page: () => const QuizDetailPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<QuizController>()) {
          Get.lazyPut<QuizController>(() => QuizController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.QUIZ_SESSION,
      page: () => const QuizPlayPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<QuizController>()) {
          Get.lazyPut<QuizController>(() => QuizController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.QUIZ_RESULT,
      page: () => const QuizResultPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<QuizController>()) {
          Get.lazyPut<QuizController>(() => QuizController());
        }
      }),
    ),

    // ==========================================
    // ADMIN ROUTES
    // ==========================================
    GetPage(
      name: AppRoutes.ADMIN_QUIZ,
      page: () => const AdminQuizPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.ADMIN_QUESTION,
      page: () => const AdminQuestionPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
  ];
}
