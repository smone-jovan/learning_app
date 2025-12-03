import 'package:get/get.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';

/// Main Binding - Dependency injection untuk Main Page dengan Bottom Nav
class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthController exists
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    // Main Controller
    Get.lazyPut(() => MainController());

    // Home Controller
    Get.lazyPut(() => HomeController());
  }
}
