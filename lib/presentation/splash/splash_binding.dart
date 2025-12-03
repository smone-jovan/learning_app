import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// Splash Binding
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
