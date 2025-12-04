import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/app/data/models/course_model.dart';

class CourseProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all published courses
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error fetching courses: $e');
      return [];
    }
  }

  /// Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();

      if (doc.exists) {
        return CourseModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching course: $e');
      return null;
    }
  }

  /// Get courses by category
  Future<List<CourseModel>> getCoursesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('isPublished', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error fetching courses by category: $e');
      return [];
    }
  }

  /// Stream courses (for real-time updates)
  Stream<List<CourseModel>> streamCourses() {
    return _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
