import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/quiz_controller.dart';
import '../../controllers/gamification_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Main Controllers - lazy load
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    
    // ✅ Feature Controllers - needed for bottom navigation tabs
    Get.lazyPut<QuizController>(() => QuizController());
    Get.lazyPut<GamificationController>(() => GamificationController());
    
    // AuthController loaded separately at login
  }
}
