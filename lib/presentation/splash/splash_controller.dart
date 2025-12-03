import 'package:get/get.dart';
import '/app/data/services/firebase_service.dart';

class SplashController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void onInit() {
    super.onInit();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    // ✅ Wait max 3 detik
    await Future.delayed(Duration(seconds: 3));

    final user = _firebaseService.getCurrentUser();

    if (user != null) {
      // ✅ User logged in → go to home
      Get.offNamed('/main');
    } else {
      // ✅ User not logged in → go to login
      Get.offNamed('/login');
    }
  }
}
