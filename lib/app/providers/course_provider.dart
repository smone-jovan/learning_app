import 'package:learning_app/app/data/services/firestore_service.dart';
import 'package:learning_app/core/constant/firebase_collections.dart';
import 'package:learning_app/app/data/models/course_model.dart';
import 'package:learning_app/app/data/models/lesson_model.dart';
import 'package:learning_app/app/data/models/user_progress_model.dart';
/// Provider untuk course data dari Firestore
class CourseProvider {
  /// Get all courses
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.courses,
        queryBuilder: (query) => query.orderBy('createdAt', descending: true),
      );

      return docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  /// Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await FirestoreService.getDocument(
        collection: FirebaseCollections.courses,
        docId: courseId,
      );

      if (doc != null && doc.exists) {
        return CourseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting course: $e');
      return null;
    }
  }

  /// Get courses by category
  Future<List<CourseModel>> getCoursesByCategory(String category) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.courses,
        queryBuilder: (query) =>
            query.where('category', isEqualTo: category),
      );

      return docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting courses by category: $e');
      return [];
    }
  }

  /// Get course lessons
  Future<List<LessonModel>> getCourseLessons(String courseId) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.lessons,
        queryBuilder: (query) =>
            query.where('courseId', isEqualTo: courseId).orderBy('order'),
      );

      return docs.map((doc) => LessonModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting lessons: $e');
      return [];
    }
  }

  /// Get user progress for course
  Future<UserProgressModel?> getUserProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.userProgress,
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('courseId', isEqualTo: courseId),
        limit: 1,
      );

      if (docs.isNotEmpty) {
        return UserProgressModel.fromFirestore(docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting user progress: $e');
      return null;
    }
  }

  /// Save user progress
  Future<bool> saveUserProgress(UserProgressModel progress) async {
    try {
      return await FirestoreService.setDocument(
        collection: FirebaseCollections.userProgress,
        docId: progress.progressId,
        data: progress.toMap(),
        merge: true,
      );
    } catch (e) {
      print('Error saving user progress: $e');
      return false;
    }
  }
}
