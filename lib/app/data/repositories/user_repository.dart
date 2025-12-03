import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '/core/constant/firebase_collections.dart';
import '../models/user_model.dart';

/// Repository untuk user data operations
class UserRepository {
  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await FirestoreService.getDocument(
        collection: FirebaseCollections.users,
        docId: userId,
      );

      if (doc != null && doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Update user data
  Future<bool> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = Timestamp.now();

      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: data,
      );
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// Update user points
  Future<bool> updatePoints({
    required String userId,
    required int points,
  }) async {
    try {
      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: {
          'totalPoints': FieldValue.increment(points),
          'updatedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error updating points: $e');
      return false;
    }
  }

  /// Update user coins
  Future<bool> updateCoins({
    required String userId,
    required int coins,
  }) async {
    try {
      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: {
          'coins': FieldValue.increment(coins),
          'updatedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error updating coins: $e');
      return false;
    }
  }

  /// Update user streak
  Future<bool> updateStreak({
    required String userId,
    required int currentStreak,
    required int longestStreak,
  }) async {
    try {
      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: {
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'lastActiveDate': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error updating streak: $e');
      return false;
    }
  }

  /// Add achievement to user
  Future<bool> addAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: {
          'achievements': FieldValue.arrayUnion([achievementId]),
          'updatedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error adding achievement: $e');
      return false;
    }
  }

  /// Enroll user in course
  Future<bool> enrollCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: {
          'enrolledCourses': FieldValue.arrayUnion([courseId]),
          'updatedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error enrolling course: $e');
      return false;
    }
  }

  /// Update user profile photo
  Future<bool> updateProfilePhoto({
    required String userId,
    required String photoUrl,
  }) async {
    try {
      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: {
          'photoUrl': photoUrl,
          'updatedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error updating profile photo: $e');
      return false;
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return FirestoreService.streamDocument(
      collection: FirebaseCollections.users,
      docId: userId,
    ).map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Delete user data
  Future<bool> deleteUser(String userId) async {
    try {
      return await FirestoreService.deleteDocument(
        collection: FirebaseCollections.users,
        docId: userId,
      );
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
