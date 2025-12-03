import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '/../../presentation/pages/main/main_binding.dart';
import '/../../presentation/pages/main/main_page.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Bindings
import '/../../presentation/pages/main/main_binding.dart';
import '/../../presentation/pages/quiz/quiz_binding.dart';
import '/../../presentation/home/home_binding.dart';

// Pages
import '/../../presentation/home/home_page.dart';
import '/../../presentation/pages/quiz/quiz_list_page.dart';
import '/../../presentation/pages/quiz/quiz_detail_page.dart';
import '/../../presentation/pages/quiz/quiz_play_page.dart';
import '/../../presentation/pages/quiz/quiz_result_page.dart';
import '/../../presentation/pages/courses/courses_page.dart';
import '/../../presentation/pages/leaderboard/leaderboard_page.dart';
import '/../../presentation/pages/profile/profile_page.dart';
import '/../../presentation/pages/setting/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase Initialized Successfully');
  } catch (e) {
    print('❌ Firebase Initialization Error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      defaultTransition: Transition.cupertino,
      getPages: [
        // ========== MAIN ROUTE ==========
        GetPage(
          name: '/',
          page: () => const MainPage(),
          binding: MainBinding(),
          transition: Transition.noTransition,
        ),

        // ========== HOME ROUTE ==========
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),

        // ========== QUIZ ROUTES ==========
        GetPage(
          name: '/quizzes',
          page: () => const QuizListPage(),
          binding: QuizBinding(),
        ),
        GetPage(
          name: '/quiz-detail',
          page: () => const QuizDetailPage(),
          binding: QuizBinding(),
        ),
        GetPage(
          name: '/quiz-play',
          page: () => const QuizPlayPage(),
          binding: QuizBinding(),
        ),
        GetPage(
          name: '/quiz-result',
          page: () => const QuizResultPage(),
          binding: QuizBinding(),
        ),

        // ========== COURSES ROUTE ==========
        GetPage(
          name: '/courses',
          page: () => const CoursesPage(),
        ),

        // ========== LEADERBOARD ROUTE ==========
        GetPage(
          name: '/leaderboard',
          page: () => const LeaderboardPage(),
        ),

        // ========== PROFILE ROUTE ==========
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
        ),

        // ========== SETTINGS ROUTE ==========
        GetPage(
          name: '/settings',
          page: () => const SettingsPage(),
        ),
      ],
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('404 - Page Not Found'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.offNamed('/'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
