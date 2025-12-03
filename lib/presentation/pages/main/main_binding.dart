import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load - jangan langsung initialize
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    
    // AuthController hanya load saat login page
  }
}
