import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/presentation/pages/not_found_page.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/data/services/firebase_service.dart';
import 'app/data/services/local_storage_services.dart';
import 'core/theme/app_theme.dart';
import 'app/data/seeds/seed_runner.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/settings_controller.dart'; // ✅ ADDED

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize Local Storage
  await LocalStorageService.init();

  // Initialize AuthController as permanent
  Get.put(AuthController(), permanent: true);

  // ✅ Initialize SettingsController as permanent
  Get.put(SettingsController(), permanent: true);

  // Seed data hanya jalan jika user sudah login
  Future.delayed(const Duration(seconds: 3), () {
    SeedRunner.runIfAuthenticated();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get SettingsController
    final settingsController = Get.find<SettingsController>();

    return Obx(() => GetMaterialApp(
          // ✅ Wrap dengan Obx untuk reactive theme
          title: 'Learning App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsController.themeMode.value, // ✅ Dynamic theme

          // Initial route
          initialRoute: _getInitialRoute(),

          // All pages
          getPages: AppPages.pages,

          // Unknown route handler
          unknownRoute: GetPage(
            name: AppRoutes.NOT_FOUND,
            page: () => const NotFoundPage(),
          ),
        ));
  }

  String _getInitialRoute() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('✅ User already logged in: ${user.email}');
      return AppRoutes.MAIN;
    } else {
      print('⚠️ No user logged in, showing splash');
      return AppRoutes.SPLASH;
    }
  }
}
