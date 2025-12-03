import 'package:get/get.dart';
import 'package:learning_app/presentation/controllers/home_controller.dart';
import 'package:learning_app/presentation/controllers/auth_controller.dart';
/// Home Binding - Dependency injection untuk Home Page
class HomeBinding extends Bindings {
@override
void dependencies() {
// Pastikan AuthController sudah ada
if (!Get.isRegistered<AuthController>()) {
Get.put(AuthController(), permanent: true);
}
// Initialize HomeController
Get.lazyPut<HomeController>(() => HomeController());
}
}
