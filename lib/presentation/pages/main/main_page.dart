import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/presentation/controllers/main_controller.dart';

// ✅ FIX: Use absolute imports untuk semua pages
import 'package:learning_app/presentation/home/home_page.dart';
import 'package:learning_app/presentation/pages/courses/courses_page.dart';
import 'package:learning_app/presentation/pages/leaderboard/leaderboard_page.dart';
import 'package:learning_app/presentation/pages/profile/profile_page.dart';

class MainPage extends GetView<MainController> {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Define pages as method untuk avoid const error
    final pages = <Widget>[
      HomePage(),
      CoursesPage(),
      LeaderboardPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: Obx(() {
        final index = controller.currentIndex.value;
        return IndexedStack(
          index: index,
          children: pages,
        );
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
