import 'package:get/get.dart';
import 'app_routes.dart';
import 'package:learning_app/presentation/splash/splash_page.dart';
import 'package:learning_app/presentation/splash/splash_binding.dart';
import 'package:learning_app/presentation/auth/login_page.dart';
import 'package:learning_app/presentation/auth/register_page.dart';
import 'package:learning_app/presentation/auth/forgot_password_page.dart';
import 'package:learning_app/presentation/auth/auth_binding.dart';
import 'package:learning_app/presentation/pages/main/main_page.dart';
import 'package:learning_app/presentation/pages/main/main_binding.dart';
import 'package:learning_app/presentation/pages/quiz/quiz_list_page.dart';
import 'package:learning_app/presentation/pages/quiz/quiz_detail_page.dart';
import 'package:learning_app/presentation/pages/quiz/quiz_play_page.dart';
import 'package:learning_app/presentation/pages/quiz/quiz_result_page.dart';
import 'package:learning_app/presentation/pages/quiz/quiz_binding.dart';
import 'package:learning_app/presentation/pages/achievement/achievement_page.dart';
import 'package:learning_app/presentation/controllers/gamification_controller.dart';
/// Konfigurasi semua pages dan bindings
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashPage(),  // ✅ Function returning Widget
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.QUIZ_LIST,
      page: () => const QuizListPage(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: AppRoutes.QUIZ_DETAIL,
      page: () => const QuizDetailPage(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: AppRoutes.QUIZ_PLAY,
      page: () => const QuizPlayPage(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: AppRoutes.QUIZ_RESULT,
      page: () => const QuizResultPage(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: AppRoutes.ACHIEVEMENTS,
      page: () => const AchievementsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<GamificationController>(() => GamificationController());
      }),
    ),
  ];
}
