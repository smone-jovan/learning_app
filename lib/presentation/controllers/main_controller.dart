import 'package:get/get.dart';

class MainController extends GetxController {
  // Current index as observable int
  final RxInt currentIndex = 0.obs;

  /// Change page
  void changePage(int index) {
    currentIndex.value = index;
  }
}
