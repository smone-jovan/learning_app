import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../home/home_page.dart';
import '../courses/courses_page.dart';
import '../quiz/quiz_list_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../achievement/achievement_page.dart';
import 'package:learning_app/app/routes/app_routes.dart';

class MainPage extends StatelessWidget {  // ✅ GANTI DARI GetView<MainController>
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ State untuk selected index (local state, tidak perlu controller)
    final RxInt currentIndex = 0.obs;

    // ✅ List pages
    final List<Widget> pages = [
      const HomePage(),
      const CoursesPage(),
      const QuizListPage(),
      const LeaderboardPage(),
      const AchievementsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
            tooltip: 'Settings',
          ),
        ],
      ),
      
      // ✅ Body dengan IndexedStack
      body: Obx(
        () => IndexedStack(
          index: currentIndex.value,
          children: pages,
        ),
      ),
      
      // ✅ Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: currentIndex.value,
          onDestinationSelected: (index) {
            currentIndex.value = index;
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined),
              selectedIcon: Icon(Icons.quiz_rounded),
              label: 'Quizzes',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard_rounded),
              label: 'Leaderboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Achievements',
            ),
          ],
        ),
      ),
    );
  }
}
