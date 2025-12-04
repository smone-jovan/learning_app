import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '/app/data/services/local_storage_services.dart';
import '/app/data/providers/seed_provider.dart'; // 🆕 TAMBAH
import 'auth_controller.dart';

/// Splash Controller - Handle initial routing logic
class SplashController extends GetxController {
  final SeedProvider _seedProvider = SeedProvider(); // 🆕 TAMBAH
  
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    final isLoggedIn = LocalStorageService.read<bool>(
      LocalStorageService.keyIsLoggedIn,
    ) ?? false;

    if (isLoggedIn) {
      // Check if auth controller has valid user
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        if (authController.currentUser != null) {
          // 🆕 NEW: Seed database di background setelah user login
          print('🌱 Checking if database needs seeding...');
          _seedDatabaseInBackground();
          
          Get.offAllNamed(AppRoutes.MAIN);
          return;
        }
      }
    } else {
      // 🆕 Jika user belum login, jangan seed
      print('! No user logged in, skipping seed');
    }

    // Navigate to login
    Get.offAllNamed(AppRoutes.LOGIN);
  }
  
  /// 🆕 NEW: Seed database di background (tidak block UI)
  Future<void> _seedDatabaseInBackground() async {
    try {
      // Run in background, don't await
      _seedProvider.seedAll().then((_) {
        print('✅ Background seeding completed');
      }).catchError((error) {
        print('❌ Background seeding error: $error');
      });
    } catch (e) {
      print('❌ Error starting background seed: $e');
    }
  }
}
