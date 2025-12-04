import 'package:get/get.dart';
import 'package:learning_app/app/data/models/course_model.dart';
import 'package:learning_app/app/providers/course_provider.dart';

class CourseController extends GetxController {
  final CourseProvider _courseProvider = CourseProvider();

  // Observable lists
  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final Rx<CourseModel?> selectedCourse = Rx<CourseModel?>(null);

  // Filter state
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedLevel = 'All'.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  /// Load all courses
  Future<void> loadCourses() async {
    try {
      isLoading.value = true;
      final allCourses = await _courseProvider.getAllCourses();
      courses.value = allCourses;
    } catch (e) {
      print('Error loading courses: $e');
      Get.snackbar(
        'Error',
        'Failed to load courses',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load course detail
  Future<void> loadCourseDetail(String courseId) async {
    try {
      isLoading.value = true;
      final course = await _courseProvider.getCourseById(courseId);
      if (course == null) {
        Get.snackbar('Error', 'Course not found');
        return;
      }
      selectedCourse.value = course;
    } catch (e) {
      print('Error loading course detail: $e');
      Get.snackbar(
        'Error',
        'Failed to load course details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter courses by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  /// Filter courses by level
  void filterByLevel(String level) {
    selectedLevel.value = level;
  }

  /// Get filtered courses
  List<CourseModel> get filteredCourses {
    var filtered = courses.toList();

    if (selectedCategory.value != 'All') {
      filtered = filtered
          .where((course) => course.category == selectedCategory.value)
          .toList();
    }

    if (selectedLevel.value != 'All') {
      filtered = filtered
          .where((course) => course.level == selectedLevel.value)
          .toList();
    }

    return filtered;
  }
}
