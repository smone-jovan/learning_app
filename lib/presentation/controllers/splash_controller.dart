import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '/app/data/services/local_storage_services.dart';
import 'auth_controller.dart';

/// Splash Controller - Handle initial routing logic
class SplashController extends GetxController {
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
          Get.offAllNamed(AppRoutes.MAIN);
          return;
        }
      }
    }

    // Navigate to login
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
