import 'package:get/get.dart';
import '../../controllers/quiz_controller.dart';
import '../../controllers/auth_controller.dart';

/// Quiz Binding - Dependency injection untuk Quiz System
class QuizBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthController exists
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    // Initialize QuizController
    Get.lazyPut<QuizController>(() => QuizController());
  }
}
